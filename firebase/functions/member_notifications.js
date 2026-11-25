const {Timestamp} = require("firebase-admin/firestore");

const assistantReply = {
  fr: {title: "Réponse de CHOLOTO", body: "L’équipe CHOLOTO a répondu à votre message."},
  en: {title: "Reply from CHOLOTO", body: "The CHOLOTO team has replied to your message."},
  cr: {title: "Repons CHOLOTO", body: "Ekip CHOLOTO a reponn mesaj ou a."},
};

const accountActivated = {
  fr: {title: "Compte VIP activé", body: "Votre accès VIP CHOLOTO est actif."},
  en: {title: "VIP account activated", body: "Your CHOLOTO VIP access is active."},
  cr: {title: "Kont VIP ou aktive", body: "Ou gen aksè ak VIP CHOLOTO kounye a."},
};

function hasAccess(profile, at) {
  const end = profile.get("end_sub");
  if (!(end instanceof Timestamp) || end.toMillis() <= at.toMillis()) return false;
  // Signup can seed end_sub with the creation or onboarding time.
  const created = profile.get("created_time");
  const completed = profile.get("onboarding_completed_at");
  return !(created instanceof Timestamp && end.toMillis() <= created.toMillis()) &&
    !(completed instanceof Timestamp && end.isEqual(completed));
}

function matchesOwner(profile, userId) {
  const storedUid = profile.get("uid");
  return profile.exists && (storedUid === undefined || storedUid === userId);
}

function createMemberNotificationHandlers({send}) {
  async function onAccountActivated({before, after}, context) {
    const {userId} = context.params;
    if (!userId || !matchesOwner(after, userId)) return;
    if (!hasAccess(after, after.updateTime) || hasAccess(before, after.updateTime)) return;

    // An intervening cancellation or deletion supersedes a delayed event.
    const current = await after.ref.get();
    if (!matchesOwner(current, userId) || !hasAccess(current, current.readTime)) return;
    return send({
      userId,
      eventId: context.eventId,
      data: {type: "account_activated", route: "subscription"},
      messages: accountActivated,
    });
  }

  async function onAssistantReplyCreated(snapshot, context) {
    const {userId} = context.params;
    if (!userId || snapshot.get("sender_role") !== "admin") return;
    const conversation = await snapshot.ref.parent.parent.get();
    if (!conversation.exists || conversation.get("user_uid") !== userId) return;
    if (conversation.get("guest_access") === true || conversation.get("status") === "deleting") return;
    return send({
      userId,
      eventId: context.eventId,
      data: {type: "assistant_reply", route: "support"},
      messages: assistantReply,
    });
  }

  return {onAccountActivated, onAssistantReplyCreated};
}

module.exports = {createMemberNotificationHandlers};
