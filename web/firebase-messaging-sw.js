/* global firebase */

// Keep the click handler before Firebase imports so it remains authoritative.
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const targetUrl =
    event.notification.data?.url ?? new URL('../vip', self.registration.scope).href;

  event.waitUntil(
    clients
      .matchAll({type: 'window', includeUncontrolled: true})
      .then(async (windowClients) => {
        const appBaseUrl = new URL('../', self.registration.scope).href;
        const existingClient = windowClients.find((client) =>
          client.url.startsWith(appBaseUrl),
        );
        if (existingClient) {
          await existingClient.navigate(targetUrl);
          return existingClient.focus();
        }
        return clients.openWindow(targetUrl);
      }),
  );
});

importScripts('https://www.gstatic.com/firebasejs/11.7.0/firebase-app-compat.js');
importScripts(
  'https://www.gstatic.com/firebasejs/11.7.0/firebase-messaging-compat.js',
);

firebase.initializeApp({
  apiKey: 'AIzaSyBljhPBH4sMSQXVJMSP-qRadQTiwrC4BRg',
  authDomain: 'choloto-6aa5b.firebaseapp.com',
  projectId: 'choloto-6aa5b',
  storageBucket: 'choloto-6aa5b.firebasestorage.app',
  messagingSenderId: '934080509989',
  appId: '1:934080509989:web:3c903c43f4894c904f27cc',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((message) => {
  if (message.data?.type !== 'new_prediction') {
    return;
  }

  const targetUrl = new URL('../vip', self.registration.scope).href;
  const iconUrl = new URL(
    '../icons/Icon-192.png',
    self.registration.scope,
  ).href;

  self.registration.showNotification(
    message.data.title ?? 'Nouvelle prédiction disponible',
    {
      body:
        message.data.body ??
        'Touchez pour consulter la nouvelle prédiction VIP.',
      icon: iconUrl,
      badge: iconUrl,
      tag: `prediction-${message.data.predictionId ?? 'latest'}`,
      data: {url: targetUrl},
    },
  );
});
