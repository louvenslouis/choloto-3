# Design system CHOLOTO

L’accueil de CHOLOTO reprend le relief d’une interface de jeu dans un thème exclusivement sombre. La médaille violette attire le regard vers l’abonnement VIP, les deux cartes dorées donnent accès aux tirages et à la Croix de la chance, et les panneaux saphir accueillent les contenus que l’on parcourt. Pour prolonger cette direction sur un autre écran, choisir d’abord ce que l’utilisateur doit pouvoir y faire, puis le composant et la matière qui expriment ce rôle.

## Couleurs et matières

Les valeurs ci-dessous servent de repères visuels. Dans Flutter, utiliser `FlutterFlowTheme.of(context)`, puis `theme.designToken` pour accéder aux matières, espacements, rayons et ombres. [Thème et tokens](../lib/flutter_flow/flutter_flow_theme.dart)

| Rôle | Traitement visuel | Référence Flutter |
| --- | --- | --- |
| Fond de page | Noir `#000000` dans l’application. Sur l’accueil, le bleu encre `#070C19` se fond dans le noir. Un arc saphir discret éclaire la zone des stories. | `theme.primaryBackground`, `background.homeGradient` |
| Surface de lecture | Gris `#1C1C1E` pour les surfaces courantes. Sur l’accueil, les raccourcis et les résultats partagent un dégradé saphir de `#1B2943` à `#0D1628`, un filet fin et un rayon de 16. | `theme.secondaryBackground`, `home.panel` |
| Marque et action principale | Jaune CHOLOTO `#EDB900`. Le texte et les icônes d’une action jaune sont noirs. L’onglet sélectionné reprend ce jaune sur Accueil, Tirages et Tchala. Sur VIP, il reprend le violet de l’abonnement. | `theme.primary`, `theme.onPrimary`, `home.amethystGlow` |
| Abonnement VIP | Améthyste texturée, médaille violette sertie d’or, titre ivoire et bouton jaune. Le violet identifie l’offre dès le premier regard. | `home.vipAmethyst`, `home.amethystGlow`, `vip.goldLight` |
| Tirages et Croix de la chance | Même or brossé, même titre noir. Les silhouettes du ticket et du X distinguent les deux destinations. Le token historique de ce fond doré s’appelle `membership`. | `home.membership`, `theme.onPrimary`, [texture or](../assets/images/home/brushed_gold.webp) |
| Texte sur saphir | Blanc pour les titres et bleu-gris `#B9C4D9` pour les dates, périodes et libellés secondaires. | `theme.primaryText`, `home.mutedText` |

Les titres utilisent **Google Sans Flex** à partir des styles `display`, `headline` et `title`. Les libellés et le texte courant utilisent **Inter** à partir des styles `label` et `body`. La graisse la plus forte revient aux titres des cartes et aux numéros. Sur téléphone, une date de tirage reste à 14 et un libellé de raccourci à 12. Employer le nom de la destination ou le verbe de l’action. Ajouter du texte explicatif uniquement sur demande.

Les dimensions sont exprimées en pixels logiques Flutter. L’échelle d’espacement est **4, 8, 16, 24, 32**. Les rayons sont **8, 16, 24** et `full` pour les cercles et pilules. Les cartes illustrées emploient le rayon 24. Les panneaux de lecture emploient le rayon 16. L’ombre des objets suit leur silhouette, ce qui préserve le relief sur une surface peu éclairée.

## En-têtes de page

Le dégradé vertical couvre toute la largeur de l’en-tête et s’efface au bas de celui-ci. Le saphir identifie les pages générales, l’améthyste les pages VIP et d’abonnement. Les titres, les illustrations et les commandes s’alignent sur les marges du contenu. Sur ordinateur, l’accueil intègre la marque et la navigation à son en-tête. [Fond partagé](../lib/flutter_flow/flutter_flow_theme.dart) · [Barre de titre](../lib/components/page_header_app_bar.dart)

## Composition de l’accueil

| | Téléphone | Grand écran |
| --- | --- | --- |
| En-tête | Logo et nom à gauche, Statistiques et Réglages réunis à droite. Navigation en bas. | Marque à gauche, navigation au centre et mêmes commandes à droite. |
| Stories et cartes | Bulles, carte VIP pleine largeur, puis **24** d’espace avant les deux cartes dorées côte à côte. | Bulles au-dessus de la grille. VIP à gauche, cartes dorées empilées à droite. Le bas de la Croix s’aligne sur le bas de la carte VIP. |
| Raccourcis et résultats | Les quatre raccourcis suivent les cartes. Un espace de **24** les sépare des derniers résultats. | Résultats sous la carte VIP et raccourcis en grille de deux sur deux sous les cartes dorées. |

La grille passe à deux colonnes dès que le contenu dispose de **656** de largeur au réglage de texte normal, soit 392 pour le VIP, 16 de gouttière et 248 pour les cartes dorées. Le contenu est centré et plafonné à **1 248**. Avec un texte agrandi, les cartes s’empilent et les raccourcis peuvent revenir sur deux lignes. La navigation conserve quatre destinations, **Accueil, Tirages, VIP et Tchala**. [Grille de l’accueil](../lib/components/home_feature_section.dart) · [Cadre de page](../lib/components/home_page_scaffold.dart) · [Navigation](../lib/main.dart)

## Composants et comportements

**Bulles de story.** Bingo et YouTube partagent un cercle de 72 et le même cadrage. Une story à découvrir a un anneau doré de 4, une story vue un anneau acier de 2. Le compteur apparaît à partir de deux contenus. Le chargement et l’action de réessai occupent chacun un emplacement de même taille. Une rangée vide disparaît. Cette direction artistique porte sur les bulles d’entrée. Le contenu et les interactions de chaque lecteur suivent leur propre interface. [Bulle](../lib/components/home_story_bubble.dart) · [Rangée](../lib/components/home_stories_rail.dart)

**Carte Abonnement VIP.** Le titre et le bouton occupent la gauche. La médaille peut dépasser légèrement du cadre à droite. Toute la carte ouvre l’espace VIP. Lorsque l’abonnement a expiré, un bandeau compact placé avant les stories donne accès au renouvellement. Sa surface saphir est entièrement activable. La médaille améthyste identifie le VIP et le lien doré invite au renouvellement. Avant l’échéance, le rappel en fenêtre reprend la matière améthyste du pass et le bouton jaune. Les cartes de suivi de l’abonnement et du paiement reprennent le panneau saphir des résultats. [Carte VIP](../lib/components/home_feature_section.dart) · [Bandeau de renouvellement](../lib/components/rappel_fin_abonnement_widget.dart)

**Cartes Derniers tirages et Croix de la chance.** Utiliser le même composant, les mêmes marges et la même matière pour les deux entrées. Le ticket est incliné. Le X remplit davantage son cadre carré, il est donc affiché à **92 %** de l’échelle du ticket pour donner aux deux illustrations un poids visuel comparable. Sur un petit écran, les titres peuvent passer sur deux lignes. [Carte et relief des illustrations](../lib/components/home_feature_card.dart)

**Raccourcis 3D.** Chaque destination associe un objet détouré et un libellé court. Les objets partagent une ligne de base dans un seul panneau saphir. Conserver leur ordre et leurs proportions. Saints mène directement au calendrier des saints de Tchala. [Composant des raccourcis](../lib/components/home_shortcuts.dart) · [Destinations](../lib/autres/home/home_widget.dart)

| YouTube | Saints | Tchala | Historique VIP |
| :---: | :---: | :---: | :---: |
| <img src="../assets/images/home/shortcut_video.webp" width="64" alt="Bouton de lecture rouge en relief"> | <img src="../assets/images/home/shortcut_saints.webp" width="64" alt="Calendrier ivoire et or"> | <img src="../assets/images/home/shortcut_tchala.webp" width="64" alt="Livre vert à fermoir doré"> | <img src="../assets/images/home/shortcut_history.webp" width="64" alt="Montre à gousset violette et or"> |

**Derniers résultats.** New York et Floride partagent un panneau avec un séparateur fin. Chaque ligne présente le logo du marché, son nom, la période, la date et les numéros sur des jetons dorés. L’en-tête réunit le titre, l’actualisation et l’accès à tous les tirages. Les lignes utilisent les mêmes marges à gauche et à droite. Si la largeur manque, les jetons passent sous le nom du marché. Le chargement, l’absence de résultat et l’indisponibilité s’affichent dans la ligne concernée. [Panneau des résultats](../lib/components/tirages_home_widget.dart)

**Assistance.** Le bouton circulaire flotte en bas à droite, au-dessus de la navigation mobile. Sa cible mesure 48. Une pastille rouge apparaît pour les messages d’assistance en attente, avec un affichage plafonné à `99+`. Le lecteur d’écran reçoit le nombre réel. [Bouton et pastille](../lib/components/home_header_actions.dart) · [Disposition des résultats](../lib/components/tirages_home_widget.dart)

## Paramètres

Les préférences, le compte et l’aide utilisent les panneaux saphir et l’en-tête partagé. Les sections s’empilent sur téléphone. Sur grand écran, les préférences occupent la colonne de gauche. Chaque réglage affiche sa valeur actuelle et une coche identifie le choix actif dans le sélecteur.

Les préférences sont propres à l’appareil. Le marché choisi apparaît en premier dans les derniers résultats de l’accueil. New York et la Floride restent tous deux visibles. Les tailles de lecture « Grand » et « Très grand » appliquent un minimum de 120 % et 140 % tout en respectant un agrandissement système supérieur. Les animations peuvent également suivre l’appareil ou être réduites dans l’application. [Paramètres](../lib/settings/parametres/parametres_widget.dart) · [Préférences locales](../lib/settings/device_preferences.dart)

Dans Compte, le téléphone et la date de naissance sont modifiables depuis les paramètres et le profil. Les membres peuvent choisir les cinq types de notifications Web pour leurs navigateurs inscrits. Le commutateur du navigateur contrôle la réception sur cet appareil. Un visiteur sans compte peut s’inscrire aux alertes BINGO.

## Page Tirages

L’en-tête saphir réunit le titre et le bouton d’actualisation à gauche. Chaque date ouvre un panneau de lecture. À gauche du résultat figurent le logo du marché, son nom et la période. À droite, les numéros reprennent le même jeton que sur l’accueil. Les logos à lettrage foncé disposent d’un fond clair pour rester lisibles sur le saphir.

L’historique se lit de haut en bas sur téléphone. Sur grand écran, les résultats d’une journée occupent deux colonnes et se lisent de gauche à droite. Un texte agrandi peut ramener la grille à une colonne et faire passer les jetons sous le nom du marché. L’onglet Tirages reprend la navigation basse ou l’en-tête horizontal de l’accueil selon la largeur. [Page Tirages](../lib/tirages/tirages/tirages_widget.dart) · [Ligne de résultat](../lib/tirages/tirages/tirage_result_row.dart) · [Jeton partagé](../lib/components/draw_result_chip.dart)

## Page VIP

Le portrait cerclé d’or, le nom et la médaille d’ancienneté composent l’en-tête. Une rosace améthyste à larges mailles, bordée d’un double filet doré, entoure la médaille. Le nom du membre apparaît en premier. Le nom de son badge s’affiche juste en dessous en améthyste dès que le rang est connu. Les initiales remplacent une photo absente ou indisponible. Toucher le portrait ouvre le profil, toucher la médaille affiche le rang et les jours VIP cumulés. Le fond de l’en-tête passe de l’améthyste en haut au transparent en bas. Sur téléphone, cet en-tête précède les prédictions. Sur grand écran, il prend place à leur gauche. [En-tête VIP](../lib/components/vip_page_header.dart) · [Médaille du membre](../lib/accomplissements/member_vip_badge.dart)

Deux boutons flottent au bas de la page VIP, au-dessus de la navigation mobile. À gauche, une montre à gousset accompagne « Historique ». À droite, une tasse et des pièces accompagnent « Pourboire ». Si le texte agrandi manque de place, chaque illustration conserve son libellé accessible. [Boutons flottants VIP](../lib/components/vip_floating_actions.dart)

La typographie de la page et de l’historique partage les rôles de `vip.typography`. Google Sans Flex donne aux noms de membre et aux titres de page leur largeur naturelle. Pour les prédictions, la même police utilise des chiffres tabulaires et un dessin plus étroit. Une valeur courte et isolée peut ainsi être plus grande, et chaque chiffre d’une série garde la même avance, y compris le zéro initial. Dans un mariage, le signe de liaison a une graisse plus légère que les deux nombres. Les sept cartes illustrées inscrivent leur titre en lettres grasses, resserrées et inclinées, sur un ruban améthyste bordé d’or. Le ruban part du bord gauche et s’ajuste au nom, même sur plusieurs lignes. Les marchés et les commandes utilisent Inter semi-gras. [Rôles typographiques](../lib/flutter_flow/flutter_flow_theme.dart)

Les sept cartes illustrées placent les valeurs en haut à gauche et le nom de la rubrique en bas à gauche. À droite, une couronne, une sphère de cristal, un boulier, des alliances, trois gemmes, un trèfle et un coffre étoilé identifient les rubriques. Chaque objet garde ses proportions, même dans une carte étroite ou très haute. La couleur de l’illustration prolonge le fond améthyste jusque sous les valeurs et teinte le reflet du ruban. Un voile ajusté aux chiffres assure leur contraste. Cinq fines courbes gravées s’effacent avant l’objet. Un liseré lumineux souligne le pan coupé en haut à droite. De courts filets améthyste séparent les numéros côte à côte. Dans Favori et Soutni, le filet est horizontal entre les marchés et avant les éventuels numéros sans marché.

Favori et Soutni occupent la première rangée. Chacune aligne les marchés à gauche et les numéros correspondants à droite. Une valeur trop longue passe sous son propre marché. Boloto et Mariage suivent. Chaque mariage occupe une ligne. Les deux nombres et leur signe de liaison s’alignent en trois colonnes lorsque la largeur le permet. Les autres séries se lisent de gauche à droite dans des colonnes régulières. Les sélections longues disposent d’une ligne entière. Sur téléphone, Extra prend toute la dernière rangée. Sur grand écran, 3 chiffres, 4 chiffres et Extra partagent une rangée. En très faible largeur ou avec du texte agrandi, les rubriques passent sur une colonne. [Cartes de prédiction](../lib/components/vip_prediction_panel.dart)

L’offre mensuelle prend la forme d’un billet améthyste avec des encoches et un cachet doré autour de la durée. Il regroupe les tarifs, le bouton « Devenir VIP » et l’assistance. Une carte saphir distincte compare les accès gratuits et VIP. [Offre mensuelle](../lib/settings/devenir_v_i_p/devenir_v_i_p_widget.dart)

Dans la carte Bingo dépliée du VIP, les résultats défilent dans les mêmes tuiles saphir que les détails du calendrier Bingo. Le jeton doré précède le marché, le lot et la période. Le lecteur de stories conserve ses propres cartes.

Dans la story BINGO, les cinq boules occupent le fond de l’affiche. Le billet noir à tranche dorée est détouré pour défiler indépendamment. Son numéro en Google Sans Flex utilise des chiffres tabulaires, une face ivoire-or et une ombre en relief. Numéro, lot et marché tiennent côte à côte si leur largeur mesurée le permet. Sinon le résultat occupe la largeur du billet et les détails passent en dessous. Les zéros et caractères de liaison du tirage sont conservés. Le compteur apparaît à partir de deux résultats. [Billet adaptatif](../lib/autres/bingo/stackbingo/bingo_story_result_ticket.dart)

## Accomplissements et assistance

Dans Accomplissements, la série de jours, les statistiques et les badges utilisent le panneau saphir des résultats. Le compteur de jours et la progression reprennent l’or CHOLOTO. L’illustration du trophée et les illustrations de badges gardent leur place. Après les badges de 3, 7, 14 et 30 jours, chaque nouveau seuil triple (90, 270, 810…). La collection expose les paliers gagnés et le prochain à atteindre. Le record conserve les badges après une interruption, tandis que la série en cours détermine les jours restants.

L’assistant guidé et la carte de contact du suivi d’abonnement reprennent le panneau saphir. La sélection d’une réponse utilise la même ligne à coche que les préférences. L’action de contact du suivi d’abonnement est dorée.

## Page Croix de la chance

Le fond de l’affiche reprend le jaune CHOLOTO et le grain du métal brossé. Le titre et la date complète sont imprimés en noir, dans l’axe du X doré de l’accueil. Les huit nombres blancs se lisent sur des médaillons anthracite. Toucher le X lance une onde qui secoue brièvement chaque médaillon à son passage. Les cases vides gardent leur place. L’affiche reste immobile lorsque la réduction des animations est activée et dans le JPEG partagé. Le bouton jaune « Partager le visuel » exporte l’affiche en JPEG. Une bande sombre au bas de l’image partagée porte la signature « app.choloto.com ». [Affiche de la Croix](../lib/components/cross_widget.dart) · [Matière de la carte](../lib/components/cross_poster_surface.dart)

## Page YouTube

L’en-tête saphir réunit la flèche de retour et le titre YouTube. Sur téléphone, la première vidéo dispose d’une grande vignette et les suivantes se lisent en lignes compactes. La grille passe à deux puis trois colonnes selon la largeur disponible et la taille du texte. Les vignettes gardent un format 16:9. [Page YouTube](../lib/youtube/youtube_widget.dart)

## Page Tchala

Le livre vert du raccourci de l’accueil identifie les symboles. Le calendrier ivoire et or identifie les saints. Les deux illustrations occupent la droite du même en-tête dégradé que sur Tirages. La sélection des onglets reprend le jaune de la navigation. Chaque symbole associe ses noms aux jetons dorés utilisés pour les résultats. Les jetons reviennent à la ligne quand l’espace manque. [Bandeau partagé](../lib/components/illustrated_page_header.dart) · [Page Tchala](../lib/tchala/tchala_widget.dart)

Le calendrier donne la priorité à la célébration du jour, ou à la prochaine date répertoriée. L’agenda regroupe les saints fêtés le même jour et permet de changer de mois. Sur téléphone, choisir un autre mois donne directement accès à sa liste. Sur grand écran, les prochaines fêtes et l’agenda mensuel se lisent côte à côte. Une recherche par nom ou par date porte sur toute l’année. [Calendrier des saints](../lib/tchala/saints_calendar.dart) · [Choix des dates et sources](saints-calendar.md)

## Mouvement et accessibilité

- **À l’entrée**, un reflet traverse une fois l’améthyste pendant que la médaille se pose. Un mouvement du pointeur incline légèrement la carte VIP. Sur une story à découvrir, seul le reflet de l’anneau se déplace.
- **À l’appui**, l’objet d’un raccourci se comprime brièvement. Le libellé et la zone tactile restent en place. Pour une commande à icône, reprendre le focus visible, l’infobulle localisée et la cible de 48 des commandes d’en-tête.
- **À l’arrivée d’un nouveau tirage**, les jetons du marché concerné basculent puis se posent. Le premier affichage est stable. Respecter le réglage système de réduction des animations et conserver la lisibilité de chaque état à l’arrêt.

## Réutilisation et vérification

Pour ajouter un accès rapide à une fonctionnalité, partir d’un raccourci existant. Pour ajouter un contenu à consulter, partir du panneau de résultats. Pour une action dans un formulaire ou un dialogue, reprendre les composants et les surfaces de ce parcours. Les textures et les grandes illustrations ont leur place sur les cartes de mise en avant. [Composants Flutter](../lib/components/) · [Illustrations de l’accueil](../assets/images/home/)

Avant de valider une évolution, vérifier l’accueil à 320 et 390 de large, le passage en deux colonnes sur tablette et le rendu Web à 1 440. Essayer le texte agrandi, les trois langues (français, anglais, créole haïtien), la réduction des animations et les deux apparences du système. Le rendu de l’app reste sombre. Vérifier le contraste du texte sur la matière réelle, le focus et l’accès à la dernière commande près du bouton d’assistance.

Exécuter `flutter test test/theme_test.dart test/home_presentation_test.dart`, les tests du composant modifié, puis `flutter analyze`. Lorsqu’un choix visuel partagé évolue, mettre à jour ensemble le thème ou le composant, son test et cette référence. [Tests du thème et des contrastes](../test/theme_test.dart) · [Tests de présentation de l’accueil](../test/home_presentation_test.dart) · [Consignes du dépôt](../AGENTS.md)
