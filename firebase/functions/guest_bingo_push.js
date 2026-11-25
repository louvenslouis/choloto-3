const {HttpsError} = require("firebase-functions/v1/https");
const {webPushMessage} = require("./web_push");

const topics = new Map([
  ["fr", "guest_bingo_fr"],
  ["en", "guest_bingo_en"],
  ["cr", "guest_bingo_cr"],
]);

function createGuestBingoPush({messaging, sendToSubscribers}) {
  async function register(data) {
    const {locale, token} = data ?? {};
    if (!topics.has(locale) || typeof token !== "string" || token.length < 20 ||
        token.length > 4096 || /[^A-Za-z0-9_:-]/.test(token) || Object.keys(data).length !== 2) {
      throw new HttpsError("invalid-argument", "Invalid BINGO push registration.");
    }
    let failureCode;
    try {
      // FCM accepts repeated subscription of the same token to the same topic.
      const result = await messaging.subscribeToTopic(token, topics.get(locale));
      if (result.successCount === 1 && result.failureCount === 0) return {registered: true};
      failureCode = result.errors[0]?.error.code;
    } catch (error) {
      failureCode = error?.code;
    }
    if (failureCode === "messaging/invalid-registration-token" ||
        failureCode === "messaging/registration-token-not-registered" ||
        failureCode === "messaging/invalid-argument") {
      throw new HttpsError("invalid-argument", "Invalid BINGO push registration.");
    }
    throw new HttpsError("unavailable", "BINGO push registration is unavailable.");
  }

  async function sendBingoToAll(notification) {
    if (notification.data.type !== "new_bingo") throw new Error("Guest topics only receive BINGO.");
    const topicsToSend = Array.from(topics, ([locale, topic]) =>
      messaging.send({topic, ...webPushMessage(notification, locale)}));
    // Keep all independent sends alive if one language's FCM request fails.
    const results = await Promise.allSettled([sendToSubscribers(notification), ...topicsToSend]);
    const failed = results.find((result) => result.status === "rejected");
    if (failed) throw failed.reason;
  }

  return {register, sendBingoToAll};
}

module.exports = {createGuestBingoPush};
