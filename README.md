# CHOLOTO

A new Flutter project.

## Getting Started

FlutterFlow projects are built to run on the Flutter _stable_ release.

## Déployer sur Cloudflare Pages

Cette application est une application Flutter Web. Le dossier à publier est
`build/web` après le build, et non pas la racine du dépôt.

### Déploiement manuel

Depuis la racine du projet :

```bash
flutter pub get
flutter build web --release --base-href "/" \
  --dart-define=CHOLOTO_WEB_PUSH_VAPID_KEY=VOTRE_CLE_VAPID_PUBLIQUE
cp web/manifest.json build/web/
```

Dans Cloudflare Pages, envoyez ensuite le contenu de `build/web` avec Direct
Upload. Si le projet Pages est déjà créé, vous pouvez aussi utiliser :

```bash
npx wrangler pages deploy build/web --project-name NOM_DU_PROJET
```

### Déploiement automatique avec GitHub Actions

Le workflow `.github/workflows/deploy-cloudflare-pages.yml` construit Flutter
et publie automatiquement sur Cloudflare Pages à chaque push sur `main`. Ajoutez
ces secrets dans GitHub :

- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`
- `CLOUDFLARE_PAGES_PROJECT_NAME`
- `FIREBASE_WEB_PUSH_VAPID_KEY` (clé publique Web Push de Firebase)

Le token Cloudflare doit avoir les droits de déploiement Pages sur le compte.

Cloudflare Pages héberge le frontend. L’authentification, Firestore, Storage
et les Cloud Functions restent dans le projet Firebase `choloto-6aa5b` et
doivent être déployés séparément si leurs sources ont changé.
