import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {ImageAnnotatorClient} from "@google-cloud/vision";
import {VertexAI} from "@google-cloud/vertexai";

// Initialiser le client de l'IA (on le met ici, en dehors de la fonction)
// C'est une "bonne pratique" pour la performance (Cold Starts)
const visionClient = new ImageAnnotatorClient();
const PROJECT_ID = "frigozen-app";
const LOCATION = "us-central1";
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
