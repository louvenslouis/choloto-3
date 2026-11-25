const bingoMessages = {
  fr: {title: "Nouveau BINGO", body: "Consultez les résultats dans CHOLOTO."},
  en: {title: "New BINGO", body: "View the results in CHOLOTO."},
  cr: {title: "Nouvo BINGO", body: "Gade rezilta yo nan CHOLOTO."},
};

const croixMessages = {
  fr: {
    title: "Croix de la chance",
    body: "La nouvelle grille est disponible dans CHOLOTO.",
  },
  en: {
    title: "Lucky Cross",
    body: "The new grid is available in CHOLOTO.",
  },
  cr: {
    title: "Kwa Lachans",
    body: "Nouvo griy la disponib nan CHOLOTO.",
  },
};

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

function createPublicationHandlers(send, sendBingoToAll) {
  return {
    onBingoCreated: (snapshot, context) => {
      const {date, expiration} = snapshot.data();
      // Match the active stories displayed on the home screen.
      if (typeof date?.toMillis !== "function" || typeof expiration?.toMillis !== "function") return;
      const remainingSeconds = Math.floor((expiration.toMillis() - Date.now()) / 1000);
      if (remainingSeconds < 0) return;
      return sendBingoToAll({
        eventId: context.eventId,
        ttlSeconds: Math.min(86400, remainingSeconds),
        data: {type: "new_bingo", route: "bingo", bingoId: context.params.bingoId},
        messages: bingoMessages,
      });
    },
    onCroixCreated: (_snapshot, context) => send({
      eventId: context.eventId,
      data: {type: "new_croix", route: "croix", croixId: context.params.croixId},
      messages: croixMessages,
    }),
    onPredictionCreated: (_snapshot, context) => send({
      eventId: context.eventId,
      data: {type: "new_prediction", route: "vip", predictionId: context.params.predictionId},
      messages: predictionMessages,
    }),
  };
}

module.exports = {createPublicationHandlers};
