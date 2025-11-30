import {initializeApp} from "firebase-admin/app";
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import {getMessaging, MulticastMessage} from "firebase-admin/messaging";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {onMessagePublished} from "firebase-functions/v2/pubsub";
import * as logger from "firebase-functions/logger";
import {VertexAI, Part} from "@google-cloud/vertexai";
import axios from "axios";

initializeApp();

const PROJECT_ID = "frigozen-app";
const LOCATION = "us-central1";
const UNSPLASH_ACCESS_KEY = "SD6Z8wq-qz9w0680m4Yjd2jZStEs_TzB3oeNpOWMjFI";
const EXPIRATION_CHECK_TOPIC = "daily-expiration-check";
const vertexAI = new VertexAI({project: PROJECT_ID, location: LOCATION});
const generativeModel = vertexAI.getGenerativeModel({
  model: "gemini-2.0-flash-lite",
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
    const enhancedQuery = `${searchQuery} food photography cooked meal closeup`;
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
    logger.error("Unsplash Error:", error);
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
            "category": "string"
          }
        }
        
        Example 1:
        Input: "4 Lait UHT"
        Output: {"item": {"cleanedName": "Lait", "name": "4 Lait UHT",
        "canonicalName": "Milk", "quantity": 4, "dvm": 7,
        "location": "Frigo", "category": "Dairy"}}
        
        Example 2:
        Input: "Paquet de Pates"
        Output: {"item": { "cleanedName": "Pâtes", "name": "Paquet de Pates",
        "canonicalName": "Pasta", "quantity": 1, "dvm": 365,
        "location": "Placard", "category": "Pantry", "name": "Pâtes"}}
        
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
    const {searchKey, inventory, language = "en"} = request.data;
    if (!inventory || !searchKey) {
      throw new HttpsError(
        "invalid-argument",
        "searchKey/inventory required."
      );
    }
    const db = getFirestore();
    const recipesCollectionRef = db
      .collection("globalRecipeCache")
      .doc(searchKey)
      .collection("recipes");

    const cacheSnapshot = await recipesCollectionRef.get();
    if (!cacheSnapshot.empty) {
      logger.info(
        `Cache HIT: ${searchKey}. Display ${cacheSnapshot.size} recipes.`
      );
      const recipes = cacheSnapshot.docs.map((doc) => doc.data());
      return {success: true, data: {recipes: recipes}};
    }

    try {
      const targetLang = language || "en";
      const prompt = `
        Tu es un Chef étoilé au Guide Michelin.
        Ton objectif : Créer des recettes DÉLICIEUSES et
        RÉALISTES pour éviter le gaspillage.

        Inventaire utilisateur : ${JSON.stringify(inventory)}

        RÈGLES STRICTES :
        1. **Réalisme :** Ne propose QUE des recettes qui existent vraiment.
        Pas d'inventions bizarres.
        2. **Cohérence :** Ne mélange pas des ingrédients incompatibles.
        3. **Simplicité :** Si les ingrédients manquent, propose
        une recette classique et liste ce qui manque.
        4. **Priorité :** Utilise les produits qui expirent bientôt.
        5. **LANGUE :** Génère le titre, la description et les
        instructions EXCLUSIVEMENT en **${targetLang}**.

        Génère 10 recettes.
        Pour chaque recette, JSON :
        - title: Titre appétissant (en ${targetLang})
        - description: Description courte (en ${targetLang})
        - imageSearchQuery: Une phrase descriptive en ANGLAIS
        pour chercher une photo sur Unsplash (ex: "delicious
        creamy chicken pasta on a plate restaurant style")
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

      logger.info("Recherche d'images Unsplash...");
      const imagePromises = recipesFromIA.map((recipe) => {
        const query = recipe.imageSearchQuery || recipe.title;
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
export const checkExpirations = onMessagePublished(
  EXPIRATION_CHECK_TOPIC,
  async (event) => {
    logger.info("Scan quotidien des péremptions...");
    const db = getFirestore();
    const messaging = getMessaging();
    const now = new Date();
    const tomorrow = new Date(now);
    tomorrow.setDate(now.getDate() + 1);
    const threeDaysAgo = new Date(now);
    threeDaysAgo.setDate(now.getDate() - 3);

    try {
      const householdsSnapshot = await db.collection("households").get();

      for (const householdDoc of householdsSnapshot.docs) {
        const householdId = householdDoc.id;
        const householdData = householdDoc.data();

        const inventorySnapshot = await db
          .collection("households")
          .doc(householdId)
          .collection("inventory")
          .where(
            "earliestExpirationDate", ">=", Timestamp.fromDate(threeDaysAgo)
          )
          .where(
            "earliestExpirationDate", "<=", Timestamp.fromDate(tomorrow)
          )
          .get();

        if (inventorySnapshot.empty) {
          continue;
        }

        const expiringItems = inventorySnapshot.docs.map(
          (doc) => doc.data().name
        );
        const msg = (
          `🔔 ${expiringItems.length} articles expire soon : ` +
          `${expiringItems.join(", ")}`
        );
        const members = householdData.members || [];

        if (members.length === 0) continue;
        let allTokens: string[] = [];
        for (const memberId of members) {
          const tokensSnapshot = await db
            .collection("users").doc(memberId).collection("deviceTokens").get();
          allTokens = allTokens.concat(tokensSnapshot.docs.map((t) => t.id));
        }

        if (allTokens.length === 0) {
          continue;
        }
        const uniqueTokens = [...new Set(allTokens)];

        const message: MulticastMessage = {
          tokens: uniqueTokens,
          notification: {
            title: "🔔 Alert Anti-Gaspi FrigoZen",
            body: msg.length > 220 ? `${msg.substring(0, 220)}...` : msg,
          },
          data: {screen: "inventory", householdId: householdId},
        };
        const response = await messaging.sendEachForMulticast(message);
        if (response.failureCount > 0) {
          logger.warn(`Échec d'envoi partiel pour la maison ${householdId}.`);
        }
      }
      return null;
    } catch (error) {
      logger.error("Error checkExpirations:", error);
      return null;
    }
  },
);
