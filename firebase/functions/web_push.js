const {setTimeout: delay} = require("node:timers/promises");

const invalidTokens = new Set([
  "messaging/invalid-registration-token",
  "messaging/registration-token-not-registered",
]);
const temporaryErrors = new Set(["messaging/server-unavailable", "messaging/internal-error"]);

function webPushMessage({eventId, data, messages, ttlSeconds = 86400}, locale, recipientUid) {
  return {
    data: {...data, eventId, locale, ...messages[locale], ...(recipientUid && {recipientUid})},
    webpush: {headers: {TTL: String(ttlSeconds), Urgency: "high"}},
  };
}

async function removeInvalidRegistration(document) {
  try {
    await document.ref.delete({lastUpdateTime: document.updateTime});
  } catch (error) {
    // Another delivery or the browser already deleted or refreshed this entry.
    if (error.code !== 5 && error.code !== 9) throw error;
  }
}

function createWebPushSender({firestore, messaging, logger}) {
  async function deliver(query, notification, recipientUid) {
    const {eventId, data, messages} = notification;
    const snapshot = await query.get();
    const byToken = new Map();
    for (const document of snapshot.docs) {
      const token = document.get("token");
      if (typeof token !== "string" || !token.trim()) continue;
      if (recipientUid && document.get("userId") !== recipientUid) continue;
      const entry = byToken.get(token);
      if (entry) {
        entry.documents.push(document);
      } else {
        const storedLocale = document.get("locale");
        const locale = Object.hasOwn(messages, storedLocale) ? storedLocale : "fr";
        byToken.set(token, {token, locale, documents: [document]});
      }
    }

    let sent = 0;
    const failures = {};
    for (const locale of Object.keys(messages)) {
      const entries = [...byToken.values()].filter((entry) => entry.locale === locale);
      const payload = webPushMessage(notification, locale, recipientUid);
      for (let i = 0; i < entries.length; i += 500) {
        let batch = entries.slice(i, i + 500);
        for (let attempt = 0; batch.length; attempt++) {
          const result = await messaging.sendEachForMulticast({
            ...payload, tokens: batch.map((entry) => entry.token),
          });
          const retry = [];
          const invalid = [];
          result.responses.forEach(({success, error}, index) => {
            const entry = batch[index];
            if (success) {
              sent++;
            } else if (attempt === 0 && temporaryErrors.has(error.code)) {
              retry.push(entry);
            } else {
              failures[error.code] = (failures[error.code] || 0) + 1;
              if (invalidTokens.has(error.code)) invalid.push(...entry.documents);
            }
          });
          await Promise.all(invalid.map(removeInvalidRegistration));
          batch = retry;
          if (batch.length) await delay(1000);
        }
      }
    }

    logger.info("Web push delivery", {type: data.type, eventId, sent, failures});
  }

  return {
    sendToSubscribers: (notification) =>
      deliver(firestore.collectionGroup("webPushTokens"), notification),
    sendToUser: (notification) => {
      const {userId} = notification;
      if (typeof userId !== "string" || !userId || userId.includes("/")) {
        throw new Error("A member notification requires a single recipient UID");
      }
      const devices = firestore.collection("user").doc(userId).collection("webPushTokens");
      return deliver(devices, notification, userId);
    },
  };
}

module.exports = {createWebPushSender, webPushMessage};
