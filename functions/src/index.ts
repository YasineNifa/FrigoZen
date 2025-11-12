// On importe depuis "v2/https" (la nouvelle version)
import {onCall, HttpsError} from "firebase-functions/v2/https";
// Le logger s'importe comme ça en v2
import * as logger from "firebase-functions/logger";
import {ImageAnnotatorClient} from "@google-cloud/vision";

// Initialiser le client de l'IA (on le met ici, en dehors de la fonction)
// C'est une "bonne pratique" pour la performance (Cold Starts)
const visionClient = new ImageAnnotatorClient();


export const helloWorld = onCall(
  // La v2 n'a qu'UN SEUL paramètre : "request"
  (request) => {
    // 1. La garde de sécurité
    // L'authentification est maintenant dans "request.auth"
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Vous devez être connecté.",
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


export const processReceipt = onCall(
  // On s'attend à recevoir une donnée "imageBase64"
  async (request) => {
    // 1. Garde de sécurité (comme helloWorld)
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Vous devez être connecté.");
    }

    // 2. Récupérer l'image envoyée par Flutter
    // L'image sera une très longue chaîne de texte (Base64)
    const imageBase64 = request.data.imageBase64;
    if (!imageBase64) {
      throw new HttpsError("invalid-argument", "Aucune image fournie.");
    }

    logger.info("Réception d'une image, appel de l'API Vision...");

    try {
      // 3. Préparer la requête pour l'API Vision
      const [result] = await visionClient.textDetection({
        image: {
          content: imageBase64, // On envoie l'image en Base64
        },
      });

      // 4. Analyser la réponse
      const detections = result.textAnnotations;
      if (!detections || detections.length === 0) {
        throw new HttpsError("not-found", "Aucun texte détecté.");
      }

      // 5. LE "PARSING" (le plus important !)
      // Le premier résultat (detections[0]) est TOUT le texte en un bloc.
      const fullText = detections[0].description || "";

      // On sépare le bloc de texte en lignes individuelles
      const allLines = fullText.split("\n");

      // Pour ce MVP, nous renvoyons simplement *toutes les lignes*.
      // L'étape de validation se fera dans l'app Flutter.
      // Dans le futur, on pourrait filtrer ici pour enlever les lignes
      // qui ne contiennent pas de chiffres (prix), etc.
      logger.info(`Texte détecté, ${allLines.length} lignes trouvées.`);

      // 6. Renvoyer la liste des lignes à Flutter
      return {
        success: true,
        lines: allLines,
      };
    } catch (error) {
      logger.error("Erreur de l'API Vision:", error);
      throw new HttpsError(
        "internal",
        "Erreur lors de l'analyse de l'image.",
      );
    }
  },
);
