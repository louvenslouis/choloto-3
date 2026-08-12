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

/**
 * Announces a new prediction without including any VIP-only numbers in the
 * lock-screen payload. Access to the prediction is still enforced by
 * Firestore when the user opens the app.
 */
exports.onPredictionCreated = functions
  .region("northamerica-northeast1")
  .firestore.document("prediction/{predictionId}")
  .onCreate(async (_snapshot, context) => {
    const messageId = await admin.messaging().send({
      topic: "new_predictions",
      notification: {
        title: "Nouvelle prédiction disponible",
        body: "Touchez pour consulter la nouvelle prédiction VIP.",
      },
      data: {
        type: "new_prediction",
        route: "vip",
        predictionId: context.params.predictionId,
      },
      android: {
        priority: "high",
        notification: {
          channelId: "choloto_predictions",
          icon: "ic_stat_prediction",
          color: "#EDB900",
          sound: "default",
        },
      },
      apns: {
        headers: {
          "apns-priority": "10",
        },
        payload: {
          aps: {
            badge: 1,
            sound: "default",
          },
        },
      },
    });

    functions.logger.info("Prediction push sent", {
      predictionId: context.params.predictionId,
      messageId,
    });
  });
