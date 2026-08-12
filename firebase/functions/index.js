const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.onUserDeleted = functions
  .region("northamerica-northeast1")
  .auth.user()
  .onDelete(async (user) => {
    let firestore = admin.firestore();
    let userRef = firestore.doc("user/" + user.uid);
  });

const invalidWebPushTokenCodes = new Set([
  "messaging/invalid-registration-token",
  "messaging/registration-token-not-registered",
]);

const predictionMessages = {
  fr: {
    title: "Nouvelle prédiction disponible",
    body: "Touchez pour consulter la nouvelle prédiction VIP.",
  },
  en: {
    title: "New prediction available",
    body: "Tap to view the new VIP prediction.",
  },
  cr: {
    title: "Nouvo prediksyon disponib",
    body: "Peze pou w gade nouvo prediksyon VIP la.",
  },
};

/** Announces a new prediction to browsers registered by the web app. */
exports.onPredictionCreated = functions
  .region("northamerica-northeast1")
  .runWith({memory: "256MB", timeoutSeconds: 120})
  .firestore.document("prediction/{predictionId}")
  .onCreate(async (_snapshot, context) => {
    const tokenSnapshot = await admin
      .firestore()
      .collectionGroup("webPushTokens")
      .get();
    const tokenEntriesByToken = new Map();
    tokenSnapshot.docs.forEach((document) => {
      const token = document.get("token");
      if (typeof token !== "string" || !token) {
        return;
      }
      const existingEntry = tokenEntriesByToken.get(token);
      const locale = predictionMessages[document.get("locale")]
        ? document.get("locale")
        : "fr";
      if (existingEntry) {
        existingEntry.documents.push(document);
      } else {
        tokenEntriesByToken.set(token, {
          token,
          locale,
          documents: [document],
        });
      }
    });
    const tokenEntries = [...tokenEntriesByToken.values()];

    if (tokenEntries.length === 0) {
      functions.logger.info("Prediction push skipped: no web subscribers", {
        predictionId: context.params.predictionId,
      });
      return;
    }

    let successCount = 0;
    let failureCount = 0;
    const invalidTokenDocuments = [];

    for (const [locale, localizedMessage] of Object.entries(
      predictionMessages,
    )) {
      const localizedEntries = tokenEntries.filter(
        (entry) => entry.locale === locale,
      );
      for (let index = 0; index < localizedEntries.length; index += 500) {
        const batch = localizedEntries.slice(index, index + 500);
        const response = await admin.messaging().sendEachForMulticast({
          tokens: batch.map((entry) => entry.token),
          data: {
            type: "new_prediction",
            route: "vip",
            predictionId: context.params.predictionId,
            locale,
            title: localizedMessage.title,
            body: localizedMessage.body,
          },
          webpush: {
            headers: {
              TTL: "86400",
              Urgency: "high",
            },
          },
        });

        successCount += response.successCount;
        failureCount += response.failureCount;
        response.responses.forEach((result, responseIndex) => {
          if (
            result.error &&
            invalidWebPushTokenCodes.has(result.error.code)
          ) {
            invalidTokenDocuments.push(
              ...batch[responseIndex].documents.map(
                (document) => document.ref,
              ),
            );
          }
        });
      }
    }

    await Promise.all(
      invalidTokenDocuments.map((document) => document.delete()),
    );

    functions.logger.info("Prediction push sent", {
      predictionId: context.params.predictionId,
      subscriberCount: tokenEntries.length,
      successCount,
      failureCount,
      removedInvalidTokens: invalidTokenDocuments.length,
    });
  });
