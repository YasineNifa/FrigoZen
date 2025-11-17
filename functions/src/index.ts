import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {ImageAnnotatorClient} from "@google-cloud/vision";
import {VertexAI} from "@google-cloud/vertexai";
// import * as admin from "firebase-admin";
import {initializeApp} from "firebase-admin/app";
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import {getMessaging, MulticastMessage} from "firebase-admin/messaging";
import {onMessagePublished} from "firebase-functions/v2/pubsub";
import axios from "axios";


// Initialiser le client de l'IA (on le met ici, en dehors de la fonction)
// C'est une "bonne pratique" pour la performance (Cold Starts)
const visionClient = new ImageAnnotatorClient();
const PROJECT_ID = "frigozen-app";
const LOCATION = "us-central1";
const UNSPLASH_ACCESS_KEY = "SD6Z8wq-qz9w0680m4Yjd2jZStEs_TzB3oeNpOWMjFI";
const vertexAI = new VertexAI(
  {project: PROJECT_ID, location: LOCATION}
);
const generativeModel = vertexAI.getGenerativeModel({
  model: "gemini-2.0-flash-lite",
});


export const helloWorld = onCall(
  (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must be authenticated.",
      );
    }

    // 2. Si on est ici, request.auth existe
    logger.info("La fonction helloWorld v2 a été appelée !");

    // On utilise "request.auth"
    const email = request.auth.token.email || "utilisateur";
    const message = "Bonjour depuis le Cloud, " + email;

    return {
      message: message,
      success: true,
    };
  },
);


export const processReceiptV2 = onCall(
  // we need a "imageBase64" field in request.data
  async (request) => {
    // Securety check
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "You must be authenticated.");
    }

    // Get the image in Base64 from the request
    const imageBase64 = request.data.imageBase64;
    if (!imageBase64) {
      throw new HttpsError("invalid-argument", "No image provided.");
    }

    logger.info("We are processing the receipt..");

    try {
      // const [result] = await visionClient.textDetection({
      //   image: {
      //     content: imageBase64,
      //   },
      // });
      const [result] = await visionClient.documentTextDetection({
        image: {
          content: imageBase64,
        },
      });

      // const detections = result.textAnnotations;
      // if (!detections || detections.length === 0) {
      //   throw new HttpsError("not-found", "Aucun texte détecté.");
      // }
      const annotation = result.fullTextAnnotation;
      if (!annotation || !annotation.text) {
        throw new HttpsError("not-found", "No text detected.");
      }
      // const fullText = detections[0].description || "";
      // const allLines = fullText.split("\n");
      const fullText = annotation.text;
      const allLines = fullText.split("\n");

      const nonEmptyLines = allLines.filter((line) => line.trim().length > 0);

      logger.info(`Detected Text, ${allLines.length} lines.`);

      return {
        success: true,
        lines: nonEmptyLines,
      };
    } catch (error) {
      logger.error("Error in Vision API:", error);
      throw new HttpsError(
        "internal",
        "Error while processing the receipt.",
      );
    }
  },
);

export const processReceiptGemini = onCall(
  {timeoutSeconds: 60},
  async (request) => {
    // Securety check
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "You must be authenticated.");
    }

    // Get the image in Base64 from the request
    const imageBase64 = request.data.imageBase64;
    if (!imageBase64) {
      throw new HttpsError("invalid-argument", "No image provided.");
    }

    logger.info("We are processing the receipt..");

    try {
      const imagePart = {
        inlineData: {
          mimeType: "image/jpeg",
          data: imageBase64,
        },
      };

      const prompt = `
        Tu es un assistant de gestion de frigo pour l'application FrigoZen.
        Analyse l'image de ce ticket de caisse.

        Ta mission est d'extraire TOUS les articles ALIMENTAIRES.
        - Ignore les articles non-alimentaires (vêtements, sacs poubelle, 
          appareils, etc.).
        - Ignore les totaux, la TVA, les réductions, les numéros de carte, etc.
        - Ignore les éléments de l'interface de l'application
          (comme "Accueil", "Coupons").

        Pour chaque article alimentaire trouvé, extrais les informations 
        suivantes :
        1. "name": Le nom canonique et simple du produit, **en anglais**, 
        simplifié (ex: "Milk" au lieu de "LAIT UHT 1/2 ECR", 
        "Lime" au lieu de "Citrons Verts").
        2. "quantity": La quantité (par défaut 1). Si tu vois "x 2" ou 
        "Pack de 6", utilise ce chiffre.
        3. "dvm": Une estimation de la Durée de Vie Moyenne (DVM) 
        en *jours* après l'achat. (ex: Lait=7, Poulet=3, Conserve=365).
        4. "location": L'emplacement de stockage le plus probable 
        (Frigo, Placard, Congélateur).
        5. "category": La catégorie de l'article en **anglais**
        (ex: "Vegetable", "Dairy", "Meat", "Fruit", "Pantry", "Beverage").

        Réponds OBLIGATOIREMENT et UNIQUEMENT avec un objet JSON.
        Le format doit être:
        {
          "items": [
            { "name": "...", "quantity": 1, "dvm": 7, "location": "Frigo"
            , "category": "Dairy" },
            { "name": "...", "quantity": 2, "dvm": 365, "location": "Placard"
            , "category": "Pantry" }
          ]
        }
        Si tu ne trouves aucun article alimentaire, retourne {"items": []}.
      `;

      const result = await generativeModel.generateContent({
        contents: [{role: "user", parts: [imagePart, {text: prompt}]}],
      });

      // Nettoyer la réponse
      // Gemini renvoie souvent le JSON entouré de "```json ... ```"
      let jsonText =
        result.response.candidates?.[0].content.parts[0].text || "{}";
      jsonText = jsonText.replace(/```json/g, "").replace(/```/g, "").trim();

      logger.info("Brut JSON from Gemini:", jsonText);
      const jsonData = JSON.parse(jsonText);
      // Renvoyer le JSON propre à Flutter
      return {success: true, data: jsonData};
    } catch (error) {
      logger.error("Error in Gemini API:", error);
      throw new HttpsError(
        "internal",
        "Error while processing the receipt.",
      );
    }
  },
);

// ---------------------------------------------
// NOUVELLE FONCTION : CANONICALIZE NAME
// ---------------------------------------------
export const getSmartItemData = onCall(
  {timeoutSeconds: 30},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "You must be logged in.");
    }

    const productName = request.data.productName;
    if (
      !productName || typeof productName !== "string" ||
      productName.trim() === ""
    ) {
      throw new HttpsError(
        "invalid-argument", "Product name must be a non-empty string."
      );
    }

    logger.info(`Canonicalizing name for: "${productName}"`);

    try {
      const prompt = `
        You are a database normalizer for the FrigoZen app.
        The user will provide a single product name, possibly with misspellings.
        
        Your job is to analyze this name and return a structured JSON object.
        - Correct spelling and translate to English for the canonicalName.
        - Guess the quantity if specified (e.g., "6 eggs" -> 6).
        - Estimate its storage location, category, and average shelf life (DVM).

        Respond ONLY with a JSON object in the format:
        {
          "item": {
            "canonicalName": "...", // English, simple name
            "quantity": 1,          // Default 1
            "dvm": 7,               // Default 7
            "location": "...",      // Frigo, Placard, Congélateur
            "category": "..."       // Dairy, Vegetable, Pantry, etc.
          }
        }
        
        Example 1:
        Input: "liat"
        Output: {"item": {"canonicalName": "Milk", "quantity": 1, "dvm": 7, 
        "location": "Frigo", "category": "Dairy"}}
        
        Example 2:
        Input: "6 oeufs"
        Output: {"item": {"canonicalName": "Egg", "quantity": 6, "dvm": 21, 
        "location": "Frigo", "category": "Dairy"}}
        
        Input: "${productName}"
        Output:
      `;

      const result = await generativeModel.generateContent({
        contents: [{role: "user", parts: [{text: prompt}]}],
      });

      let jsonText =
        result.response.candidates?.[0].content.parts[0].text || "{}";

      jsonText = jsonText.replace(/```json/g, "").replace(/```/g, "").trim();

      logger.info(`Gemini Response: ${jsonText}`);

      const jsonData = JSON.parse(jsonText);
      return {success: true, item: jsonData.item};
    } catch (error) {
      logger.error("Error Gemini API (canonicalize):", error);
      throw new HttpsError(
        "internal",
        "Error during name normalization.",
      );
    }
  },
);

/**
 * Cherche une image sur Unsplash basée sur des mots-clés.
 * @param {string} searchQuery - Mots-clés (ex: "chicken pasta")
 * Use @returns {Promise<string | null>} - L'URL de l'image ou null
 */
async function getImageUrlFromUnsplash(
  searchQuery: string
): Promise<string | null> {
  if (!UNSPLASH_ACCESS_KEY || UNSPLASH_ACCESS_KEY.includes("VOTRE_CLÉ")) {
    logger.warn("Clé Unsplash manquante.");
    return null;
  }
  try {
    const enhancedQuery = (
      `${searchQuery} food photography cooked meal close up`
    );
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
      return response.data.results[0].urls.regular;
    }
    return null;
  } catch (error) {
    logger.error("Erreur Unsplash:", error);
    return null;
  }
}

export const generateRecipes = onCall(
  {timeoutSeconds: 120},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "You must be logged in.");
    }
    const {searchKey, inventory} = request.data;
    if (!inventory || !searchKey) {
      throw new HttpsError(
        "invalid-argument",
        "searchKey and inventory are required."
      );
    }
    const db = getFirestore();
    const recipesCollectionRef = db
      .collection("globalRecipeCache")
      .doc(searchKey)
      .collection("recipes");

    const cacheSnapshot = await recipesCollectionRef.limit(10).get();
    if (!cacheSnapshot.empty) {
      logger.info(`Cache HIT: ${searchKey}. Display recipes.`);
      const recipes = cacheSnapshot.docs.map((doc) => doc.data());
      return {success: true, data: {recipes: recipes}};
    }
    logger.info(`Cache MISS: ${searchKey}`);
    logger.info("Generate recipes...");

    try {
      const prompt = `
        Tu es un assistant culinaire pour l'application FrigoZen.
        Ta mission est d'aider à réduire le gaspillage alimentaire.

        Voici l'inventaire de l'utilisateur (en JSON), qui inclut les lots
        d'articles et leurs dates de péremption :
        ${JSON.stringify(inventory)}

        Règles importantes :
        1. **Priorité absolue :** Propose des recettes qui utilisent les 
           articles dont la "earliestExpirationDate" est la plus proche.
        2. **Priorité secondaire :** Utilise au maximum les articles que 
           l'utilisateur possède déjà ("totalQuantity" > 0).
        3. **Recettes :** Propose 10 recettes simples et variées.

        Pour chaque recette, réponds OBLIGATOIREMENT et UNIQUEMENT 
        avec un objet JSON dans ce format :
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

      const result = await generativeModel.generateContent({
        contents: [{role: "user", parts: [{text: prompt}]}],
      });

      let jsonText =
        result.response.candidates?.[0].content.parts[0].text || "{}";
      jsonText = jsonText.replace(/```json/g, "").replace(/```/g, "").trim();

      logger.info("Gemini Response: ", jsonText);
      const jsonData = JSON.parse(jsonText);
      const recipesFromIA = (jsonData.recipes as any[]) || [];
      if (recipesFromIA.length === 0) {
        return {success: true, data: {recipes: []}};
      }
      logger.info("Recherche d'images sur Unsplash...");

      const imagePromises = recipesFromIA.map((recipe) => {
        const keywords = recipe.imageKeywords || recipe.title;
        return getImageUrlFromUnsplash(keywords);
      });
      const imageUrls = await Promise.all(imagePromises);
      const finalRecipes = recipesFromIA.map((recipe, index) => {
        return {
          ...recipe,
          imageUrl: imageUrls[index], // Ajout de l'URL (ou null)
        };
      });

      const batch = db.batch();
      for (const recipe of finalRecipes) {
        const newRecipeRef = recipesCollectionRef.doc();
        batch.set(newRecipeRef, recipe);
      }
      await batch.commit();
      return {success: true, data: {recipes: finalRecipes}};
    } catch (error) {
      logger.error("Error (generateRecipes):", error);
      throw new HttpsError(
        "internal",
        "Error during recipe generation.",
      );
    }
  },
);


initializeApp();
// LE NOM DE NOTRE SUJET. Il doit être identique dans Google Cloud.
const EXPIRATION_CHECK_TOPIC = "daily-expiration-check";

// ---------------------------------------------
// NOUVELLE FONCTION : LE SCANNEUR DE PÉREMPTION
// ---------------------------------------------
export const checkExpirations = onMessagePublished(
  EXPIRATION_CHECK_TOPIC,
  async (event) => {
    logger.info("Daily Expirations Scan... Starting.");

    const db = getFirestore();
    const messaging = getMessaging();
    const now = new Date();

    const tomorrow = new Date(now);
    tomorrow.setDate(now.getDate() + 1);

    // On calcule la date d'il y a 3 jours (pour les "périmés")
    const threeDaysAgo = new Date(now);
    threeDaysAgo.setDate(now.getDate() - 3);

    try {
      // all users
      const usersSnapshot = await db.collection("users").get();
      logger.info(`Scan ${usersSnapshot.size} users.`);

      for (const userDoc of usersSnapshot.docs) {
        const userId = userDoc.id;

        // 3. Trouver les articles qui expirent "demain" pour cet utilisateur
        // Nous cherchons les articles où la date la plus proche est :
        // > (Il y a 3 jours) ET < (Demain)
        const inventorySnapshot = await db
          .collection("users")
          .doc(userId)
          .collection("inventory")
          .where(
            "earliestExpirationDate",
            ">=",
            Timestamp.fromDate(threeDaysAgo)
          )
          .where(
            "earliestExpirationDate",
            "<=",
            Timestamp.fromDate(tomorrow)
          )
          .get();

        if (inventorySnapshot.empty) {
          continue; // Cet utilisateur n'a rien qui périme, on passe au suivant
        }

        // 4. On a trouvé des articles ! On prépare la notification.
        const expiringItems = inventorySnapshot.docs.map(
          (doc) => doc.data().name
        );
        const itemCount = expiringItems.length;
        const messageBody = (
          `🔔 ${itemCount} article(s) expire sooner` +
          `: ${expiringItems.join(", ")}`
        );

        logger.info(
          `Utilisateur ${userId} a ${itemCount} articles` +
          `expirant. Corps: ${messageBody}`
        );

        // 5. Récupérer les "tokens" (adresses) de cet utilisateur
        const tokensSnapshot = await db
          .collection("users")
          .doc(userId)
          .collection("deviceTokens")
          .get();
        if (tokensSnapshot.empty) {
          continue; // L'utilisateur n'a pas d'appareil enregistré
        }

        const tokens = tokensSnapshot.docs.map((doc) => doc.id);

        // 6. Construire le message FCM
        const message: MulticastMessage = {
          tokens: tokens,
          notification: {
            title: "🔔 Alert Anti-Gaspi FrigoZen",
            body: messageBody,
            // body: messageBody.length > 220 ?
            // `${messageBody.substring(0, 220)}...` : messageBody,
          },
          // "data" permet d'envoyer des infos à l'app si elle est ouverte
          data: {screen: "inventory"},
        };

        // 7. Envoyer la notification !
        const response = await messaging.sendEachForMulticast(message);
        if (response.failureCount > 0) {
          logger.warn(
            "Échec d'envoi de notification à "+
            `${response.failureCount} tokens.`
          );
          // Dans une V2, on pourrait ici supprimer les
          // tokens invalides de la DB
        }
      }
      logger.info("Daily Expirations Scan... Done");
      return null;
    } catch (error) {
      logger.error("Error (checkExpirations):", error);
      return null;
    }
  },
);
