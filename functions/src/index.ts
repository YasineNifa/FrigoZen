// On importe depuis "v2/https" (la nouvelle version)
import {onCall, HttpsError} from "firebase-functions/v2/https";
// Le logger s'importe comme ça en v2
import * as logger from "firebase-functions/logger";

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
