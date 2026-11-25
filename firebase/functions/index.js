const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const {createUserProfileHandler} = require("./user_profile");

exports.onAuthUserCreated = functions
  .region("northamerica-northeast1")
  .runWith({failurePolicy: true})
  .auth.user()
  .onCreate(createUserProfileHandler({
    auth: admin.auth(),
    firestore: admin.firestore(),
  }));

exports.onUserDeleted = functions
  .region("northamerica-northeast1")
  .auth.user()
  .onDelete(async (user) => {
    let firestore = admin.firestore();
    let userRef = firestore.doc("user/" + user.uid);
  });

const {createWebPushSender} = require("./web_push");
const {createPublicationHandlers} = require("./publication_notifications");
const {createMemberNotificationHandlers} = require("./member_notifications");
const {createGuestBingoPush} = require("./guest_bingo_push");

const sender = createWebPushSender({
  firestore: admin.firestore(),
  messaging: admin.messaging(),
  logger: functions.logger,
});
const guestBingo = createGuestBingoPush({
  messaging: admin.messaging(),
  sendToSubscribers: sender.sendToSubscribers,
});
const publications = createPublicationHandlers(sender.sendToSubscribers, guestBingo.sendBingoToAll);
const member = createMemberNotificationHandlers({send: sender.sendToUser});
const notifications = functions.region("northamerica-northeast1")
  .runWith({memory: "256MB", timeoutSeconds: 120}).firestore;

exports.registerGuestBingoPush = functions.region("northamerica-northeast1")
  .runWith({memory: "256MB", timeoutSeconds: 30, maxInstances: 3})
  .https.onCall(guestBingo.register);

exports.onPredictionCreated = notifications.document("prediction/{predictionId}")
  .onCreate(publications.onPredictionCreated);
exports.onCroixCreated = notifications.document("croix/{croixId}")
  .onCreate(publications.onCroixCreated);
exports.onBingoCreated = notifications.document("bingo/{bingoId}")
  .onCreate(publications.onBingoCreated);
exports.onAssistantReplyCreated = notifications
  .document("support_conversations/{userId}/messages/{messageId}")
  .onCreate(member.onAssistantReplyCreated);
exports.onAccountActivated = notifications.document("user/{userId}")
  .onUpdate(member.onAccountActivated);
