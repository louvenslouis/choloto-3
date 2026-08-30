import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleStorageKey = '__locale_key__';

class FFLocalizations {
  FFLocalizations(this.locale);

  final Locale locale;

  static FFLocalizations of(BuildContext context) =>
      Localizations.of<FFLocalizations>(context, FFLocalizations)!;

  static List<String> languages() => ['fr', 'en', 'cr'];

  static late SharedPreferences _prefs;
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();
  static Future storeLocale(String locale) =>
      _prefs.setString(_kLocaleStorageKey, locale);
  static Locale? getStoredLocale() {
    final locale = _prefs.getString(_kLocaleStorageKey);
    return locale != null && locale.isNotEmpty ? createLocale(locale) : null;
  }

  String get languageCode => locale.toString();
  String? get languageShortCode =>
      _languagesWithShortCode.contains(locale.toString())
          ? '${locale.toString()}_short'
          : null;
  int get languageIndex => languages().contains(languageCode)
      ? languages().indexOf(languageCode)
      : 0;

  String getText(String key) {
    final translations = kTranslationsMap[key];
    return translations?[locale.toString()] ?? translations?['fr'] ?? key;
  }

  String getVariableText({
    String? frText = '',
    String? enText = '',
    String? crText = '',
  }) =>
      [frText, enText, crText][languageIndex] ?? '';

  static const Set<String> _languagesWithShortCode = {
    'ar',
    'az',
    'ca',
    'cs',
    'da',
    'de',
    'dv',
    'en',
    'es',
    'et',
    'fi',
    'fr',
    'gr',
    'he',
    'hi',
    'hu',
    'it',
    'km',
    'ku',
    'mn',
    'ms',
    'no',
    'pt',
    'ro',
    'ru',
    'rw',
    'sv',
    'th',
    'uk',
    'vi',
  };
}

/// Used if the locale is not supported by GlobalMaterialLocalizations.
class FallbackMaterialLocalizationDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      SynchronousFuture<MaterialLocalizations>(
        const DefaultMaterialLocalizations(),
      );

  @override
  bool shouldReload(FallbackMaterialLocalizationDelegate old) => false;
}

/// Used if the locale is not supported by GlobalCupertinoLocalizations.
class FallbackCupertinoLocalizationDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture<CupertinoLocalizations>(
        const DefaultCupertinoLocalizations(),
      );

  @override
  bool shouldReload(FallbackCupertinoLocalizationDelegate old) => false;
}

class FFLocalizationsDelegate extends LocalizationsDelegate<FFLocalizations> {
  const FFLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<FFLocalizations> load(Locale locale) =>
      SynchronousFuture<FFLocalizations>(FFLocalizations(locale));

  @override
  bool shouldReload(FFLocalizationsDelegate old) => false;
}

Locale createLocale(String language) => language.contains('_')
    ? Locale.fromSubtags(
        languageCode: language.split('_').first,
        scriptCode: language.split('_').last,
      )
    : Locale(language);

bool _isSupportedLocale(Locale locale) {
  final language = locale.toString();
  return FFLocalizations.languages().contains(
    language.endsWith('_')
        ? language.substring(0, language.length - 1)
        : language,
  );
}

final kTranslationsMap = <Map<String, Map<String, String>>>[
  // Tirages
  {
    'hfwdp6xo': {
      'fr': 'Tirages',
      'cr': 'Tiraj',
      'en': 'Draws',
    },
    'nwse7gnu': {
      'fr': 'NEW YORK',
      'cr': 'NEW YORK',
      'en': 'NEW YORK',
    },
    '688llz6y': {
      'fr': 'Pick 3 officiel',
      'cr': 'Pick 3 ofisyèl',
      'en': 'Official Pick 3',
    },
    '16bznwfv': {
      'fr': 'Dernier tirage',
      'cr': 'Dènye tiraj',
      'en': 'Latest draw',
    },
    'xqa3sjic': {
      'fr': 'MIDDAY',
      'cr': 'MIDI',
      'en': 'MIDDAY',
    },
    '9hcsnfjs': {
      'fr': 'EVENING',
      'cr': 'ASWÈ',
      'en': 'EVENING',
    },
    'vho2s2ds': {
      'fr': 'FLORIDA',
      'cr': 'FLORIDA',
      'en': 'FLORIDA',
    },
    'jc5kkpyj': {
      'fr': 'Pick 2, Pick 3 et Pick 4 officiels',
      'cr': 'Pick 2, Pick 3 ak Pick 4 ofisyèl',
      'en': 'Official Pick 2, Pick 3 and Pick 4',
    },
    'mevtoovb': {
      'fr': 'PICK 2',
      'cr': 'PICK 2',
      'en': 'PICK 2',
    },
    'ccu2gg3x': {
      'fr': 'PICK 3',
      'cr': 'PICK 3',
      'en': 'PICK 3',
    },
    'ov51axfz': {
      'fr': 'PICK 4',
      'cr': 'PICK 4',
      'en': 'PICK 4',
    },
    'cd9jjqv4': {
      'fr': 'Sources: New York State Gaming Commission et Florida Lottery.',
      'cr': 'Sous: New York State Gaming Commission ak Florida Lottery.',
      'en': 'Sources: New York State Gaming Commission and Florida Lottery.',
    },
    'wakkucok': {
      'fr': 'Tirages',
      'cr': 'Tiraj',
      'en': 'Draws',
    },
  },
  // Tchala
  {
    'z0x7hmij': {
      'fr': 'tchala',
      'cr': 'Tchala',
      'en': 'Tchala',
    },
    '40q38tw9': {
      'fr': 'Tchala',
      'cr': 'Tchala',
      'en': 'Tchala',
    },
    'd4x9buzb': {
      'fr': 'Saints',
      'cr': 'Sen',
      'en': 'Saints',
    },
    '14smzvpm': {
      'fr': 'Tchala',
      'cr': 'Tchala',
      'en': 'Tchala',
    },
  },
  // Parametres
  {
    'ey6ffs78': {
      'fr': 'Profil',
      'cr': 'Pwofil',
      'en': 'Profile',
    },
    'eywbwq85': {
      'fr': 'Abonnement',
      'cr': 'Abònman',
      'en': 'Subscription',
    },
    '6ho9r1de': {
      'fr': 'Termes et Conditions',
      'cr': 'Tèm ak Kondisyon',
      'en': 'Terms and Conditions',
    },
    'i3ozq7ax': {
      'fr': 'Nous contacter',
      'cr': 'Kontakte nou',
      'en': 'Contact us',
    },
    '9w72tojm': {
      'fr': 'Langue',
      'cr': 'Lang',
      'en': 'Language',
    },
    '3vvyx19f': {
      'fr': 'Version',
      'cr': 'Vèsyon',
      'en': 'Version',
    },
    'cp8c72u7': {
      'fr': '260715001',
      'cr': '0.09.4',
      'en': '0.09.4',
    },
    '7yrcsutm': {
      'fr': 'Se déconnecter',
      'cr': 'Dekonekte',
      'en': 'Logout',
    },
    'f9ixk3ux': {
      'fr': 'Se connecter',
      'cr': 'Konekte',
      'en': 'Login',
    },
    'z4f6qhpj': {
      'fr': 'Développeur : LOUVENS LOUIS',
      'cr': 'Devlopè : LOUVENS LOUIS',
      'en': 'Developer: LOUVENS LOUIS',
    },
    'oadu0jrq': {
      'fr': 'Paramètres',
      'cr': 'Paramèt',
      'en': 'Settings',
    },
    'a0cq5umz': {
      'fr': 'Paramètres',
      'cr': 'Paramèt',
      'en': 'Settings',
    },
  },
  // Authentification
  {
    'bk9piqzq': {
      'fr': 'Accueil',
      'cr': 'Akèy',
      'en': 'Home',
    },
  },
  // croix
  {
    '63dg2p5g': {
      'fr': 'Croix de la Chance',
      'cr': 'Kwa Lachans',
      'en': 'Lucky Cross',
    },
    'croixsharetitle': {
      'fr': 'Partager la Croix de la Chance',
      'cr': 'Pataje Kwa Lachans',
      'en': 'Share the Lucky Cross',
    },
    'croixshareerror': {
      'fr': 'Impossible de partager la Croix de la Chance pour le moment.',
      'cr': 'Nou pa kapab pataje Kwa Lachans la kounye a.',
      'en': 'The Lucky Cross could not be shared right now.',
    },
    'croixsharedownload': {
      'fr':
          'Le visuel JPEG a été téléchargé. Vous pouvez maintenant le partager.',
      'cr': 'Imaj JPEG la telechaje. Kounye a ou ka pataje li.',
      'en': 'The JPEG was downloaded. You can now share it.',
    },
    'croixsharepreparing': {
      'fr': 'Le visuel se prépare. Réessayez dans un instant.',
      'cr': 'Imaj la ap prepare. Eseye ankò nan yon ti moman.',
      'en': 'The image is being prepared. Try again in a moment.',
    },
    '64uxl098': {
      'fr': 'Accueil',
      'cr': 'Akèy',
      'en': 'Home',
    },
  },
  // youtube
  {
    'ho2ij0yt': {
      'fr': 'YOUTUBE',
      'cr': 'YOUTUBE',
      'en': 'YOUTUBE',
    },
    'ytch4nel': {
      'fr': 'CHOLOTO sur YouTube',
      'cr': 'CHOLOTO sou YouTube',
      'en': 'CHOLOTO on YouTube',
    },
    'ytintr01': {
      'fr': 'Retrouve les dernières vidéos de la chaîne officielle.',
      'cr': 'Jwenn dènye videyo chanèl ofisyèl la.',
      'en': 'Catch up on the latest videos from the official channel.',
    },
    'ytchnbtn': {
      'fr': 'Voir la chaîne',
      'cr': 'Gade chanèl la',
      'en': 'View channel',
    },
    'ytlatest': {
      'fr': 'Dernières vidéos',
      'cr': 'Dènye videyo yo',
      'en': 'Latest videos',
    },
    'ytvidone': {
      'fr': 'vidéo',
      'cr': 'videyo',
      'en': 'video',
    },
    'ytvidmul': {
      'fr': 'vidéos',
      'cr': 'videyo',
      'en': 'videos',
    },
    'ytd7pub1': {
      'fr': 'Publié le',
      'cr': 'Pibliye',
      'en': 'Published',
    },
    'ytwatch1': {
      'fr': 'Regarder sur YouTube',
      'cr': 'Gade sou YouTube',
      'en': 'Watch on YouTube',
    },
    'ytnewest': {
      'fr': 'NOUVEAU',
      'cr': 'NOUVO',
      'en': 'NEW',
    },
    'youtube_story_label': {
      'fr': 'YouTube',
      'cr': 'YouTube',
      'en': 'YouTube',
    },
    'youtube_story_open': {
      'fr': 'Ouvrir les nouvelles vidéos CHOLOTO',
      'cr': 'Ouvri nouvo videyo CHOLOTO yo',
      'en': 'Open the new CHOLOTO videos',
    },
    'youtube_story_previous': {
      'fr': 'Vidéo précédente',
      'cr': 'Videyo anvan an',
      'en': 'Previous video',
    },
    'youtube_story_next': {
      'fr': 'Vidéo suivante',
      'cr': 'Videyo apre a',
      'en': 'Next video',
    },
    'youtube_story_close': {
      'fr': 'Fermer',
      'cr': 'Fèmen',
      'en': 'Close',
    },
    'youtube_story_thumbnail': {
      'fr': 'Miniature de la vidéo YouTube',
      'cr': 'Ti imaj videyo YouTube la',
      'en': 'YouTube video thumbnail',
    },
    'ytloading': {
      'fr': 'Chargement des vidéos…',
      'cr': 'Videyo yo ap chaje…',
      'en': 'Loading videos…',
    },
    'ytfallback': {
      'fr': 'Vidéo CHOLOTO 509',
      'cr': 'Videyo CHOLOTO 509',
      'en': 'CHOLOTO 509 video',
    },
    'yterrttl': {
      'fr': 'Impossible de charger les vidéos',
      'cr': 'Nou pa ka chaje videyo yo',
      'en': 'Unable to load videos',
    },
    'yterrdsc': {
      'fr': 'Vérifie ta connexion, puis réessaie.',
      'cr': 'Verifye koneksyon ou, epi eseye ankò.',
      'en': 'Check your connection, then try again.',
    },
    'ytretry1': {
      'fr': 'Réessayer',
      'cr': 'Eseye ankò',
      'en': 'Try again',
    },
    'ytemptyt': {
      'fr': 'Aucune vidéo disponible',
      'cr': 'Pa gen videyo disponib',
      'en': 'No videos available',
    },
    'ytemptyd': {
      'fr': 'Reviens bientôt pour découvrir les nouveautés.',
      'cr': 'Retounen byento pou wè sa ki nouvo.',
      'en': 'Come back soon to see what’s new.',
    },
    'ytrefrer': {
      'fr':
          'Actualisation impossible. Les dernières vidéos chargées restent affichées.',
      'cr': 'Nou pa ka aktyalize. Dènye videyo ki te chaje yo toujou la.',
      'en': 'Refresh failed. The last loaded videos are still displayed.',
    },
    'coytq3hn': {
      'fr': 'Home',
      'cr': 'Akèy',
      'en': 'Home',
    },
  },
  // conditions
  {
    'z4scavsi': {
      'fr': 'Termes et Conditions',
      'cr': 'Tèm ak Kondisyon',
      'en': 'Terms and Conditions',
    },
    'hy9gb3tc': {
      'fr': 'En-tête',
      'cr': 'Antèt',
      'en': 'Header',
    },
    'w4g3cm28': {
      'fr': 'Texte réduit',
      'cr': 'Tèks redui',
      'en': 'Collapsed body text',
    },
    'kpe3u5qv': {
      'fr': 'Texte développé',
      'cr': 'Tèks devlope',
      'en': 'Expanded body text',
    },
    'yai1k57w': {
      'fr': 'Home',
      'cr': 'Akèy',
      'en': 'Home',
    },
  },
  // profil
  {
    'c8eoezku': {
      'fr': 'Modifier',
      'cr': 'Modifye',
      'en': 'Edit',
    },
    'vkfordrl': {
      'fr': 'Modifier',
      'cr': 'Modifye',
      'en': 'Edit',
    },
    'xpn42xty': {
      'fr': 'Modifie ton Profil',
      'cr': 'Modifye pwofil ou',
      'en': 'Edit your profile',
    },
  },
  // customerservice
  {
    'xx4qds3f': {
      'fr': 'Contacter le service client',
      'cr': 'Kontakte sèvis kliyan',
      'en': 'Contact Customer Service',
    },
    'ujyy941k': {
      'fr':
          'Nous sommes là pour vous aider ! Envoyez-nous un message et nous vous répondrons dès que possible.',
      'cr':
          'Nou la pou ede w! Voye yon mesaj ban nou epi n ap reponn ou pi vit posib.',
      'en':
          'We\'re here to help! Send us a message and we\'ll get back to you as soon as possible.',
    },
    'doxx134q': {
      'fr': 'L\'email qu\'on pourra vous repondre',
      'cr': 'Imèl kote nou ka reponn ou',
      'en': 'The email address where we can reply to you',
    },
    'fnr6ppen': {
      'fr': 'Entrez votre adresse e-mail',
      'cr': 'Antre adrès imèl ou',
      'en': 'Enter your email address',
    },
    'uio11ou2': {
      'fr': 'Message',
      'cr': 'Mesaj',
      'en': 'Message',
    },
    'j27u9muy': {
      'fr': 'Décrivez votre problème ou votre question en détail...',
      'cr': 'Dekri pwoblèm ou oswa kesyon ou an detay...',
      'en': 'Describe your issue or question in detail...',
    },
    'qqvtrj3h': {
      'fr': 'Délai de réponse',
      'cr': 'Tan repons',
      'en': 'Response Time',
    },
    'lvctbl78': {
      'fr': 'Nous répondons généralement sous 24 heures les jours ouvrables.',
      'cr': 'Anjeneral, nou reponn nan 24 èdtan pandan jou travay yo.',
      'en': 'We typically respond within 24 hours during business days.',
    },
    'chi61r9u': {
      'fr': 'Envoyer le message',
      'cr': 'Voye mesaj la',
      'en': 'Send Message',
    },
    'spzsuvvt': {
      'fr': 'Service client',
      'cr': 'Sèvis kliyan',
      'en': 'Customer Service',
    },
  },
  // VIP
  {
    'qzn6e3c5': {
      'fr': 'VIP',
      'cr': 'VIP',
      'en': 'VIP',
    },
    'gfj3b9xn': {
      'fr': 'Compte VIP',
      'cr': 'Kont VIP',
      'en': 'VIP Account',
    },
    'pubct0u4': {
      'fr': 'Accès aux prédictions Premium',
      'cr': 'Aksè nan prediksyon prim yo',
      'en': 'Access to premium predictions',
    },
    'vipproblb': {
      'fr': 'Probabilité',
      'cr': 'Pwobabilite',
      'en': 'Probability',
    },
    'isn2t0tf': {
      'fr': 'POURBOIRE',
      'cr': 'POUBWA',
      'en': 'TIP',
    },
    'xj2saev3': {
      'fr': 'VIP',
      'cr': 'VIP',
      'en': 'VIP',
    },
  },
  // VIP history
  {
    'viphstttl': {
      'fr': 'Historique VIP',
      'cr': 'Istorik VIP',
      'en': 'VIP History',
    },
    'viphsttip': {
      'fr': 'Voir l\'historique VIP',
      'cr': 'Gade istorik VIP la',
      'en': 'View VIP history',
    },
    'viphsthed': {
      'fr': 'Calendrier des prédictions',
      'cr': 'Kalandriye prediksyon yo',
      'en': 'Prediction calendar',
    },
    'viphstdsc': {
      'fr': 'Sélectionnez une date marquée pour consulter ses prédictions.',
      'cr': 'Chwazi yon dat ki make pou w gade prediksyon li yo.',
      'en': 'Select a marked date to view its predictions.',
    },
    'viphstpub': {
      'fr': 'publication',
      'cr': 'piblikasyon',
      'en': 'publication',
    },
    'viphstpbs': {
      'fr': 'publications',
      'cr': 'piblikasyon',
      'en': 'publications',
    },
    'viphstsel': {
      'fr': 'sélection',
      'cr': 'seleksyon',
      'en': 'selection',
    },
    'viphstses': {
      'fr': 'sélections',
      'cr': 'seleksyon',
      'en': 'selections',
    },
    'viphstnew': {
      'fr': 'RÉCENTE',
      'cr': 'RESAN',
      'en': 'LATEST',
    },
    'viphstnod': {
      'fr': 'Date non disponible',
      'cr': 'Dat la pa disponib',
      'en': 'Date unavailable',
    },
    'viphstnos': {
      'fr': 'Aucune sélection enregistrée.',
      'cr': 'Pa gen seleksyon ki anrejistre.',
      'en': 'No selections saved.',
    },
    'viphstfav': {
      'fr': 'FAVORI',
      'cr': 'FAVORI',
      'en': 'FAVORITE',
    },
    'viphstsou': {
      'fr': 'SOUTNI',
      'cr': 'SOUTNI',
      'en': 'SOUTNI',
    },
    'viphstbol': {
      'fr': 'BOLOTO',
      'cr': 'BOLOTO',
      'en': 'BOLOTO',
    },
    'viphstmar': {
      'fr': 'MARIAGE',
      'cr': 'MARYAJ',
      'en': 'MARRIAGE',
    },
    'viphstc3f': {
      'fr': '3 CHIFFRES',
      'cr': '3 CHIF',
      'en': '3 DIGITS',
    },
    'viphstc4f': {
      'fr': '4 CHIFFRES',
      'cr': '4 CHIF',
      'en': '4 DIGITS',
    },
    'viphstext': {
      'fr': 'EXTRA',
      'cr': 'EKSTRA',
      'en': 'EXTRA',
    },
    'viphstlod': {
      'fr': 'Chargement de l\'historique...',
      'cr': 'Istorik la ap chaje...',
      'en': 'Loading history...',
    },
    'viphsterr': {
      'fr': 'Historique indisponible',
      'cr': 'Istorik la pa disponib',
      'en': 'History unavailable',
    },
    'viphsterd': {
      'fr': 'Impossible de charger les prédictions pour le moment.',
      'cr': 'Nou pa kapab chaje prediksyon yo kounye a.',
      'en': 'Predictions cannot be loaded right now.',
    },
    'viphstrty': {
      'fr': 'Réessayer',
      'cr': 'Eseye ankò',
      'en': 'Try again',
    },
    'viphstemp': {
      'fr': 'Aucune prédiction dans l\'historique',
      'cr': 'Pa gen prediksyon nan istorik la',
      'en': 'No predictions in history',
    },
    'viphstemd': {
      'fr':
          'Les anciennes prédictions apparaîtront ici après leur publication.',
      'cr': 'Ansyen prediksyon yo ap parèt isit la apre yo fin pibliye.',
      'en': 'Previous predictions will appear here after publication.',
    },
    'viphstndy': {
      'fr': 'Aucune prédiction ce jour',
      'cr': 'Pa gen prediksyon jou sa a',
      'en': 'No predictions on this day',
    },
    'viphstndd': {
      'fr': 'Choisissez une date marquée dans le calendrier.',
      'cr': 'Chwazi yon dat ki make nan kalandriye a.',
      'en': 'Choose a marked date in the calendar.',
    },
    'viphstacc': {
      'fr': 'Accès VIP requis',
      'cr': 'Aksè VIP obligatwa',
      'en': 'VIP access required',
    },
    'viphstacd': {
      'fr':
          'Votre abonnement VIP doit être actif pour consulter cet historique.',
      'cr': 'Abònman VIP ou dwe aktif pou w gade istorik sa a.',
      'en': 'Your VIP subscription must be active to view this history.',
    },
    'viphstbak': {
      'fr': 'Retour à VIP',
      'cr': 'Retounen nan VIP',
      'en': 'Back to VIP',
    },
  },
  // upgrade
  {
    'mu1scrs8': {
      'fr': 'Accueil',
      'cr': 'Akèy',
      'en': 'Home',
    },
  },
  // Home
  {
    'covzb0rd': {
      'fr': 'ABONNEMENT VIP',
      'cr': 'ABÒNMAN VIP',
      'en': 'VIP MEMBERSHIP',
    },
    'uvl7vow9': {
      'fr': 'Accède à tous les avantages exclusifs.',
      'cr': 'Jwenn aksè nan tout avantaj eksklizif yo.',
      'en': 'Access all exclusive benefits.',
    },
    'afym167o': {
      'fr': 'CROIX DE LA CHANCE',
      'cr': 'KWA LACHANS',
      'en': 'LUCKY CROSS',
    },
    'pqih1sxe': {
      'fr': 'Tente chaque jour et gagne GROS.',
      'cr': 'Tante chans ou chak jou epi genyen GWO.',
      'en': 'Try every day and win BIG.',
    },
    'fkwji2m2': {
      'fr': 'YOUTUBE',
      'cr': 'YOUTUBE',
      'en': 'YOUTUBE',
    },
    'gcjztr88': {
      'fr': 'Regarde, Abonne-toi et reste connecté',
      'cr': 'Gade, abòne w epi rete konekte',
      'en': 'Watch, subscribe, and stay connected',
    },
    'loh576na': {
      'fr': 'CHOLOTO',
      'cr': 'CHOLOTO',
      'en': 'CHOLOTO',
    },
    'uer2q4no': {
      'fr': 'Accueil',
      'cr': 'Akèy',
      'en': 'Home',
    },
  },
  // Accomplissements
  {
    'aiyue31r': {
      'fr': 'STATISTIQUES',
      'cr': 'ESTATISTIK',
      'en': 'STATISTICS',
    },
    'o0ut0uym': {
      'fr': 'Statistiques',
      'cr': 'Estatistik',
      'en': 'Statistics',
    },
    'exm1ba5v': {
      'fr': 'Accomplissements',
      'cr': 'Reyalizasyon',
      'en': 'Achievements',
    },
    'safuzdxq': {
      'fr': 'Gains déclarés',
      'cr': 'Gany ki deklare',
      'en': 'Reported winnings',
    },
    '5baauzd7': {
      'fr': 'Gains ratés déclarés',
      'cr': 'Gany rate ki deklare',
      'en': 'Reported missed winnings',
    },
    'ach_guest_title': {
      'fr': 'Connectez-vous pour collectionner vos badges',
      'cr': 'Konekte pou w koleksyone badj ou yo',
      'en': 'Sign in to collect your badges',
    },
    'ach_guest_desc': {
      'fr':
          'Votre série quotidienne et vos récompenses seront synchronisées sur tous vos appareils.',
      'cr':
          'Seri chak jou ak rekonpans ou yo ap senkronize sou tout aparèy ou yo.',
      'en': 'Your daily streak and rewards will sync across all your devices.',
    },
    'ach_sign_in': {
      'fr': 'Se connecter',
      'cr': 'Konekte',
      'en': 'Sign in',
    },
    'ach_error_title': {
      'fr': 'Vos accomplissements sont indisponibles',
      'cr': 'Reyalizasyon ou yo pa disponib',
      'en': 'Your achievements are unavailable',
    },
    'ach_error_desc': {
      'fr':
          'Vérifiez votre connexion puis réessayez. Votre progression reste enregistrée.',
      'cr': 'Verifye koneksyon ou epi eseye ankò. Pwogrè ou rete anrejistre.',
      'en': 'Check your connection and try again. Your progress remains saved.',
    },
    'ach_retry': {
      'fr': 'Réessayer',
      'cr': 'Eseye ankò',
      'en': 'Try again',
    },
    'ach_profile_missing_title': {
      'fr': 'Profil en cours de préparation',
      'cr': 'Pwofil la ap prepare',
      'en': 'Profile being prepared',
    },
    'ach_profile_missing_desc': {
      'fr':
          'Votre progression apparaîtra dès que votre profil CHOLOTO sera prêt.',
      'cr': 'Pwogrè ou ap parèt depi pwofil CHOLOTO ou pare.',
      'en':
          'Your progress will appear as soon as your CHOLOTO profile is ready.',
    },
    'ach_streak_semantics': {
      'fr': 'Série de connexion quotidienne',
      'cr': 'Seri koneksyon chak jou',
      'en': 'Daily login streak',
    },
    'ach_streak_title': {
      'fr': 'Votre série actuelle',
      'cr': 'Seri ou genyen kounye a',
      'en': 'Your current streak',
    },
    'ach_days_in_a_row': {
      'fr': 'jours d’affilée',
      'cr': 'jou youn apre lòt',
      'en': 'days in a row',
    },
    'ach_best_streak': {
      'fr': 'Meilleur record :',
      'cr': 'Pi bon rekò :',
      'en': 'Best streak:',
    },
    'ach_days_until_badge': {
      'fr': 'jours avant le badge de',
      'cr': 'jou anvan badj',
      'en': 'days until the',
    },
    'ach_all_streak_unlocked': {
      'fr': 'Tous les badges de série sont débloqués !',
      'cr': 'Tout badj seri yo debloke !',
      'en': 'All streak badges are unlocked!',
    },
    'ach_day_mon': {'fr': 'L', 'cr': 'L', 'en': 'M'},
    'ach_day_tue': {'fr': 'M', 'cr': 'M', 'en': 'T'},
    'ach_day_wed': {'fr': 'M', 'cr': 'M', 'en': 'W'},
    'ach_day_thu': {'fr': 'J', 'cr': 'J', 'en': 'T'},
    'ach_day_fri': {'fr': 'V', 'cr': 'V', 'en': 'F'},
    'ach_day_sat': {'fr': 'S', 'cr': 'S', 'en': 'S'},
    'ach_day_sun': {'fr': 'D', 'cr': 'D', 'en': 'S'},
    'ach_tracking_started': {
      'fr':
          'Le suivi de votre série commence aujourd’hui. Aucun historique antérieur n’a été inventé.',
      'cr': 'Swivi seri ou kòmanse jodi a. Nou pa envante okenn ansyen istwa.',
      'en':
          'Your streak tracking starts today. No earlier history has been invented.',
    },
    'ach_overview_title': {
      'fr': 'Votre progression',
      'cr': 'Pwogrè ou',
      'en': 'Your progress',
    },
    'ach_overview_desc': {
      'fr': 'Un résumé de vos déclarations Bingo et de votre activité.',
      'cr': 'Yon rezime deklarasyon Bingo ak aktivite ou.',
      'en': 'A summary of your Bingo reports and activity.',
    },
    'ach_stat_declarations': {
      'fr': 'Participations déclarées',
      'cr': 'Patisipasyon deklare',
      'en': 'Reported entries',
    },
    'ach_stat_wins': {
      'fr': 'Gains déclarés',
      'cr': 'Gany ki deklare',
      'en': 'Reported wins',
    },
    'ach_stat_rate': {
      'fr': 'Taux de réussite déclaré',
      'cr': 'To reyisit ki deklare',
      'en': 'Reported success rate',
    },
    'ach_badges_title': {
      'fr': 'Collection de badges',
      'cr': 'Koleksyon badj',
      'en': 'Badge collection',
    },
    'ach_badges_desc': {
      'fr': 'Revenez chaque jour et participez aux Bingos pour tout débloquer.',
      'cr':
          'Retounen chak jou epi patisipe nan Bingo yo pou debloke tout bagay.',
      'en': 'Come back daily and join Bingos to unlock everything.',
    },
    'ach_unlocked': {'fr': 'Débloqué', 'cr': 'Debloke', 'en': 'Unlocked'},
    'ach_locked': {'fr': 'Verrouillé', 'cr': 'Bloke', 'en': 'Locked'},
    'ach_progress_of': {'fr': 'sur', 'cr': 'sou', 'en': 'of'},
    'ach_streak_3_title': {
      'fr': 'Étincelle',
      'cr': 'Etensèl',
      'en': 'Spark',
    },
    'ach_streak_3_desc': {
      'fr': '3 jours connectés d’affilée',
      'cr': '3 jou konekte youn apre lòt',
      'en': 'Log in 3 days in a row',
    },
    'ach_streak_7_title': {
      'fr': 'Semaine en feu',
      'cr': 'Semèn an dife',
      'en': 'Week on fire',
    },
    'ach_streak_7_desc': {
      'fr': '7 jours connectés d’affilée',
      'cr': '7 jou konekte youn apre lòt',
      'en': 'Log in 7 days in a row',
    },
    'ach_streak_14_title': {
      'fr': 'Inarrêtable',
      'cr': 'San rete',
      'en': 'Unstoppable',
    },
    'ach_streak_14_desc': {
      'fr': '14 jours connectés d’affilée',
      'cr': '14 jou konekte youn apre lòt',
      'en': 'Log in 14 days in a row',
    },
    'ach_streak_30_title': {
      'fr': 'Légende du mois',
      'cr': 'Lejand mwa a',
      'en': 'Monthly legend',
    },
    'ach_streak_30_desc': {
      'fr': '30 jours connectés d’affilée',
      'cr': '30 jou konekte youn apre lòt',
      'en': 'Log in 30 days in a row',
    },
    'ach_winner_1_title': {
      'fr': 'Premier gain',
      'cr': 'Premye gany',
      'en': 'First win',
    },
    'ach_winner_1_desc': {
      'fr': 'Déclarer un premier Bingo gagnant',
      'cr': 'Deklare premye Bingo ki genyen',
      'en': 'Report your first winning Bingo',
    },
    'ach_winner_5_title': {
      'fr': 'Œil de lynx',
      'cr': 'Je file',
      'en': 'Sharp eye',
    },
    'ach_winner_5_desc': {
      'fr': 'Déclarer 5 Bingos gagnants',
      'cr': 'Deklare 5 Bingo ki genyen',
      'en': 'Report 5 winning Bingos',
    },
    'ach_winner_10_title': {
      'fr': 'Maître Bingo',
      'cr': 'Mèt Bingo',
      'en': 'Bingo master',
    },
    'ach_winner_10_desc': {
      'fr': 'Déclarer 10 Bingos gagnants',
      'cr': 'Deklare 10 Bingo ki genyen',
      'en': 'Report 10 winning Bingos',
    },
    'ach_participation_1_title': {
      'fr': 'Premier pas',
      'cr': 'Premye pa',
      'en': 'First step',
    },
    'ach_participation_1_desc': {
      'fr': 'Faire une première déclaration',
      'cr': 'Fè premye deklarasyon ou',
      'en': 'Make your first report',
    },
    'ach_participation_10_title': {
      'fr': 'Habitué',
      'cr': 'Abitye',
      'en': 'Regular',
    },
    'ach_participation_10_desc': {
      'fr': 'Atteindre 10 déclarations',
      'cr': 'Rive nan 10 deklarasyon',
      'en': 'Reach 10 reports',
    },
    'ach_participation_50_title': {
      'fr': 'Passionné',
      'cr': 'Pasyone',
      'en': 'Enthusiast',
    },
    'ach_participation_50_desc': {
      'fr': 'Atteindre 50 déclarations',
      'cr': 'Rive nan 50 deklarasyon',
      'en': 'Reach 50 reports',
    },
    'ach_loyalty_30_title': {
      'fr': 'Membre fidèle',
      'cr': 'Manm fidèl',
      'en': 'Loyal member',
    },
    'ach_loyalty_30_desc': {
      'fr': 'Être membre depuis 30 jours',
      'cr': 'Manm depi 30 jou',
      'en': 'Be a member for 30 days',
    },
    'ach_loyalty_180_title': {
      'fr': 'Pilier CHOLOTO',
      'cr': 'Pilye CHOLOTO',
      'en': 'CHOLOTO pillar',
    },
    'ach_loyalty_180_desc': {
      'fr': 'Être membre depuis 180 jours',
      'cr': 'Manm depi 180 jou',
      'en': 'Be a member for 180 days',
    },
    'ach_profile_title': {
      'fr': 'Profil rayonnant',
      'cr': 'Pwofil briyan',
      'en': 'Shining profile',
    },
    'ach_profile_desc': {
      'fr': 'Ajouter votre nom et votre photo',
      'cr': 'Ajoute non ak foto ou',
      'en': 'Add your name and photo',
    },
    '4z7v1o5y': {
      'fr': 'Hello World',
      'cr': 'Bonjou mond',
      'en': 'Hello World',
    },
    'xilss3xs': {
      'fr': 'Home',
      'cr': 'Akèy',
      'en': 'Home',
    },
  },
  // newYorkk
  {
    'm917towe': {
      'fr': 'NEW YORK',
      'cr': 'NEW YORK',
      'en': 'NEW YORK',
    },
  },
  // infos
  {
    '0h41wv7v': {
      'fr': 'Bonsoir',
      'cr': 'Bonswa',
      'en': 'Good evening',
    },
    'kdy8dhng': {
      'fr': 'D\'accord',
      'cr': 'Dakò',
      'en': 'Okay',
    },
  },
  // FL
  {
    'c2owtjft': {
      'fr': 'FLORIDA',
      'cr': 'FLORIDA',
      'en': 'FLORIDA',
    },
    'u6drxrnb': {
      'fr': 'Prochain tirage dans:',
      'cr': 'Pwochen tiraj nan:',
      'en': 'Next draw in:',
    },
  },
  // language
  {
    'fvgr8wc7': {
      'fr': 'Français',
      'cr': 'Fransè',
      'en': 'French',
    },
    'nido8rbi': {
      'fr': 'Anglais',
      'cr': 'Anglè',
      'en': 'English',
    },
    '687lerxj': {
      'fr': 'Créole',
      'cr': 'Kreyòl',
      'en': 'Creole',
    },
  },
  // devenirVIP
  {
    'c8ki06qv': {
      'fr': 'Devenez un membre VIP',
      'cr': 'Vin yon manm VIP',
      'en': 'Become a VIP member',
    },
    'imcn98qf': {
      'fr': 'Avec CHOLOTO VIP, multipliez vos chances de gagner !',
      'cr': 'Avèk CHOLOTO VIP, miltipliye chans ou pou genyen!',
      'en': 'With CHOLOTO VIP, multiply your chances of winning!',
    },
    '99kfebqb': {
      'fr': 'CE QUI EST INCLUS',
      'cr': 'SA KI LADAN',
      'en': 'WHAT\'S INCLUDED',
    },
    'juufc32a': {
      'fr': 'GRATUIT',
      'cr': 'GRATIS',
      'en': 'FREE',
    },
    'zpnlwhem': {
      'fr': 'VIP',
      'cr': 'VIP',
      'en': 'VIP',
    },
    'tv8dp8zl': {
      'fr': 'Résultats des loteries',
      'cr': 'Rezilta lotri yo',
      'en': 'Lottery results',
    },
    'jekwx2fb': {
      'fr': 'Résultats des loteries',
      'cr': 'Rezilta lotri yo',
      'en': 'Lottery results',
    },
    'j59fr62k': {
      'fr': 'Résultats des loteries',
      'cr': 'Rezilta lotri yo',
      'en': 'Lottery results',
    },
    '96ad4c5w': {
      'fr': 'Résultats des loteries',
      'cr': 'Rezilta lotri yo',
      'en': 'Lottery results',
    },
    'bl4kupme': {
      'fr': '1 Mois',
      'cr': '1 Mwa',
      'en': '1 Month',
    },
    'r11k1q8q': {
      'fr': 'USD \$ 40.00 ou GDS 2,000.00',
      'cr': 'USD \$ 40.00 oswa GDS 2,000.00',
      'en': 'USD \$ 40.00 or GDS 2,000.00',
    },
    'i0zhxntw': {
      'fr': 'Devenir VIP',
      'cr': 'Vin VIP',
      'en': 'Become VIP',
    },
  },
  // editProfilTexts
  {
    'etl45w0v': {
      'fr': 'Champ de texte',
      'cr': 'Chan tèks',
      'en': 'Text field',
    },
    '640x9dq1': {
      'fr': 'Bouton',
      'cr': 'Bouton',
      'en': 'Button',
    },
    'prfnamehint': {
      'fr': 'Entrez votre nom d\'utilisateur',
      'cr': 'Antre non itilizatè ou',
      'en': 'Enter your username',
    },
    'prfemlhint': {
      'fr': 'Entrez votre adresse e-mail',
      'cr': 'Antre adrès imèl ou',
      'en': 'Enter your email address',
    },
    'prfsavebtn': {
      'fr': 'Enregistrer',
      'cr': 'Anrejistre',
      'en': 'Save',
    },
    'prfemailrq': {
      'fr': 'L\'adresse e-mail est obligatoire.',
      'cr': 'Adrès imèl la obligatwa.',
      'en': 'Email is required.',
    },
  },
  // bingoCardVIP
  {
    'bingo_story_label': {
      'fr': 'Bingo',
      'cr': 'Bingo',
      'en': 'Bingo',
    },
    'bingo_story_open': {
      'fr': 'Ouvrir le Bingo',
      'cr': 'Ouvri Bingo a',
      'en': 'Open Bingo',
    },
    'bingo_story_previous': {
      'fr': 'Bingo précédent',
      'cr': 'Bingo anvan an',
      'en': 'Previous Bingo',
    },
    'bingo_story_next': {
      'fr': 'Bingo suivant',
      'cr': 'Bingo apre a',
      'en': 'Next Bingo',
    },
    'bingo_story_like': {
      'fr': 'J’aime ce Bingo',
      'cr': 'Mwen renmen Bingo sa a',
      'en': 'Like this Bingo',
    },
    'bingo_story_dislike': {
      'fr': 'Je n’aime pas ce Bingo',
      'cr': 'Mwen pa renmen Bingo sa a',
      'en': 'Dislike this Bingo',
    },
    'bingo_story_reaction_error': {
      'fr': 'Impossible d’enregistrer votre réaction pour le moment.',
      'cr': 'Nou pa ka anrejistre reyaksyon ou an kounye a.',
      'en': 'Your reaction could not be saved right now.',
    },
    'bingo_story_comment_hint': {
      'fr': 'Avez-vous gagné avec nous ? Commentez…',
      'cr': 'Èske ou te genyen avèk nou? Ekri yon kòmantè…',
      'en': 'Did you win with us? Add a comment…',
    },
    'bingo_story_comment_send': {
      'fr': 'Envoyer le commentaire',
      'cr': 'Voye kòmantè a',
      'en': 'Send comment',
    },
    'bingo_story_comment_success': {
      'fr': 'Votre commentaire a été envoyé.',
      'cr': 'Kòmantè ou a anrejistre.',
      'en': 'Your comment was sent.',
    },
    'bingo_story_comment_error': {
      'fr': 'Impossible d’envoyer votre commentaire pour le moment.',
      'cr': 'Nou pa ka voye kòmantè ou an kounye a.',
      'en': 'Your comment could not be sent right now.',
    },
    'bingo_story_comment_liked': {
      'fr': 'CHOLOTO aime votre commentaire',
      'cr': 'CHOLOTO renmen kòmantè ou a',
      'en': 'CHOLOTO likes your comment',
    },
    'bingo_story_comment_reply_label': {
      'fr': 'Réponse CHOLOTO',
      'cr': 'Repons CHOLOTO',
      'en': 'CHOLOTO reply',
    },
    'ch00aogu': {
      'fr': 'Avez-vous gagné avec nous ?',
      'cr': 'Èske ou te genyen avèk nou?',
      'en': 'Did you win with us?',
    },
    'ksh6eozy': {
      'fr': 'WI',
      'cr': 'WI',
      'en': 'YES',
    },
    '7ccuyv05': {
      'fr': 'NON',
      'cr': 'NON',
      'en': 'NO',
    },
    'bngreduce': {
      'fr': 'Réduire',
      'cr': 'Redui',
      'en': 'Collapse',
    },
    'bngexpand': {
      'fr': 'Agrandir',
      'cr': 'Elaji',
      'en': 'Expand',
    },
    'bngsuccess': {
      'fr': '🎉 FÉLICITATIONS',
      'cr': '🎉 FELISITASYON',
      'en': '🎉 CONGRATULATIONS',
    },
    'bngtryagain': {
      'fr': 'RÉESSAYEZ UNE PROCHAINE FOIS',
      'cr': 'ESEYE YON LÒT FWA',
      'en': 'TRY AGAIN NEXT TIME',
    },
  },
  // don
  {
    'don_moncash_title': {
      'fr': 'Pourboire avec MonCash',
      'cr': 'Fè yon pourboire ak MonCash',
      'en': 'Tip with MonCash',
    },
    'don_moncash_instruction': {
      'fr':
          'Pour soutenir CHOLOTO, envoyez directement votre pourboire au numéro ci-dessous.',
      'cr':
          'Pou soutni CHOLOTO, voye pourboire ou dirèkteman nan nimewo ki anba a.',
      'en': 'To support CHOLOTO, send your tip directly to the number below.',
    },
    'don_moncash_label': {
      'fr': 'Numéro MonCash de CHOLOTO',
      'cr': 'Nimewo MonCash CHOLOTO',
      'en': 'CHOLOTO MonCash number',
    },
    'don_moncash_thanks': {
      'fr': 'Merci pour votre soutien !',
      'cr': 'Mèsi pou sipò ou !',
      'en': 'Thank you for your support!',
    },
    'wydszs2w': {
      'fr': 'Faire un don',
      'cr': 'Fè nou yon don',
      'en': 'Make a Donation',
    },
    '6xxzgm60': {
      'fr':
          'Votre contribution nous aide à poursuivre notre mission et à avoir un impact positif dans la communauté.',
      'cr':
          'Kontribisyon ou ede nou kontinye misyon nou pou pote yon enpak pozitif nan kominote a.',
      'en':
          'Your contribution helps us continue our mission to make a positive impact in the community.',
    },
    's9v0uvn9': {
      'fr': 'Sélectionnez un montant',
      'cr': 'Chwazi yon montan',
      'en': 'Select Amount',
    },
    '42ir0fto': {
      'fr': '\$10',
      'cr': '\$10',
      'en': '\$10',
    },
    '8igtcp6r': {
      'fr': '\$25',
      'cr': '\$25',
      'en': '\$25',
    },
    'beg6pkjf': {
      'fr': '\$50',
      'cr': '\$50',
      'en': '\$50',
    },
    'ovxdt2ne': {
      'fr': '\$100',
      'cr': '\$100',
      'en': '\$100',
    },
    'cwa7j3cs': {
      'fr': 'Montant personnalisé',
      'cr': 'Montan pèsonalize',
      'en': 'Custom Amount',
    },
    '36ocr8q8': {
      'fr': 'Entrez le montant',
      'cr': 'Antre montan an',
      'en': 'Enter amount',
    },
    'kmatu0bj': {
      'fr': 'Mode de paiement',
      'cr': 'Metòd peman',
      'en': 'Payment Method',
    },
    'zgkhgl88': {
      'fr': '•••• •••• •••• 4242',
      'cr': '•••• •••• •••• 4242',
      'en': '•••• •••• •••• 4242',
    },
    'r0jtpvwa': {
      'fr': 'Faire un don maintenant',
      'cr': 'Fè yon don kounye a',
      'en': 'Donate Now',
    },
    'g2sbccpm': {
      'fr': 'Votre don est sécurisé et sera traité en toute sécurité.',
      'cr': 'Don ou an sekirite epi y ap trete li san danje.',
      'en': 'Your donation is secure and will be processed safely.',
    },
  },
  // Welcome
  {
    'onboarding_eyebrow': {
      'fr': 'Bienvenue dans CHOLOTO',
      'cr': 'Byenvini nan CHOLOTO',
      'en': 'Welcome to CHOLOTO',
    },
    'onboarding_title': {
      'fr': 'Vos tirages. Vos numéros. Votre CHOLOTO.',
      'cr': 'Tiraj ou. Nimewo ou. CHOLOTO pa ou.',
      'en': 'Your draws. Your numbers. Your CHOLOTO.',
    },
    'onboarding_description': {
      'fr':
          'Consultez les résultats, explorez le Tchala et profitez de l’expérience VIP au même endroit.',
      'cr':
          'Gade rezilta yo, dekouvri Tchala a epi pwofite eksperyans VIP la yon sèl kote.',
      'en':
          'Check results, explore Tchala, and enjoy the VIP experience in one place.',
    },
    'onboarding_feature_results': {
      'fr': 'Résultats rapides',
      'cr': 'Rezilta rapid',
      'en': 'Fast results',
    },
    'onboarding_feature_tchala': {
      'fr': 'Tchala',
      'cr': 'Tchala',
      'en': 'Tchala',
    },
    'onboarding_feature_vip': {
      'fr': 'Avantages VIP',
      'cr': 'Avantaj VIP',
      'en': 'VIP benefits',
    },
    'onboarding_continue_title': {
      'fr': 'Choisissez comment continuer',
      'cr': 'Chwazi kijan pou kontinye',
      'en': 'Choose how to continue',
    },
    'onboarding_logo_label': {
      'fr': 'Logo CHOLOTO',
      'cr': 'Logo CHOLOTO',
      'en': 'CHOLOTO logo',
    },
    'registration_eyebrow': {
      'fr': 'Finalisons votre compte',
      'cr': 'Ann fini kont ou',
      'en': 'Let’s finish your account',
    },
    'registration_title': {
      'fr': 'Encore une petite étape',
      'cr': 'Gen yon ti etap ankò',
      'en': 'One quick final step',
    },
    'registration_description': {
      'fr':
          'Choisissez votre langue et ajoutez votre numéro pour finaliser votre profil CHOLOTO.',
      'cr':
          'Chwazi lang ou epi ajoute nimewo telefòn ou pou n fini pwofil CHOLOTO ou.',
      'en':
          'Choose your language and add your phone number to finish your CHOLOTO profile.',
    },
    'registration_language_label': {
      'fr': 'Votre langue',
      'cr': 'Lang ou',
      'en': 'Your language',
    },
    'registration_language_fr': {
      'fr': 'Français',
      'cr': 'Fransè',
      'en': 'French',
    },
    'registration_language_en': {
      'fr': 'Anglais',
      'cr': 'Anglè',
      'en': 'English',
    },
    'registration_language_cr': {
      'fr': 'Créole',
      'cr': 'Kreyòl',
      'en': 'Haitian Creole',
    },
    'registration_phone_label': {
      'fr': 'Numéro de téléphone (facultatif)',
      'cr': 'Nimewo telefòn (si ou vle)',
      'en': 'Phone number (optional)',
    },
    'registration_phone_hint': {
      'fr': 'Laissez vide ou saisissez : +509 37 00 00 00',
      'cr': 'Kite l vid oswa antre : +509 37 00 00 00',
      'en': 'Leave blank or enter: +509 37 00 00 00',
    },
    'registration_validate': {
      'fr': 'Valider et continuer',
      'cr': 'Valide epi kontinye',
      'en': 'Confirm and continue',
    },
    'registration_phone_invalid': {
      'fr': 'Saisissez un numéro de téléphone valide.',
      'cr': 'Antre yon nimewo telefòn ki valab.',
      'en': 'Enter a valid phone number.',
    },
    'registration_language_required': {
      'fr': 'Choisissez votre langue.',
      'cr': 'Chwazi lang ou.',
      'en': 'Choose your language.',
    },
    'registration_save_error': {
      'fr':
          'Impossible de finaliser votre profil pour le moment. Vérifiez votre connexion et réessayez.',
      'cr':
          'Nou pa ka fini pwofil ou pou kounye a. Verifye koneksyon ou epi eseye ankò.',
      'en':
          'We cannot finish your profile right now. Check your connection and try again.',
    },
    'ser0033p': {
      'fr': 'Continuer avec Google',
      'cr': 'Kontinye ak Google',
      'en': 'Continue with Google',
    },
    'email_continue': {
      'fr': 'Créer un compte avec un e-mail',
      'cr': 'Kreye yon kont ak yon imèl',
      'en': 'Create an account with email',
    },
    'email_sign_in_title': {
      'fr': 'Connexion par e-mail',
      'cr': 'Konekte ak imèl',
      'en': 'Email sign-in',
    },
    'email_sign_in_description': {
      'fr': 'Saisissez l’adresse e-mail et le mot de passe de votre compte.',
      'cr': 'Antre adrès imèl ak modpas kont ou.',
      'en': 'Enter the email address and password for your account.',
    },
    'email_create_title': {
      'fr': 'Créer un compte',
      'cr': 'Kreye yon kont',
      'en': 'Create an account',
    },
    'email_create_description': {
      'fr': 'Créez votre compte avec une adresse e-mail et un mot de passe.',
      'cr': 'Kreye kont ou ak yon adrès imèl ak yon modpas.',
      'en': 'Create your account with an email address and password.',
    },
    'email_label': {
      'fr': 'Adresse e-mail',
      'cr': 'Adrès imèl',
      'en': 'Email address',
    },
    'email_password_label': {
      'fr': 'Mot de passe',
      'cr': 'Modpas',
      'en': 'Password',
    },
    'email_confirm_password_label': {
      'fr': 'Confirmer le mot de passe',
      'cr': 'Konfime modpas la',
      'en': 'Confirm password',
    },
    'email_sign_in': {
      'fr': 'Se connecter',
      'cr': 'Konekte',
      'en': 'Sign in',
    },
    'email_create_account': {
      'fr': 'Créer mon compte',
      'cr': 'Kreye kont mwen',
      'en': 'Create my account',
    },
    'email_create_mode': {
      'fr': 'Créer un compte',
      'cr': 'Kreye kont',
      'en': 'Create account',
    },
    'email_sign_in_mode': {
      'fr': 'Se connecter',
      'cr': 'Konekte',
      'en': 'Sign in',
    },
    'email_forgot_password': {
      'fr': 'Mot de passe oublié ?',
      'cr': 'Ou bliye modpas ou?',
      'en': 'Forgot password?',
    },
    'email_invalid': {
      'fr': 'Saisissez une adresse e-mail valide.',
      'cr': 'Antre yon adrès imèl ki valab.',
      'en': 'Enter a valid email address.',
    },
    'email_password_too_short': {
      'fr': 'Le mot de passe doit contenir au moins 6 caractères.',
      'cr': 'Modpas la dwe gen omwen 6 karaktè.',
      'en': 'The password must contain at least 6 characters.',
    },
    'email_password_mismatch': {
      'fr': 'Les mots de passe ne correspondent pas.',
      'cr': 'Modpas yo pa menm.',
      'en': 'The passwords do not match.',
    },
    'email_show_password': {
      'fr': 'Afficher le mot de passe',
      'cr': 'Montre modpas la',
      'en': 'Show password',
    },
    'email_hide_password': {
      'fr': 'Masquer le mot de passe',
      'cr': 'Kache modpas la',
      'en': 'Hide password',
    },
    'email_loading': {
      'fr': 'Veuillez patienter…',
      'cr': 'Tanpri tann…',
      'en': 'Please wait…',
    },
    'email_close': {
      'fr': 'Fermer',
      'cr': 'Fèmen',
      'en': 'Close',
    },
    '7p5qctmz': {
      'fr': 'Continuer en tant qu\'invité',
      'cr': 'Kontinye kòm envite',
      'en': 'Continue as guest',
    },
    '3vjw7hwm': {
      'fr': 'VERSION BETA',
      'cr': 'VÈSYON BETA',
      'en': 'BETA VERSION',
    },
  },
  // tiragesHome
  {
    'grf0e1nq': {
      'fr': 'TIRAGES',
      'cr': 'TIRAJ',
      'en': 'DRAWS',
    },
    'zljfxk4l': {
      'fr': 'VOIR TOUT',
      'cr': 'GADE TOUT',
      'en': 'VIEW ALL',
    },
  },
  // storyPage
  {
    'hs9qcniz': {
      'fr': 'TEST 1-2',
      'cr': 'TÈS 1-2',
      'en': 'TEST 1-2',
    },
    'gbh5c896': {
      'fr': 'Hello World',
      'cr': 'Bonjou mond',
      'en': 'Hello World',
    },
  },
  // rappelFinAbonnement
  {
    'subscription_expiration_reminder_title': {
      'fr': 'Abonnement bientôt expiré',
      'cr': 'Abònman an pral ekspire',
      'en': 'Subscription expiring soon',
    },
    'subscription_expiration_reminder_date': {
      'fr': 'Votre accès VIP prend fin le',
      'cr': 'Aksè VIP ou ap fini',
      'en': 'Your VIP access ends on',
    },
    'subscription_expiration_reminder_message': {
      'fr':
          'Réabonnez-vous dès que possible pour éviter toute interruption de vos avantages VIP.',
      'cr': 'Renouvle abònman ou pi vit posib pou avantaj VIP ou yo pa kanpe.',
      'en':
          'Renew as soon as possible to avoid any interruption to your VIP benefits.',
    },
    'subscription_expiration_reminder_renew': {
      'fr': 'Se réabonner',
      'cr': 'Renouvle kounye a',
      'en': 'Renew now',
    },
    'subscription_expiration_reminder_later': {
      'fr': 'Plus tard',
      'cr': 'Pita',
      'en': 'Later',
    },
    'subscription_expiration_reminder_close': {
      'fr': 'Fermer',
      'cr': 'Fèmen',
      'en': 'Close',
    },
    'subscription_expired_card_title': {
      'fr': 'Votre abonnement VIP a expiré',
      'cr': 'Abònman VIP ou a ekspire',
      'en': 'Your VIP subscription has expired',
    },
    'subscription_expired_card_message': {
      'fr': 'Renouvelez-le maintenant pour retrouver tous vos avantages VIP.',
      'cr': 'Renouvle li kounye a pou w jwenn tout avantaj VIP ou yo ankò.',
      'en': 'Renew now to restore all your VIP benefits.',
    },
    'subscription_expired_card_renew': {
      'fr': 'Renouveler',
      'cr': 'Renouvle',
      'en': 'Renew',
    },
    '6wnv7a6z': {
      'fr':
          'Votre abonnement CHOLOTO VIP expire bientôt. Contactez-Nous dès maintenant pour le renouveler.',
      'cr':
          'Abònman CHOLOTO VIP ou a pral ekspire talè. Kontakte nou kounye a pou renouvle li epi kontinye pwofite tout avantaj eksklizif yo.',
      'en':
          'Your CHOLOTO VIP subscription will expire soon. Contact us today to renew your subscription and continue enjoying all the exclusive benefits.',
    },
    'ppbj8s5f': {
      'fr': 'Contactez-nous',
      'cr': 'Kontakte nou',
      'en': 'Contact us',
    },
  },
  // universalVIP
  {
    'xm4yj0vd': {
      'fr': 'FLO-NY',
      'cr': 'FLO-NY',
      'en': 'FLO-NY',
    },
  },
  // jour
  {
    'lbzfuhpv': {
      'fr': '1',
      'cr': '1',
      'en': '1',
    },
  },
  // Miscellaneous
  {
    '0ges4wqg': {
      'fr': 'Titre',
      'cr': 'Tit',
      'en': 'Title',
    },
    'ymcdwy4s': {
      'fr': 'Sous-titre',
      'cr': 'Sou-tit',
      'en': 'Subtitle',
    },
  },
].reduce((a, b) => a..addAll(b));
