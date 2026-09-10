# Déploiement Firestore limité aux notes vocales

Projet : `choloto-6aa5b`. Cible : `firestore:rules` uniquement.
Publication vérifiée : `2026-09-10T02:47:21.260590Z`.
Ruleset : `projects/choloto-6aa5b/rulesets/f10bd2b1-54c1-40f0-a10c-c69c1a3a8f08`.
SHA-256 du fichier testé et relu en production : `f3259afce0b12a2a55b418da32d134313576446304e0f5ca305c4da27a602ec5`.

Les règles publiées avant cette intervention ne contenaient pas les permissions des images préparées dans le fichier principal `firebase/firestore.rules`. Cette configuration conserve leur refus et ajoute uniquement les notes vocales, conformément à la demande de déploiement limité. Les profils, paiements, textes, accès VIP et autres contrats sont conservés.

Commande exécutée depuis ce dossier :

```sh
firebase deploy --only firestore:rules --project choloto-6aa5b --non-interactive
```

Validation reproductible depuis ce dossier :

```sh
firebase emulators:exec --only firestore,auth --project demo-choloto "node compatibility.mjs"
```

`compatibility.mjs` conserve la suite générale et ses contrôles vocaux. Six attentes des permissions images sont adaptées pour vérifier leur refus, comme dans les règles de production précédentes ; aucun test n’est supprimé.

Le déploiement s’est terminé avec succès et le ruleset actif a été relu via l’API Firebase Rules : son contenu est strictement identique à ce fichier. Les anciens avertissements de compilation de la fonction inutilisée `hasActiveVipAccess`, non modifiée, restent présents. Aucun déploiement de Functions, Storage, Hosting ou index n’a été effectué, et aucun document de test n’a été créé en production.
