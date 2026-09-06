# Déploiement des règles de preuve de paiement

Déployé le 6 septembre 2026 à 02:42:47 UTC (5 septembre, 22:42 à Port-au-Prince), sur autorisation explicite de l’utilisateur.

- Projet : `choloto-6aa5b`.
- Cible exclusive : `firestore:rules`, release `cloud.firestore`.
- Source de départ : règles relues en production, ruleset `17f93750-abdb-4cd2-9302-9374c51d8992`.
- Ruleset publié et relu après déploiement : `35db70e8-6f8a-4911-b40e-d10595c106c8`.
- SHA-256 du fichier publié : `3ae94dbae8b1aeb51fc87bddf6f47f37be3ccf2ea23674d0b388efe2c339a2a0`.

Seul le bloc de 93 lignes lié à `payment_requests`, à sa preuve `evidence/image` et à ses fonctions de validation a été ajouté. Une comparaison après publication confirme que le retrait de ce bloc restitue exactement les octets du fichier précédemment en production. Les règles de connexion, profils, abonnements et paiements existants restent inchangées.

Les fichiers locaux comportent aussi des différences antérieures, notamment sur les annulations de paiement. Elles ont été exclues de ce déploiement : le fichier local complet n’a pas été publié.

## Validation du fichier exact publié

Un dossier isolé `/tmp/choloto-proof-deploy/firebase` a réuni les règles de production avec ce seul ajout et les suites de tests inchangées des deux dépôts. Sur `demo-choloto` :

```sh
firebase emulators:exec --only firestore,auth --project demo-choloto "node tests/firestore_rules_compatibility.mjs"
firebase emulators:exec --only firestore,auth --project demo-choloto "node tests/payment_transactions_rules.mjs"
```

Les deux commandes ont terminé avec le code 0. Elles incluent `payment_requests_rules.mjs` : profils actuels et historiques, lecture préalable des documents absents, envoi photo seule/message facultatif, confidentialité propriétaire/administrateur, refus anonyme/étranger, acceptation atomique avec paiement et renouvellement, refus et double validation. La première exécution de compatibilité avait réussi ses tests mais rencontré un timeout de la CLI après l’arrêt des émulateurs ; une nouvelle exécution complète a terminé normalement.

La production a été relue avant publication pour vérifier l’absence de changement concurrent. Le déploiement ciblé a réussi avec le code 0 ; la source publiée a ensuite été relue et comparée intégralement au fichier testé. Les avertissements du compilateur concernent la fonction préexistante `hasActiveVipAccess`, qui n’a pas été modifiée.

Aucun index, Storage, Hosting, Cloud Function ni client n’a été déployé. Aucun test ni document de test n’a été écrit en production.
