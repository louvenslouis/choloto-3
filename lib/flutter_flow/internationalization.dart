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

  String getText(String key) =>
      (kTranslationsMap[key] ?? {})[locale.toString()] ?? '';

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
      'en': 'Tirages',
    },
    'nwse7gnu': {
      'fr': 'NEW YORK',
      'cr': '',
      'en': '',
    },
    '688llz6y': {
      'fr': 'Pick 3 officiel',
      'cr': '',
      'en': '',
    },
    '16bznwfv': {
      'fr': 'Dernier tirage',
      'cr': '',
      'en': '',
    },
    'xqa3sjic': {
      'fr': 'MIDDAY',
      'cr': '',
      'en': '',
    },
    '9hcsnfjs': {
      'fr': 'EVENING',
      'cr': '',
      'en': '',
    },
    'vho2s2ds': {
      'fr': 'FLORIDA',
      'cr': '',
      'en': '',
    },
    'jc5kkpyj': {
      'fr': 'Pick 2, Pick 3 et Pick 4 officiels',
      'cr': '',
      'en': '',
    },
    'mevtoovb': {
      'fr': 'PICK 2',
      'cr': '',
      'en': '',
    },
    'ccu2gg3x': {
      'fr': 'PICK 3',
      'cr': '',
      'en': '',
    },
    'ov51axfz': {
      'fr': 'PICK 4',
      'cr': '',
      'en': '',
    },
    'cd9jjqv4': {
      'fr': 'Sources: New York State Gaming Commission et Florida Lottery.',
      'cr': '',
      'en': '',
    },
    'wakkucok': {
      'fr': 'Tirages',
      'cr': 'Tiraj',
      'en': 'Tirages',
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
      'en': 'Abonnement',
    },
    'eq9kt96t': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    '6ho9r1de': {
      'fr': 'Termes et Conditions',
      'cr': 'Abònman',
      'en': 'Abonnement',
    },
    'w56piynt': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    'i3ozq7ax': {
      'fr': 'Nous contacter',
      'cr': 'Lang',
      'en': 'Langue',
    },
    '9w72tojm': {
      'fr': 'Langue',
      'cr': 'Lang',
      'en': 'Langue',
    },
    '3vvyx19f': {
      'fr': 'Version',
      'cr': 'Vèsion',
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
      'cr': '',
      'en': '',
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
      'cr': 'Kwa chans',
      'en': 'Cross',
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
      'cr': 'Termes et Conditions',
      'en': 'Termes et Conditions',
    },
    'hy9gb3tc': {
      'fr': 'Header',
      'cr': '',
      'en': '',
    },
    'w4g3cm28': {
      'fr': 'Collapsed body text',
      'cr': '',
      'en': '',
    },
    'kpe3u5qv': {
      'fr': 'Expanded body text',
      'cr': '',
      'en': '',
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
      'en': 'Edit your Profil',
    },
  },
  // customerservice
  {
    'xx4qds3f': {
      'fr': 'Contact Customer Service',
      'cr': '',
      'en': '',
    },
    'ujyy941k': {
      'fr':
          'We\'re here to help! Send us a message and we\'ll get back to you as soon as possible.',
      'cr': '',
      'en': '',
    },
    'doxx134q': {
      'fr': 'L\'email qu\'on pourra vous repondre',
      'cr': '',
      'en': '',
    },
    'fnr6ppen': {
      'fr': 'Enter your email address',
      'cr': '',
      'en': '',
    },
    'uio11ou2': {
      'fr': 'Message',
      'cr': '',
      'en': '',
    },
    'j27u9muy': {
      'fr': 'Describe your issue or question in detail...',
      'cr': '',
      'en': '',
    },
    'qqvtrj3h': {
      'fr': 'Response Time',
      'cr': '',
      'en': '',
    },
    'lvctbl78': {
      'fr': 'We typically respond within 24 hours during business days.',
      'cr': '',
      'en': '',
    },
    'chi61r9u': {
      'fr': 'Send Message',
      'cr': '',
      'en': '',
    },
    'spzsuvvt': {
      'fr': 'Customer Service',
      'cr': '',
      'en': '',
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
      'cr': 'Aksè ak prediksyon Premyòm yo',
      'en': 'Premium Access',
    },
    'isn2t0tf': {
      'fr': 'POURBOIRE',
      'cr': 'DON',
      'en': 'DON',
    },
    'xj2saev3': {
      'fr': 'VIP',
      'cr': 'VIP',
      'en': 'VIP',
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
      'fr': 'MEMBERSHIP',
      'cr': 'MEMBÈCHIP',
      'en': 'MEMBERSHIP',
    },
    'uvl7vow9': {
      'fr': 'Accède à tous les avantages exclusifs.',
      'cr': 'Aksede ak tout avantaj esklizif yo',
      'en': 'Accède à tous les avantages exclusifs.',
    },
    'afym167o': {
      'fr': 'CROIX DE LA CHANCE',
      'cr': 'KWA LACHANS',
      'en': 'CROIX DE LA CHANCE',
    },
    'pqih1sxe': {
      'fr': 'Tente chaque jour et gagne GROS.',
      'cr': 'Tante chak jou',
      'en': 'Tente chaque jour et gagne GROS.',
    },
    'fkwji2m2': {
      'fr': 'YOUTUBE',
      'cr': 'YOUTUBE',
      'en': 'YOUTUBE',
    },
    'gcjztr88': {
      'fr': 'Regarde, Abonne-toi et reste connecté',
      'cr': 'Gade epi rete konekte',
      'en': 'Regarde, Abonne-toi et reste connecté',
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
      'cr': '',
      'en': '',
    },
    'o0ut0uym': {
      'fr': 'Statistiques',
      'cr': '',
      'en': '',
    },
    'exm1ba5v': {
      'fr': 'Accomplissements',
      'cr': '',
      'en': '',
    },
    'safuzdxq': {
      'fr': 'Gains déclarés',
      'cr': '',
      'en': '',
    },
    '5baauzd7': {
      'fr': 'Gains ratés déclarés',
      'cr': '',
      'en': '',
    },
    '4z7v1o5y': {
      'fr': 'Hello World',
      'cr': '',
      'en': '',
    },
    'xilss3xs': {
      'fr': 'Home',
      'cr': '',
      'en': '',
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
      'cr': 'Lizay',
      'en': 'Hello',
    },
    'kdy8dhng': {
      'fr': 'D\'accord',
      'cr': 'Kòrèk',
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
      'cr': 'Prochain tirage dans:',
      'en': 'Prochain tirage dans:',
    },
  },
  // language
  {
    'fvgr8wc7': {
      'fr': 'Français',
      'cr': 'Fransè',
      'en': 'French',
    },
    'k7jkytyd': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    'nido8rbi': {
      'fr': 'Anglais',
      'cr': 'Anglè',
      'en': 'English',
    },
    'mn2wwk29': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    '687lerxj': {
      'fr': 'Créole',
      'cr': 'Kreyòl',
      'en': 'Creole',
    },
    'tifw94xi': {
      'fr': '',
      'cr': '',
      'en': '',
    },
  },
  // devenirVIP
  {
    'c8ki06qv': {
      'fr': 'Devenez un membre VIP',
      'cr': 'Devenez un membre VIP',
      'en': 'Devenez un membre VIP',
    },
    'imcn98qf': {
      'fr': 'ak CHOLOTO VIP, miltipliye chans pouw gagner !',
      'cr': 'ak CHOLOTO VIP, miltipliye chans pouw gagner !',
      'en': 'ak CHOLOTO VIP, miltipliye chans pouw gagner !',
    },
    '99kfebqb': {
      'fr': 'WHAT\'S INCLUDED',
      'cr': 'WHAT\'S INCLUDED',
      'en': 'WHAT\'S INCLUDED',
    },
    'juufc32a': {
      'fr': 'GRATUIT',
      'cr': '',
      'en': '',
    },
    'zpnlwhem': {
      'fr': 'VIP',
      'cr': '',
      'en': '',
    },
    'tv8dp8zl': {
      'fr': 'Resultats lotteries',
      'cr': '',
      'en': '',
    },
    'jekwx2fb': {
      'fr': 'Resultats lotteries',
      'cr': '',
      'en': '',
    },
    'j59fr62k': {
      'fr': 'Resultats lotteries',
      'cr': '',
      'en': '',
    },
    '96ad4c5w': {
      'fr': 'Resultats lotteries',
      'cr': '',
      'en': '',
    },
    'bl4kupme': {
      'fr': '1 Mois',
      'cr': '',
      'en': '',
    },
    'r11k1q8q': {
      'fr': 'USD \$ 40.00 ou GDS 2,000.00',
      'cr': '',
      'en': '',
    },
    'i0zhxntw': {
      'fr': 'Devenir VIP',
      'cr': '',
      'en': '',
    },
  },
  // editProfilTexts
  {
    'etl45w0v': {
      'fr': 'TextField',
      'cr': '',
      'en': '',
    },
    '640x9dq1': {
      'fr': 'Button',
      'cr': '',
      'en': '',
    },
  },
  // bingoCardVIP
  {
    'ch00aogu': {
      'fr': 'Ou te gagné ak nou ?',
      'cr': 'Ou te gagné ak nou ?',
      'en': 'Ou te gagné ak nou ?',
    },
    'ksh6eozy': {
      'fr': 'WI',
      'cr': 'WI',
      'en': 'WI',
    },
    '7ccuyv05': {
      'fr': 'NON',
      'cr': 'NON',
      'en': 'NON',
    },
  },
  // don
  {
    'wydszs2w': {
      'fr': 'Faire un don',
      'cr': 'Fè nou yon don',
      'en': 'Make a Donation',
    },
    '6xxzgm60': {
      'fr':
          'Your contribution helps us continue our mission to make a positive impact in the community.',
      'cr': '',
      'en': '',
    },
    's9v0uvn9': {
      'fr': 'Select Amount',
      'cr': '',
      'en': '',
    },
    '42ir0fto': {
      'fr': '\$10',
      'cr': '',
      'en': '',
    },
    '8igtcp6r': {
      'fr': '\$25',
      'cr': '',
      'en': '',
    },
    'beg6pkjf': {
      'fr': '\$50',
      'cr': '',
      'en': '',
    },
    'ovxdt2ne': {
      'fr': '\$100',
      'cr': '',
      'en': '',
    },
    'cwa7j3cs': {
      'fr': 'Custom Amount',
      'cr': '',
      'en': '',
    },
    '36ocr8q8': {
      'fr': 'Enter amount',
      'cr': '',
      'en': '',
    },
    'kmatu0bj': {
      'fr': 'Payment Method',
      'cr': '',
      'en': '',
    },
    'zgkhgl88': {
      'fr': '•••• •••• •••• 4242',
      'cr': '',
      'en': '',
    },
    'r0jtpvwa': {
      'fr': 'Donate Now',
      'cr': '',
      'en': '',
    },
    'g2sbccpm': {
      'fr': 'Your donation is secure and will be processed safely.',
      'cr': '',
      'en': '',
    },
  },
  // Welcome
  {
    'ser0033p': {
      'fr': 'Continuer avec Google',
      'cr': 'Konekte ak Google',
      'en': 'Connect with Google',
    },
    '7p5qctmz': {
      'fr': 'Connecter en tant qu\'Inviter',
      'cr': 'Antre an tan ke invite',
      'en': 'Guest Mode',
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
      'en': 'TIRAGES',
    },
    'zljfxk4l': {
      'fr': 'VOIR TOUT',
      'cr': 'TOUT',
      'en': 'ALL',
    },
  },
  // storyPage
  {
    'hs9qcniz': {
      'fr': 'TEST 1-2',
      'cr': '',
      'en': '',
    },
    'gbh5c896': {
      'fr': 'Hello World',
      'cr': '',
      'en': '',
    },
  },
  // rappelFinAbonnement
  {
    '6wnv7a6z': {
      'fr':
          'Votre abonnement CHOLOTO VIP expire bientôt. Contactez-Nous dès maintenant pour le renouveler.',
      'cr':
          'Abònman CHOLOTO VIP ou a pa lwen ekspire talè. Kontakte nou depi kounye a pou renouvle li epi kontinye jwi tout avantaj yo.',
      'en':
          'Your CHOLOTO VIP subscription will expire soon. Contact us today to renew your subscription and continue enjoying all the exclusive benefits.',
    },
    'ppbj8s5f': {
      'fr': 'Contactez-Nous',
      'cr': 'Kontakte nou',
      'en': 'Contact US',
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
      'cr': '',
      'en': '',
    },
  },
  // Miscellaneous
  {
    '0ges4wqg': {
      'fr': 'Title',
      'cr': '',
      'en': '',
    },
    'ymcdwy4s': {
      'fr': 'Subtitle',
      'cr': '',
      'en': '',
    },
    'a35mfcuz': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    'nmni0qro': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    'x4kia2ry': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    '7gc9jck6': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    'nvwy6ecy': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    '4zwf23g2': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    'avyqijpp': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    'ayfvgb4r': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    '513ztq3m': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    'dupcuttl': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    '8oak2w6z': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    'le2mw2tl': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    'h5gpkshg': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    'dgzz3vyc': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    'pjs4ywum': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    'cajjvpk8': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    't1relmez': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    'kvsokc1s': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    'qsiyeg83': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    '8a0h7zfb': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    '7z86aawz': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    'jdlqynmz': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    'j2hc2pmp': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    'ifxtrgmf': {
      'fr': '',
      'cr': '',
      'en': '',
    },
    'whkjsdsh': {
      'fr': '',
      'cr': '',
      'en': '',
    },
  },
].reduce((a, b) => a..addAll(b));
