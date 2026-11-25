/* global firebase */

const appBaseUrl = new URL('../', self.registration.scope);
const destinations = new Map([
  ['new_prediction', 'vip'],
  ['new_croix', 'croix'],
  ['new_bingo', 'home'],
  ['assistant_reply', 'customerservice'],
  ['account_activated', 'upgrade'],
]);

// Firebase Auth 11.7.0 persists the default FlutterFire Web session here.
// Its worker-side auth listener can still report the previous user immediately
// after sign-out in a tab. Read the committed session for every private event.
function currentMemberUid() {
  return new Promise((resolve) => {
    const open = self.indexedDB.open('firebaseLocalStorageDb');
    open.onupgradeneeded = () => open.transaction.abort();
    open.onerror = () => resolve(null);
    open.onsuccess = () => {
      const db = open.result;
      try {
        const app = firebase.app();
        const key = `firebase:authUser:${app.options.apiKey}:${app.name}`;
        const store = db.transaction('firebaseLocalStorage').objectStore('firebaseLocalStorage');
        const read = store.get(key);
        read.onsuccess = () => {
          const session = read.result?.value;
          resolve(session?.isAnonymous === false ? session.uid : null);
        };
        read.onerror = () => resolve(null);
      } catch {
        resolve(null);
      } finally {
        db.close();
      }
    };
  }).catch(() => null);
}

async function targetFor(data) {
  const path = destinations.get(data?.type);
  if (!path) return null;
  const url = new URL(path, appBaseUrl);
  if (data.type === 'new_bingo') {
    if (typeof data.bingoId !== 'string' || !data.bingoId.trim() || data.bingoId.includes('/')) {
      return null;
    }
    url.searchParams.set('bingoId', data.bingoId);
  }
  if (data.type === 'assistant_reply' || data.type === 'account_activated') {
    if (typeof data.recipientUid !== 'string' || !data.recipientUid) return null;
    if (await currentMemberUid() !== data.recipientUid) return null;
  }
  return url.href;
}

// Keep the click handler before Firebase imports so it remains authoritative.
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  event.waitUntil((async () => {
    const data = event.notification.data;
    // The previous worker stored only the VIP URL in its notifications.
    const legacyVip = !data?.type && data?.url === new URL('vip', appBaseUrl).href;
    const targetUrl = legacyVip ? data.url : await targetFor(data);
    if (!targetUrl) return;
    const windows = await clients.matchAll({type: 'window', includeUncontrolled: true});
    const existing = windows.find((client) => client.url.startsWith(appBaseUrl.href));
    if (existing) {
      const navigated = await existing.navigate(targetUrl);
      if (navigated) return navigated.focus();
    }
    return clients.openWindow(targetUrl);
  })());
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

const predictionMessages = {
  fr: {
    title: 'Nouvelle prédiction disponible',
    body: 'Touchez pour consulter la nouvelle prédiction VIP.',
  },
  en: {
    title: 'New prediction available',
    body: 'Tap to view the new VIP prediction.',
  },
  cr: {
    title: 'Nouvo prediksyon disponib',
    body: 'Peze pou w gade nouvo prediksyon VIP la.',
  },
};

messaging.onBackgroundMessage(async ({data}) => {
  if (!await targetFor(data)) return;
  const prediction = data.type === 'new_prediction';
  const fallback = prediction
    ? predictionMessages[data.locale] ?? predictionMessages.fr
    : {};
  const title = data.title || fallback.title;
  if (!title) return;
  const iconUrl = new URL('icons/Icon-192.png', appBaseUrl).href;
  return self.registration.showNotification(title, {
    body: data.body || fallback.body,
    icon: iconUrl,
    badge: iconUrl,
    tag: prediction
      ? `prediction-${data.predictionId ?? data.eventId ?? 'latest'}`
      : `${data.type}-${data.eventId ?? data.croixId ?? data.bingoId ?? 'latest'}`,
    data: {type: data.type, recipientUid: data.recipientUid, bingoId: data.bingoId},
  });
});
