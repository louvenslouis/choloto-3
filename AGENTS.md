# Instructions obligatoires pour tout agent IA — CHOLOTO

Ce fichier s'applique à l'intégralité de ce dépôt. Il doit être lu avant toute
analyse, modification, génération de code, migration ou déploiement.

## Principe non négociable : ne jamais casser une version publiée

CHOLOTO possède des versions Android, iOS et Web déjà utilisées en production.
Le backend Firebase est un contrat public pour ces clients. Une règle plus
stricte, un renommage de champ, un changement de chemin ou une modification de
séquence peut être techniquement correct pour le code actuel tout en bloquant
les applications déjà installées.

Avant de modifier Firebase, l'authentification, le schéma Firestore, la
navigation post-connexion, les Cloud Functions ou les notifications :

1. Reconstituer le flux complet réellement exécuté par le client, opération par
   opération et dans le bon ordre. Ne pas tester uniquement l'écriture finale.
2. Consulter `git log`, `git blame` et les anciennes implémentations pertinentes
   pour identifier les contrats des versions déjà publiées.
3. Préserver les anciens chemins, champs, types, droits et séquences tant qu'une
   migration explicite et testée ne permet pas de les retirer.
4. Ajouter un test de régression qui échoue avec l'ancien comportement fautif et
   passe avec le changement proposé.
5. Tester le client actuel, les formes de données historiques, les ressources
   absentes, les utilisateurs non authentifiés et les utilisateurs étrangers.
6. Ne jamais déployer un changement Firebase sans validation locale et sans
   autorisation explicite de l'utilisateur pour le déploiement concerné.

Une modification ne doit pas être considérée comme terminée si un de ces points
n'a pas été vérifié. En cas de doute sur un ancien contrat, conserver la
compatibilité et signaler le doute au lieu de supposer que les anciens clients
seront mis à jour.

## Contrat critique : connexion et document utilisateur

La collection s'appelle exactement `user` au singulier. Le document utilisateur
canonique est `/user/{uid}`, où `{uid}` est l'UID Firebase Authentication.

Le flux de première connexion, notamment avec Google, est :

1. Firebase Authentication authentifie l'utilisateur.
2. Le client lit `/user/{uid}` pour savoir si son profil existe.
3. Une absence de document doit être lisible par son propriétaire et produire
   un résultat « inexistant », jamais `permission-denied`.
4. Si le document est absent, le client crée `/user/{uid}`.
5. Le client peut ensuite compléter `end_sub`, `device` et d'autres champs.
6. La navigation vers l'accueil peut enfin avoir lieu.

Règles permanentes pour `/user/{uid}` :

- Déduire la propriété du chemin `userId == request.auth.uid`.
- Ne jamais exiger `resource.data.uid` pour autoriser la lecture d'un document
  susceptible de ne pas encore exister : `resource.data` n'existe pas dans ce
  cas.
- Accepter les documents historiques sans champ `uid`, mais refuser tout champ
  `uid` qui contredit l'UID du chemin.
- Un utilisateur ne peut jamais créer, lire, modifier ou supprimer le document
  d'un autre utilisateur. L'accès administrateur doit rester explicite.
- Ne jamais remplacer ce modèle par une lecture publique ou un large
  `allow write: if request.auth != null`.
- Toute modification de ce flux doit rester compatible avec les anciennes
  versions ou être précédée d'une migration backend indépendante du client.

Implémentations de référence :

- `lib/backend/backend.dart` : `maybeCreateUser`
- `lib/auth/firebase_auth/firebase_auth_manager.dart` :
  `_signInOrCreateAccount` et `signInWithGoogle`
- `lib/components/welcome_widget.dart` : complétion du profil et navigation
- `lib/backend/schema/user_record.dart` : schéma du document utilisateur
- `firebase/firestore.rules` : autorisations de production
- `firebase/tests/firestore_rules_compatibility.mjs` : contrats historiques

## Contrat visuel obligatoire : design system CHOLOTO

Toute nouvelle page, composant, modale, état vide, chargement ou message
d'erreur doit sembler appartenir à la même application. Avant de modifier une
interface, examiner la page concernée, les pages voisines et les composants
réutilisables dans `lib/components/`. Ne jamais inventer un second langage
visuel pour une fonctionnalité isolée.

La source de vérité est `lib/flutter_flow/flutter_flow_theme.dart`. Accéder au
thème avec `FlutterFlowTheme.of(context)` et aux tokens avec
`FlutterFlowTheme.of(context).designToken`. Ne pas dupliquer les tokens dans une
page et ne pas changer leurs valeurs globales pour résoudre un problème local.

### Couleurs et thèmes

- Couleur de marque principale : jaune CHOLOTO `#EDB900` (`theme.primary`).
- Texte ou icône posé sur le jaune : `theme.onPrimary`, actuellement noir.
- Thème sombre, utilisé par défaut : arrière-plan `#000000`, surfaces
  `#1C1C1E`, texte principal blanc.
- Thème clair : arrière-plan `#F7F7F7`, surfaces blanches, texte principal
  `#14181B`.
- Employer `primaryBackground` pour le fond des pages,
  `secondaryBackground` pour les cartes et surfaces, `primaryText` et
  `secondaryText` pour les textes, puis `success`, `warning`, `error` et `info`
  uniquement pour leur sens prévu.
- Ne pas ajouter de `Color(0x...)`, `Colors.white`, `Colors.black` ou autre
  couleur brute dans une nouvelle interface lorsque le thème fournit la valeur.
  Une exception visuelle intentionnelle doit être rare, justifiée dans le code
  et vérifiée dans les deux thèmes.
- Le thème clair/sombre est une fonctionnalité, pas une préférence de l'agent.
  Toute interface doit être lisible dans les deux modes. Ne pas supprimer le
  thème sombre par défaut ni la persistance de `FFAppState.lightThemeEnabled`.

### Typographie

- Utiliser les styles `display*`, `headline*` et `title*` du thème pour les
  titres ; ils reposent sur la police locale `Google sans flex`.
- Utiliser les styles `body*` et `label*` pour le contenu et les libellés ; ils
  reposent sur Inter.
- Partir d'un style du thème et employer `.override(...)` seulement pour une
  adaptation nécessaire. Ne pas construire de `TextStyle` arbitraire ni
  introduire une nouvelle police sans décision explicite de design.
- Respecter la hiérarchie existante : un seul titre principal clair par écran,
  titres de section cohérents, corps lisible et texte secondaire réellement
  secondaire. Ne pas réduire du texte important pour faire tenir une mise en
  page.

### Espacements, formes et profondeur

Les seuls pas d'espacement par défaut sont ceux de `designToken.spacing` :
`xs = 4`, `sm = 8`, `md = 16`, `lg = 24`, `xl = 32`. Les rayons standards sont
`sm = 8`, `md = 16`, `lg = 24` et `full` pour les éléments pilules ou
circulaires. Les ombres doivent venir de `designToken.shadow`.

- Préférer ces tokens aux valeurs magiques répétées.
- Conserver des alignements et marges réguliers entre pages comparables.
- Les cartes utilisent normalement `secondaryBackground` et un rayon du design
  system. Les boutons d'action principaux utilisent normalement `primary` et
  `onPrimary`.
- Réutiliser `FFButtonWidget`, `FlutterFlowIconButton` et les composants de
  `lib/components/` avant de créer une nouvelle variante.
- Ne pas multiplier bordures, dégradés, ombres fortes, animations ou formes si
  ces effets n'existent pas dans le parcours adjacent.

### Navigation, responsive, contenu et accessibilité

- Préserver la navigation principale à quatre destinations définie dans
  `lib/main.dart` : Accueil, Tirages, VIP et Tchala. Une nouvelle fonctionnalité
  ne doit pas modifier ce modèle sans demande explicite.
- Concevoir au minimum pour téléphone Android/iOS et Flutter Web. Éviter les
  largeurs fixes qui débordent ; tenir compte des zones sûres, du clavier, des
  petits écrans, des textes longs et des changements d'orientation pertinents.
- Tous les textes visibles doivent passer par `FFLocalizations` et rester
  disponibles en français, anglais et créole. Ne jamais intégrer une chaîne
  utilisateur uniquement en dur dans une nouvelle interface.
- Prévoir les états chargement, vide, erreur, hors connexion et désactivé sans
  casser la structure de la page. Une erreur technique brute ne doit pas être
  affichée à l'utilisateur.
- Conserver des zones tactiles confortables, un contraste lisible, des libellés
  compréhensibles et des icônes cohérentes avec Material ou Font Awesome déjà
  utilisés. Ne pas employer un emoji comme icône d'interface.
- Réutiliser les logos et médias officiels présents dans `assets/`, préserver
  leur ratio et ne pas recréer une identité CHOLOTO approximative.

### Validation obligatoire de toute modification d'interface

Avant de déclarer une interface terminée :

1. Comparer visuellement avec les écrans adjacents et confirmer la réutilisation
   des tokens et composants existants.
2. Vérifier au moins un petit viewport mobile et un viewport Web pertinent.
3. Vérifier les thèmes sombre et clair, y compris contraste, icônes, champs,
   cartes, dialogues et barre de navigation.
4. Vérifier les trois langues, particulièrement le débordement des libellés.
5. Exécuter `flutter test test/theme_test.dart`, les tests du composant modifié
   et `flutter analyze`.
6. Ajouter ou mettre à jour un test lorsque la modification touche un token,
   la persistance du thème, la navigation ou un comportement visuel critique.

Une capture d'un seul écran dans un seul thème ne suffit pas à valider le design
system. Si une demande exige réellement un nouveau style, modifier d'abord la
source de vérité et ses tests, puis appliquer ce changement de manière cohérente
au lieu de coder une exception locale.

## Incident à ne jamais réintroduire — 12 août 2026

Une règle de lecture de `/user/{uid}` utilisait `resource.data.uid`. Lors de la
première connexion, le document n'existait pas encore. Le `get()` préalable de
`maybeCreateUser` était donc refusé avant que le `set()` puisse être exécuté.
Google Auth réussissait, mais aucun profil n'était créé et l'utilisateur
n'atteignait pas l'accueil.

Le test antérieur créait directement le document et n'exécutait pas la lecture
préalable ; il était vert tout en laissant le vrai parcours cassé. Tout nouveau
test doit reproduire la séquence réelle, y compris les lectures, les documents
absents et les opérations intermédiaires.

## Validation obligatoire des règles Firestore

Pour chaque modification de `firebase/firestore.rules` ou d'un flux qui en
dépend :

1. Mettre à jour `firebase/tests/firestore_rules_compatibility.mjs` si nécessaire.
2. Depuis `firebase/`, exécuter exactement :

   ```bash
   firebase emulators:exec --only firestore,auth --project demo-choloto \
     "node tests/firestore_rules_compatibility.mjs"
   ```

3. Exécuter `git diff --check` et inspecter le diff complet.
4. Ne pas déployer si un test échoue, si l'émulateur n'a pas démarré ou si un
   scénario historique pertinent n'est pas couvert.

La suite de compatibilité doit au minimum vérifier :

- lecture par le propriétaire d'un `/user/{uid}` inexistant, attendue en 404 et
  non en 403 ;
- création et lecture du profil actuel avec un champ `uid` correct ;
- création, lecture et mise à jour d'un ancien profil sans champ `uid` ;
- refus d'un chemin appartenant à un autre UID, même si le payload usurpe `uid` ;
- refus des accès non authentifiés aux données privées ;
- maintien des autres contrats publics, VIP, administrateur et notifications.

Les tests Flutter pertinents et `flutter analyze` doivent également être lancés
quand le code Dart est modifié. Une validation Firestore seule ne valide pas la
navigation ni l'interface.

## Discipline de modification et de déploiement

- Préserver les changements locaux existants ; ne jamais écraser un fichier ou
  réinitialiser le dépôt pour simplifier une intervention.
- Faire le plus petit changement sûr. Ne pas mélanger durcissement de sécurité,
  migration de schéma et refonte du client dans une même modification.
- Pour durcir une permission utilisée par une version publiée, introduire
  d'abord un nouveau chemin sécurisé ou une Cloud Function, migrer les clients,
  observer l'adoption, puis retirer l'ancien contrat dans une intervention
  séparée et explicitement autorisée.
- Ne jamais déployer les Functions, index, Hosting ou Storage lorsque seule une
  règle Firestore doit changer. Limiter la cible du déploiement.
- Le projet Firebase de production est `choloto-6aa5b`. Ne jamais utiliser ce
  projet pour les tests ; employer le projet de démonstration et les émulateurs.
- Avant un déploiement, indiquer clairement les clients et opérations affectés.
  Après le déploiement, rapporter la cible exacte, le résultat et les tests
  réellement exécutés, sans présenter une supposition comme une validation.

## Critère de fin

Un changement sensible est prêt uniquement si l'agent peut expliquer :

- le contrat historique préservé ;
- le parcours complet testé ;
- les cas autorisés et refusés ;
- le test qui empêcherait la régression ;
- ce qui a été déployé, ou explicitement que rien n'a été déployé.

Si l'une de ces réponses manque, poursuivre l'analyse ou demander une décision
à l'utilisateur avant toute action de production.
