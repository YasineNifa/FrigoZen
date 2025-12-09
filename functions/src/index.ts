import {initializeApp} from "firebase-admin/app";
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import {getMessaging, MulticastMessage} from "firebase-admin/messaging";
import {getStorage} from "firebase-admin/storage";
import {GoogleAuth} from "google-auth-library";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {onSchedule} from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";
import {VertexAI, Part} from "@google-cloud/vertexai";
import axios from "axios";

initializeApp();

const PROJECT_ID = "frigozen-app";
const LOCATION = "us-central1";
const UNSPLASH_ACCESS_KEY = "SD6Z8wq-qz9w0680m4Yjd2jZStEs_TzB3oeNpOWMjFI";
const vertexAI = new VertexAI({project: PROJECT_ID, location: LOCATION});
const generativeModel = vertexAI.getGenerativeModel({
  model: "gemini-2.0-flash-lite",
  generationConfig: {
    temperature: 0.3,
  },
});

/**
 * Cherche une image sur Unsplash basée sur des mots-clés.
 * @param {string} searchQuery - Mots-clés (ex: "chicken pasta")
 * Use @returns {Promise<string | null>} - L'URL de l'image ou null
 */
async function getImageUrlFromUnsplash(
  searchQuery: string
): Promise<string | null> {
  if (!UNSPLASH_ACCESS_KEY) {
    return null;
  }
  try {
    const enhancedQuery = `${searchQuery} food`;
    const response = await axios.get("https://api.unsplash.com/search/photos", {
      params: {
        query: enhancedQuery,
        page: 1,
        per_page: 1,
        orientation: "squarish",
        order_by: "relevant",
      },
      headers: {Authorization: `Client-ID ${UNSPLASH_ACCESS_KEY}`},
    });

    if (response.data.results.length > 0) {
      return response.data.results[0].urls.small;
    }
    return null;
  } catch (error) {
    logger.error("Unsplash API Error:", error);
    return null;
  }
}

/**
 * Génère une image avec Imagen 3 (Vertex AI) et l'upload sur Storage.
 * @param {string} prompt - Description de l'image
 * @return {Promise<string | null>} - URL de l'image ou null
 */
async function generateImageWithImagen(prompt: string): Promise<string | null> {
  try {
    const auth = new GoogleAuth({
      scopes: "https://www.googleapis.com/auth/cloud-platform",
    });
    const client = await auth.getClient();
    const accessToken = await client.getAccessToken();

    const url = `https://${LOCATION}-aiplatform.googleapis.com/v1/projects/` +
      `${PROJECT_ID}/locations/${LOCATION}/publishers/google/models/` +
      "imagen-3.0-generate-001:predict";

    const response = await axios.post(
      url,
      {
        instances: [{prompt: prompt}],
        parameters: {
          sampleCount: 1,
          aspectRatio: "1:1",
        },
      },
      {
        headers: {
          "Authorization": `Bearer ${accessToken.token}`,
          "Content-Type": "application/json",
        },
      }
    );

    const predictions = response.data.predictions;
    if (!predictions || predictions.length === 0) return null;

    const base64Image = predictions[0].bytesBase64Encoded;
    const buffer = Buffer.from(base64Image, "base64");
    const randomStr = Math.random().toString(36).substring(7);
    const filename = `generated_recipes/${Date.now()}_${randomStr}.png`;

    const bucket = getStorage().bucket("frigozen-app.appspot.com");
    const file = bucket.file(filename);

    await file.save(buffer, {
      metadata: {contentType: "image/png"},
      public: true,
    });

    return file.publicUrl();
  } catch (error) {
    logger.error("Imagen API Error:", error);
    return null;
  }
}
// ===================================================================
// FONCTION 1 : helloWorld
// ===================================================================
export const helloWorld = onCall((request) => {
  return {message: "Backend en ligne !", success: true};
});

// ===================================================================
// FONCTION 3 : processReceiptGemini (OCR)
// ===================================================================
export const processReceiptGemini = onCall(
  {timeoutSeconds: 60},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated", "Login required."
      );
    }
    const imageBase64 = request.data.imageBase64;
    try {
      const imagePart: Part = {
        inlineData: {mimeType: "image/jpeg", data: imageBase64},
      };

      const prompt = `
          Tu es un assistant pour l'app FrigoZen. Analyse ce ticket de caisse.
          Extrais :
          1. Le nom du magasin.
          2. Les articles ALIMENTAIRES.

          Pour chaque article :
          - "name": Clean name in the same language used by the user without
            number or quantity or brand
          - "extractedName": Le nom EXACT sur le ticket (ex: "Lait 1/2 Ecr").
            C'est ce que l'utilisateur verra.
          - "canonicalName": Le nom SIMPLE en ANGLAIS (ex: "Milk").
            C'est pour la logique.
          - "quantity": Quantité détectée (défaut 1).
          - "dvm": Durée de vie estimée (jours).
          
          Format JSON :
          {
            "storeName": "Magasin",
            "items": [
              { "name": "...", "canonicalName": "...", "quantity": 1, "dvm": 7,
               "location": "Frigo",
               "category": "Dairy" },
               { "name": "...", "canonicalName": "...", "quantity": 2,
                "dvm": 365, "location": "Placard", "category": "Pantry" }
            ]
          }
      `;

      const result = await generativeModel.generateContent({
        contents: [{role: "user", parts: [imagePart, {text: prompt}]}],
      });

      let jsonText =
        result.response.candidates?.[0].content.parts[0].text || "{}";
      jsonText = jsonText.replace(/```json/g, "").replace(/```/g, "").trim();
      const jsonData = JSON.parse(jsonText);

      return {success: true, data: jsonData};
    } catch (error) {
      logger.error("Error OCR:", error);
      throw new HttpsError("internal", "Error OCR.");
    }
  },
);

// ===================================================================
// FONCTION 2 : getSmartItemData
// ===================================================================
export const getSmartItemData = onCall(
  {timeoutSeconds: 30},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated", "Login required."
      );
    }
    const productName = request.data.productName;
    if (!productName) {
      throw new HttpsError(
        "invalid-argument", "Name required."
      );
    }

    try {
      const prompt = `
        You are a database normalizer for the FrigoZen app.
        The user will provide a raw input (e.g., "4 bottles 
        of Milk", "Lait demi-écrémé", "Tomates x3").
        Your job is to extract the CLEAN data.

        RULES:
        1. **Canonical Name:** MUST be the English singular
        product name (e.g., "Milk", not "4 Milk"). Remove
        numbers, packaging info, and brands.
        2. **Quantity:** Extract the quantity from the input.
        If not specified, default is 1. (e.g. "3 pommes" -> quantity: 3).
        3. **DVM (Shelf Life):** Estimate in days based on
        food type (Meat: 3, Veg: 7, Dry: 365).

        Respond ONLY with this JSON:
        {
          "item": {
            "name": "string",           // same as the user input.
            "cleanedName": "string",    // Clean name in the same language
            // used by the user without number or quantity or brand
            "canonicalName": "string",  // CLEAN English name (NO numbers!)
            "quantity": integer,        // Extracted quantity
            "dvm": integer,        // ESTIMATED DAYS (e.g. 3, 7, 21, 365)      
            "location": "string",
            "category": "string"   // MUST be one of: cat_fruits_vegetables,
            // cat_bakery, cat_dairy_eggs, cat_meat_fish, cat_frozen,
            // cat_pantry_salty, cat_pantry_sweet, cat_beverages, cat_baby,
            // cat_pets, cat_other
          }
        }

        STRICT CATEGORY MAPPING:
        Map the item to the most appropriate category from this list:
        - cat_fruits_vegetables (Fruits, vegetables, herbs)
        - cat_bakery (Bread, pastries)
        - cat_dairy_eggs (Milk, cheese, yogurt, eggs)
        - cat_meat_fish (Meat, poultry, fish, seafood)
        - cat_frozen (Frozen foods, ice cream)
        - cat_pantry_salty (Pasta, rice, canned goods, spices, oil)
        - cat_pantry_sweet (Sugar, chocolate, cookies, honey)
        - cat_beverages (Water, juice, soda, alcohol)
        - cat_baby (Baby food, diapers)
        - cat_pets (Pet food, litter)
        - cat_other (Anything else)
        
        Example 1:
        Input: "4 Lait UHT"
        Output: {"item": {"cleanedName": "Lait", "name": "4 Lait UHT",
        "canonicalName": "Milk", "quantity": 4, "dvm": 7,
        "location": "Frigo", "category": "cat_dairy_eggs"}}
        
        Example 2:
        Input: "Paquet de Pates"
        Output: {"item": { "cleanedName": "Pâtes", "name": "Paquet de Pates",
        "canonicalName": "Pasta", "quantity": 1, "dvm": 365,
        "location": "Placard", "category": "cat_pantry_salty"}}
        
        Input: "${productName}"
        Output:
      `;

      const result = await generativeModel.generateContent({
        contents: [{role: "user", parts: [{text: prompt}]}],
      });

      let jsonText =
      result.response.candidates?.[0].content.parts[0].text || "{}";
      jsonText = jsonText.replace(/```json/g, "").replace(/```/g, "").trim();
      const jsonData = JSON.parse(jsonText);
      return {success: true, item: jsonData.item};
    } catch (error) {
      logger.error("Error getSmartItemData:", error);
      throw new HttpsError("internal", "Error normalization.");
    }
  },
);
// ===================================================================
// FONCTION 5 : generateRecipes (CORRECTIF CACHE + IMAGES)
// ===================================================================
export const generateRecipes = onCall(
  {timeoutSeconds: 120},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Login required.");
    }
    const {
      searchKey,
      inventory,
      language = "en",
      preferences = {},
    } = request.data;
    if (!inventory || !searchKey) {
      throw new HttpsError(
        "invalid-argument",
        "searchKey/inventory required."
      );
    }

    // Generate a cache key that includes preferences
    const prefsString = JSON.stringify(preferences);
    // Simple hash for prefs to keep key short-ish
    let prefsHash = 0;
    for (let i = 0; i < prefsString.length; i++) {
      prefsHash = ((prefsHash << 5) - prefsHash) + prefsString.charCodeAt(i);
      prefsHash |= 0; // Convert to 32bit integer
    }
    const fullCacheKey = `${searchKey}_${prefsHash}`;

    const db = getFirestore();
    const recipesCollectionRef = db
      .collection("globalRecipeCache")
      .doc(fullCacheKey)
      .collection("recipes");

    const cacheSnapshot = await recipesCollectionRef.get();
    if (!cacheSnapshot.empty) {
      logger.info(
        `Cache HIT: ${fullCacheKey}. Display ${cacheSnapshot.size} recipes.`
      );
      const recipes = cacheSnapshot.docs.map((doc) => doc.data());
      return {success: true, data: {recipes: recipes}};
    }

    try {
      const targetLang = language || "en";
      const now = new Date();
      const todayStr = now.toISOString().split("T")[0];

      // Construct preferences string for prompt
      let prefsPrompt = "";
      if (preferences.mealType && preferences.mealType !== "Any") {
        prefsPrompt += `- Type de plat : ${preferences.mealType}\n`;
      }
      if (preferences.diet && preferences.diet !== "None") {
        prefsPrompt += `- Régime : ${preferences.diet}\n`;
      }
      if (preferences.difficulty && preferences.difficulty !== "Any") {
        prefsPrompt += `- Difficulté : ${preferences.difficulty}\n`;
      }

      // If no preferences, force expiration priority
      const isStrictExpiration =
        !preferences.mealType &&
        !preferences.diet &&
        !preferences.difficulty;

      const expirationRule = isStrictExpiration ?
        "4. **PRIORITÉ ABSOLUE :** Tu DOIS utiliser les produits dont " +
        "la 'earliestExpirationDate' est proche de la date du jour." :
        "4. **Priorité :** Essaie d'utiliser les produits " +
        "qui expirent bientôt.";

      const prompt = `
        Tu es un Chef de cuisine familiale expérimenté et créatif.
        Ton objectif : Créer des recettes DÉLICIEUSES, SIMPLES et
        RÉALISTES pour éviter le gaspillage au quotidien.

        Date du jour : ${todayStr}
        Inventaire utilisateur : ${JSON.stringify(inventory)}

        PRÉFÉRENCES UTILISATEUR (A RESPECTER IMPÉRATIVEMENT) :
        ${prefsPrompt}

        RÈGLES STRICTES :
        1. **Réalisme :** Ne propose QUE des recettes
        qui existent vraiment et sont faisables à la maison.
        2. **Cohérence :** Ne mélange pas des ingrédients incompatibles.
        3. **Simplicité :** Privilégie des recettes avec
        peu d'ingrédients manquants.
        ${expirationRule}
        5. **LANGUE :** Génère le titre, la description et les
        instructions EXCLUSIVEMENT en **${targetLang}**.

        Génère 5 recettes variées (si possible selon les préférences).
        Pour chaque recette, JSON :
        - title: Titre appétissant (en ${targetLang})
        - description: Description courte (en ${targetLang})
        - imageSearchQuery: Mots-clés VISUELS en ANGLAIS pour
        trouver la photo du plat.
          Doit décrire le plat fini 
          (ex: "spaghetti carbonara plate", "chocolate cake slice").
          Pas de phrases complexes, juste des mots-clés.
        - usedItems: Liste des ingrédients utilisés
        - missingItems: Liste des ingrédients manquants
        - instructions: Liste des étapes (en ${targetLang})

        exemples:
        {
          "recipes": [
            {
              "title": "Titre de la recette",
              "description": "Courte description alléchante.",
              "imageKeywords": "chicken pasta tomato" // Une phrase de
              // recherche 
              // descriptive en ANGLAIS optimisée pour Unsplash. 
              // Elle doit décrire le plat fini dans une assiette 
              // (ex: "delicious creamy chicken pasta on a plate 
              // food photography").
              "usedItems": [ // Articles que l'utilisateur possède
                {"name": "Poulet", "quantity": "200g", "isExpiringSoon": true},
                {"name": "Crème", "quantity": "10cl", "isExpiringSoon": false}
              ],
              "missingItems": [ // Articles que l'utilisateur n'a pas
                {"name": "Champignons", "quantity": "50g"},
                {"name": "Persil", "quantity": "1 brin"}
              ],
              "instructions": [
                "1. Coupez le poulet...",
                "2. Faites chauffer la crème..."
              ]
            }
          ]
        }
      `;

      const geminiResult = await generativeModel.generateContent({
        contents: [{role: "user", parts: [{text: prompt}]}],
      });

      let jsonText =
        geminiResult.response.candidates?.[0].content.parts[0].text || "{}";
      jsonText = jsonText.replace(/```json/g, "").replace(/```/g, "").trim();
      const jsonData = JSON.parse(jsonText);
      const recipesFromIA = (jsonData.recipes as any[]) || [];
      if (recipesFromIA.length === 0) {
        return {success: true, data: {recipes: []}};
      }

      logger.info("Génération des images (Mode Hybride)...");
      const imagePromises = recipesFromIA.map(async (recipe, index) => {
        // Recipe #1: Imagen 3 (Premium)
        if (index === 0) {
          const prompt = "Professional food photography of " +
            `${recipe.title}. ${recipe.description}. High resolution, ` +
            "delicious, restaurant quality, natural lighting.";
          const aiImage = await generateImageWithImagen(prompt);
          if (aiImage) return aiImage;
          // Fallback to Unsplash if AI fails
        }

        // Others: Unsplash
        let query = recipe.imageSearchQuery || recipe.title;
        query = `${query} food photography delicious plate high resolution`;
        return getImageUrlFromUnsplash(query);
      });
      const imageUrls = await Promise.all(imagePromises);
      const finalRecipes = recipesFromIA.map((recipe, index) => {
        return {...recipe, imageUrl: imageUrls[index]};
      });

      const batch = db.batch();
      for (const recipe of finalRecipes) {
        const newRecipeRef = recipesCollectionRef.doc();
        batch.set(newRecipeRef, recipe);
      }
      await batch.commit();
      return {success: true, data: {recipes: finalRecipes}};
    } catch (error) {
      logger.error("Error generateRecipes:", error);
      throw new HttpsError("internal", "Error generating recipes.");
    }
  },
);

// ===================================================================
// FONCTION 6 : checkExpirations (NOTIFICATIONS - MAISONS)
// ===================================================================
export const checkExpiringItems = onSchedule(
  "every day 10:00",
  async (event) => {
    const db = getFirestore();
    const messaging = getMessaging();
    const now = new Date();
    const twoDaysLater = new Date();
    twoDaysLater.setDate(now.getDate() + 2);

    // 1. Query items expiring in the next 2 days
    // Note: Requires a composite index on
    // 'inventory' collection if we add more filters
    // For now we just check the date range.
    const snapshot = await db.collectionGroup("inventory")
      .where("earliestExpirationDate", ">=", Timestamp.fromDate(now))
      .where("earliestExpirationDate", "<=", Timestamp.fromDate(twoDaysLater))
      .get();

    if (snapshot.empty) {
      logger.info("No expiring items found.");
      return;
    }

    // 2. Group items by household
    const householdItems: {[key: string]: string[]} = {};

    snapshot.docs.forEach((doc) => {
      // doc.ref.parent is 'inventory' collection
      // doc.ref.parent.parent is the household document
      const householdId = doc.ref.parent.parent?.id;
      const itemName = doc.data().name;

      if (householdId && itemName) {
        if (!householdItems[householdId]) {
          householdItems[householdId] = [];
        }
        householdItems[householdId].push(itemName);
      }
    });

    // 3. Send notifications for each household
    for (const [householdId, items] of Object.entries(householdItems)) {
      try {
        // Get household members
        const householdDoc =
          await db.collection("households").doc(householdId).get();

        if (!householdDoc.exists) continue;

        // Check if ANY member is premium (Shared Premium logic)
        // Or check the household owner. For simplicity, we check if the
        // user associated with the household has isPremium=true.
        // Since we don't have a direct link here easily without querying users,
        // we will query users who have this householdId.

        const usersSnapshot = await db.collection("users")
          .where("householdId", "==", householdId)
          .get();

        let isPremiumHousehold = false;
        const tokens: string[] = [];

        usersSnapshot.docs.forEach((userDoc) => {
          const userData = userDoc.data();
          if (userData.isPremium === true) {
            isPremiumHousehold = true;
          }
          if (userData.fcmToken) {
            tokens.push(userData.fcmToken);
          }
        });

        // GATE: If no one is premium, SKIP notification
        if (!isPremiumHousehold) {
          logger.info(
            `Skipping notification for household ${householdId} (Not Premium)`
          );
          continue;
        }

        if (tokens.length === 0) continue;

        const message: MulticastMessage = {
          tokens: tokens,
          notification: {
            title: "⚠️ Gaspillage imminent !",
            body: `Vite ! ${items.length} produits expirent bientôt : ` +
              `${items.slice(0, 3).join(", ")}` +
              `${items.length > 3 ? "..." : ""}`,
          },
          data: {
            type: "expiration_alert",
            householdId: householdId,
          },
        };

        const response = await messaging.sendEachForMulticast(message);
        logger.info(
          `Sent ${response.successCount} notifications to ` +
          `household ${householdId}`
        );
      } catch (error) {
        logger.error(
          `Error sending notification to household ${householdId}:`,
          error
        );
      }
    }
  });
