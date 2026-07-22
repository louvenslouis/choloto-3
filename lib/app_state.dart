import 'package:flutter/material.dart';
import 'flutter_flow/request_manager.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/api_requests/api_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'dart:convert';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      if (prefs.containsKey('ff_okay')) {
        try {
          _okay = jsonDecode(prefs.getString('ff_okay') ?? '');
        } catch (e) {
          print("Can't decode persisted json. Error: $e.");
        }
      }
    });
    _safeInit(() {
      _subscriber = prefs.containsKey('ff_subscriber')
          ? DateTime.fromMillisecondsSinceEpoch(prefs.getInt('ff_subscriber')!)
          : _subscriber;
    });
    _safeInit(() {
      _user = prefs.getString('ff_user') ?? _user;
    });
    _safeInit(() {
      if (prefs.containsKey('ff_bingo')) {
        try {
          final serializedData = prefs.getString('ff_bingo') ?? '{}';
          _bingo = BingoStruct.fromSerializableMap(jsonDecode(serializedData));
        } catch (e) {
          print("Can't decode persisted data type. Error: $e.");
        }
      }
    });
    _safeInit(() {
      _haiti = prefs
              .getStringList('ff_haiti')
              ?.map((x) => DateTime.fromMillisecondsSinceEpoch(int.parse(x)))
              .toList() ??
          _haiti;
    });
    _safeInit(() {
      if (prefs.containsKey('ff_betaFeatures')) {
        try {
          final serializedData = prefs.getString('ff_betaFeatures') ?? '{}';
          _betaFeatures = BetaFeaturesStruct.fromSerializableMap(
              jsonDecode(serializedData));
        } catch (e) {
          print("Can't decode persisted data type. Error: $e.");
        }
      }
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  dynamic _okay;
  dynamic get okay => _okay;
  set okay(dynamic value) {
    _okay = value;
    prefs.setString('ff_okay', jsonEncode(value));
  }

  DateTime? _subscriber;
  DateTime? get subscriber => _subscriber;
  set subscriber(DateTime? value) {
    _subscriber = value;
    value != null
        ? prefs.setInt('ff_subscriber', value.millisecondsSinceEpoch)
        : prefs.remove('ff_subscriber');
  }

  String _user = 'Invité';
  String get user => _user;
  set user(String value) {
    _user = value;
    prefs.setString('ff_user', value);
  }

  dynamic _tchala = jsonDecode(
      '[{\"symbole_kreyol\":\"Achte\",\"traduction_francais\":\"Achat\",\"numeros_associes\":[55,7,76,36]},{\"symbole_kreyol\":\"Adiltè\",\"traduction_francais\":\"Adultère\",\"numeros_associes\":[29,58,69,28]},{\"symbole_kreyol\":\"Akouchman\",\"traduction_francais\":\"Accouchement\",\"numeros_associes\":[32,56,11,33]},{\"symbole_kreyol\":\"Aksidan\",\"traduction_francais\":\"Accident\",\"numeros_associes\":[96,6,5,49]},{\"symbole_kreyol\":\"Alimèt\",\"traduction_francais\":\"Allumette\",\"numeros_associes\":[11,8,42]},{\"symbole_kreyol\":\"Altagras\",\"traduction_francais\":\"Mardi Gras\",\"numeros_associes\":[12,21]},{\"symbole_kreyol\":\"Anana\",\"traduction_francais\":\"Ananas\",\"numeros_associes\":[73,19,11]},{\"symbole_kreyol\":\"Anbilans\",\"traduction_francais\":\"Ambulance\",\"numeros_associes\":[30,37,22,42]},{\"symbole_kreyol\":\"Ansent\",\"traduction_francais\":\"Enceinte\",\"numeros_associes\":[20]},{\"symbole_kreyol\":\"Antèman\",\"traduction_francais\":\"Enterrement\",\"numeros_associes\":[9,91,10,66]},{\"symbole_kreyol\":\"Arete\",\"traduction_francais\":\"Arrestation\",\"numeros_associes\":[36,13,24,25]},{\"symbole_kreyol\":\"Atelye\",\"traduction_francais\":\"Atelier\",\"numeros_associes\":[41,47,45,73]},{\"symbole_kreyol\":\"Avyon\",\"traduction_francais\":\"Avion\",\"numeros_associes\":[3,29,47,85,4]},{\"symbole_kreyol\":\"Bag Maryaj\",\"traduction_francais\":\"Bague de mariage\",\"numeros_associes\":[25,59]},{\"symbole_kreyol\":\"Bale\",\"traduction_francais\":\"Balai\",\"numeros_associes\":[55,3,14]},{\"symbole_kreyol\":\"Balèn\",\"traduction_francais\":\"Baleine\",\"numeros_associes\":[65,4,59]},{\"symbole_kreyol\":\"Bank\",\"traduction_francais\":\"Banque\",\"numeros_associes\":[61,15,84,14]},{\"symbole_kreyol\":\"Bannann\",\"traduction_francais\":\"Banane\",\"numeros_associes\":[87,48]},{\"symbole_kreyol\":\"Batay\",\"traduction_francais\":\"Bataille\",\"numeros_associes\":[78,11,19,32]},{\"symbole_kreyol\":\"Bato\",\"traduction_francais\":\"Bateau\",\"numeros_associes\":[18,68]},{\"symbole_kreyol\":\"Baton\",\"traduction_francais\":\"Bâton\",\"numeros_associes\":[43,61]},{\"symbole_kreyol\":\"Baton\",\"traduction_francais\":\"Bâton\",\"numeros_associes\":[89,40,41,88]},{\"symbole_kreyol\":\"Batèm\",\"traduction_francais\":\"Baptême\",\"numeros_associes\":[88,69,58]},{\"symbole_kreyol\":\"Bay Tete\",\"traduction_francais\":\"Allaitement (donner le sein)\",\"numeros_associes\":[19]},{\"symbole_kreyol\":\"Baza\",\"traduction_francais\":\"Bazar\",\"numeros_associes\":[39,62]},{\"symbole_kreyol\":\"Bekàn\",\"traduction_francais\":\"Bicyclette\",\"numeros_associes\":[52,41,78]},{\"symbole_kreyol\":\"Benyen\",\"traduction_francais\":\"Baignade (prendre un bain)\",\"numeros_associes\":[32,25,59]},{\"symbole_kreyol\":\"Bib\",\"traduction_francais\":\"Bébé\",\"numeros_associes\":[32,20]},{\"symbole_kreyol\":\"Bibwon\",\"traduction_francais\":\"Bébé\",\"numeros_associes\":[82,94]},{\"symbole_kreyol\":\"Bèso\",\"traduction_francais\":\"Furoncle\",\"numeros_associes\":[1,36,62,72]},{\"symbole_kreyol\":\"Bijou\",\"traduction_francais\":\"Bijou\",\"numeros_associes\":[53,41,52]},{\"symbole_kreyol\":\"Ble\",\"traduction_francais\":\"Bleu\",\"numeros_associes\":[1,79,9,83]},{\"symbole_kreyol\":\"Blese\",\"traduction_francais\":\"Blesser\",\"numeros_associes\":[9,3,42,62]},{\"symbole_kreyol\":\"Bèf\",\"traduction_francais\":\"Boeuf\",\"numeros_associes\":[16,76,96]},{\"symbole_kreyol\":\"Bwat\",\"traduction_francais\":\"Boîte\",\"numeros_associes\":[81,93]},{\"symbole_kreyol\":\"Bokit\",\"traduction_francais\":\"Seau\",\"numeros_associes\":[49]},{\"symbole_kreyol\":\"Labou\",\"traduction_francais\":\"Boue\",\"numeros_associes\":[6,60,62,82]},{\"symbole_kreyol\":\"Boulanje\",\"traduction_francais\":\"Boulangerie\",\"numeros_associes\":[3,21,32,60]},{\"symbole_kreyol\":\"Bourik\",\"traduction_francais\":\"Âne\",\"numeros_associes\":[53,35,91,14]},{\"symbole_kreyol\":\"Bous\",\"traduction_francais\":\"Sacoche\",\"numeros_associes\":[2,60,10,69]},{\"symbole_kreyol\":\"Bourèt\",\"traduction_francais\":\"Bobine\",\"numeros_associes\":[41]},{\"symbole_kreyol\":\"Kabrit\",\"traduction_francais\":\"Chèvre\",\"numeros_associes\":[28,82]},{\"symbole_kreyol\":\"Kado\",\"traduction_francais\":\"Cadeau\",\"numeros_associes\":[41,11,30,5]},{\"symbole_kreyol\":\"Kadna\",\"traduction_francais\":\"Cadenas\",\"numeros_associes\":[97,61,22,5]},{\"symbole_kreyol\":\"Kafe\",\"traduction_francais\":\"Café\",\"numeros_associes\":[68,27,6]},{\"symbole_kreyol\":\"Kaye\",\"traduction_francais\":\"Cahier\",\"numeros_associes\":[32]},{\"symbole_kreyol\":\"Kayiman\",\"traduction_francais\":\"Caiman\",\"numeros_associes\":[29,90,60]},{\"symbole_kreyol\":\"Kana\",\"traduction_francais\":\"Canne\",\"numeros_associes\":[41,42,22]},{\"symbole_kreyol\":\"Kanaval\",\"traduction_francais\":\"Carnaval\",\"numeros_associes\":[66,67]},{\"symbole_kreyol\":\"Kazên\",\"traduction_francais\":\"Caserne\",\"numeros_associes\":[0,56,31]},{\"symbole_kreyol\":\"Katedral\",\"traduction_francais\":\"Cathédrale\",\"numeros_associes\":[64,16,8,21]},{\"symbole_kreyol\":\"Sékéy\",\"traduction_francais\":\"Cercueil\",\"numeros_associes\":[22,31]},{\"symbole_kreyol\":\"Seremoni\",\"traduction_francais\":\"Cérémonie\",\"numeros_associes\":[2,7]},{\"symbole_kreyol\":\"Kap\",\"traduction_francais\":\"Casquette\",\"numeros_associes\":[32,3,21,4]},{\"symbole_kreyol\":\"Chèn\",\"traduction_francais\":\"Chaîne\",\"numeros_associes\":[42,73]},{\"symbole_kreyol\":\"Chèz\",\"traduction_francais\":\"Chaise\",\"numeros_associes\":[63,16,73]},{\"symbole_kreyol\":\"Chantye\",\"traduction_francais\":\"Chantier\",\"numeros_associes\":[32,85]},{\"symbole_kreyol\":\"Chapo\",\"traduction_francais\":\"Chapeau\",\"numeros_associes\":[20,28,71,11]},{\"symbole_kreyol\":\"Chaplè\",\"traduction_francais\":\"Chapelle\",\"numeros_associes\":[4,32]},{\"symbole_kreyol\":\"Chabon\",\"traduction_francais\":\"Charbon\",\"numeros_associes\":[85,59,7,30]},{\"symbole_kreyol\":\"Chasè\",\"traduction_francais\":\"Chasseur\",\"numeros_associes\":[9,59,99]},{\"symbole_kreyol\":\"Chat\",\"traduction_francais\":\"Chat\",\"numeros_associes\":[74,4,14,84]},{\"symbole_kreyol\":\"Chef\",\"traduction_francais\":\"Chef (cuisinier)\",\"numeros_associes\":[22]},{\"symbole_kreyol\":\"Chen\",\"traduction_francais\":\"Chien\",\"numeros_associes\":[15,75,95]},{\"symbole_kreyol\":\"Syèl\",\"traduction_francais\":\"Ciel\",\"numeros_associes\":[66,89]},{\"symbole_kreyol\":\"Simityè\",\"traduction_francais\":\"Cimetière\",\"numeros_associes\":[3,13]},{\"symbole_kreyol\":\"Sinema\",\"traduction_francais\":\"Cinéma\",\"numeros_associes\":[75]},{\"symbole_kreyol\":\"Kleren\",\"traduction_francais\":\"Clairin (rhum)\",\"numeros_associes\":[49,14,40,36]},{\"symbole_kreyol\":\"Kle\",\"traduction_francais\":\"Clé\",\"numeros_associes\":[5,64,41]},{\"symbole_kreyol\":\"Klôch\",\"traduction_francais\":\"Cloche\",\"numeros_associes\":[3,27,48,25]},{\"symbole_kreyol\":\"Klou\",\"traduction_francais\":\"Clou\",\"numeros_associes\":[67,27,22]},{\"symbole_kreyol\":\"Kochon\",\"traduction_francais\":\"Cochon\",\"numeros_associes\":[58,32,22]},{\"symbole_kreyol\":\"Kômès\",\"traduction_francais\":\"Commerce\",\"numeros_associes\":[74,77]},{\"symbole_kreyol\":\"Kondui\",\"traduction_francais\":\"Conduire\",\"numeros_associes\":[3,21,62]},{\"symbole_kreyol\":\"Konstriksyon\",\"traduction_francais\":\"Construction\",\"numeros_associes\":[32,19]},{\"symbole_kreyol\":\"Kôk\",\"traduction_francais\":\"Coq\",\"numeros_associes\":[11,71,1,32]},{\"symbole_kreyol\":\"Kôk Batay\",\"traduction_francais\":\"Coq de combat\",\"numeros_associes\":[11,15,64]},{\"symbole_kreyol\":\"Kôbya\",\"traduction_francais\":\"Cochon d\'Inde\",\"numeros_associes\":[4,22,61]},{\"symbole_kreyol\":\"Kostim\",\"traduction_francais\":\"Costume\",\"numeros_associes\":[44,23,84]},{\"symbole_kreyol\":\"Koulèv\",\"traduction_francais\":\"Couleuvre\",\"numeros_associes\":[39,21,72]},{\"symbole_kreyol\":\"Kou\",\"traduction_francais\":\"Cou\",\"numeros_associes\":[8,60]},{\"symbole_kreyol\":\"Kouto\",\"traduction_francais\":\"Couteau\",\"numeros_associes\":[58,54,37,9]},{\"symbole_kreyol\":\"Krab\",\"traduction_francais\":\"Crabe\",\"numeros_associes\":[55,30]},{\"symbole_kreyol\":\"Krè\",\"traduction_francais\":\"Craie\",\"numeros_associes\":[28,19,46,62]},{\"symbole_kreyol\":\"Krapo\",\"traduction_francais\":\"Crapaud\",\"numeros_associes\":[28,73]},{\"symbole_kreyol\":\"Krapo\",\"traduction_francais\":\"Crapaud\",\"numeros_associes\":[22,9,75]},{\"symbole_kreyol\":\"Kreyon\",\"traduction_francais\":\"Crayon\",\"numeros_associes\":[1,11]},{\"symbole_kreyol\":\"Kaka\",\"traduction_francais\":\"Excrément\",\"numeros_associes\":[7]},{\"symbole_kreyol\":\"Kivèt\",\"traduction_francais\":\"Bassin (crucifix)\",\"numeros_associes\":[30,14,64]},{\"symbole_kreyol\":\"Kizin\",\"traduction_francais\":\"Cuisine\",\"numeros_associes\":[24]},{\"symbole_kreyol\":\"Kwa\",\"traduction_francais\":\"Croix\",\"numeros_associes\":[10,40,33]},{\"symbole_kreyol\":\"Krich\",\"traduction_francais\":\"Porc-épic\",\"numeros_associes\":[6,42,81,28]},{\"symbole_kreyol\":\"Kribich\",\"traduction_francais\":\"Écrevisse\",\"numeros_associes\":[30,31,32]},{\"symbole_kreyol\":\"Danse\",\"traduction_francais\":\"Danse\",\"numeros_associes\":[79,8,86,39]},{\"symbole_kreyol\":\"Dan\",\"traduction_francais\":\"Dent\",\"numeros_associes\":[31,58,15]},{\"symbole_kreyol\":\"Drapo\",\"traduction_francais\":\"Drapeau\",\"numeros_associes\":[77,73,14,24]},{\"symbole_kreyol\":\"Dlo\",\"traduction_francais\":\"Eau\",\"numeros_associes\":[89,22,5,51]},{\"symbole_kreyol\":\"Echèl\",\"traduction_francais\":\"Échelle\",\"numeros_associes\":[65,3,25,62]},{\"symbole_kreyol\":\"Ekri\",\"traduction_francais\":\"Écrire\",\"numeros_associes\":[7,21,32]},{\"symbole_kreyol\":\"Pèdi\",\"traduction_francais\":\"Perdre\",\"numeros_associes\":[51,54,74]},{\"symbole_kreyol\":\"Egliz\",\"traduction_francais\":\"Église\",\"numeros_associes\":[95,75,18]},{\"symbole_kreyol\":\"Eleksyon\",\"traduction_francais\":\"Élection\",\"numeros_associes\":[68]},{\"symbole_kreyol\":\"Ènmi\",\"traduction_francais\":\"Ennemi\",\"numeros_associes\":[60,4,73,32]},{\"symbole_kreyol\":\"Envazyon\",\"traduction_francais\":\"Invasion\",\"numeros_associes\":[1,51,20]},{\"symbole_kreyol\":\"Inondasyon\",\"traduction_francais\":\"Inondation\",\"numeros_associes\":[32,85]},{\"symbole_kreyol\":\"Ensidan\",\"traduction_francais\":\"Incident\",\"numeros_associes\":[4,27,61,83]},{\"symbole_kreyol\":\"Enjistis\",\"traduction_francais\":\"Injustice\",\"numeros_associes\":[82,61]},{\"symbole_kreyol\":\"Jalouzi\",\"traduction_francais\":\"Jalousie\",\"numeros_associes\":[5,22,80]},{\"symbole_kreyol\":\"Jaden\",\"traduction_francais\":\"Jardin\",\"numeros_associes\":[41,1,32]},{\"symbole_kreyol\":\"Ja\",\"traduction_francais\":\"Rhum\",\"numeros_associes\":[31,86]},{\"symbole_kreyol\":\"Jwèt\",\"traduction_francais\":\"Jeu\",\"numeros_associes\":[14,52,21,62]},{\"symbole_kreyol\":\"Journal\",\"traduction_francais\":\"Journal\",\"numeros_associes\":[96,21,62]},{\"symbole_kreyol\":\"Jij\",\"traduction_francais\":\"Juge\",\"numeros_associes\":[42,89,51]},{\"symbole_kreyol\":\"Jipon\",\"traduction_francais\":\"Jupe\",\"numeros_associes\":[80,95]},{\"symbole_kreyol\":\"Kola\",\"traduction_francais\":\"Cola\",\"numeros_associes\":[16,85]},{\"symbole_kreyol\":\"Kodak\",\"traduction_francais\":\"Caméra\",\"numeros_associes\":[86,4]},{\"symbole_kreyol\":\"Laboure\",\"traduction_francais\":\"Labourer\",\"numeros_associes\":[1,29,41,91]},{\"symbole_kreyol\":\"Lenn\",\"traduction_francais\":\"Laine\",\"numeros_associes\":[4,45,78]},{\"symbole_kreyol\":\"Lèt\",\"traduction_francais\":\"Lait\",\"numeros_associes\":[75,72,13]},{\"symbole_kreyol\":\"Latrin\",\"traduction_francais\":\"Latrine\",\"numeros_associes\":[5,81]},{\"symbole_kreyol\":\"Lave\",\"traduction_francais\":\"Laver\",\"numeros_associes\":[30,66,28]},{\"symbole_kreyol\":\"Legim\",\"traduction_francais\":\"Légume\",\"numeros_associes\":[47,29]},{\"symbole_kreyol\":\"Lesiv\",\"traduction_francais\":\"Lessive\",\"numeros_associes\":[3,30]},{\"symbole_kreyol\":\"Lèt (Ekri)\",\"traduction_francais\":\"Lettre\",\"numeros_associes\":[66,12]},{\"symbole_kreyol\":\"Lenj\",\"traduction_francais\":\"Linge\",\"numeros_associes\":[27,43,65,75]},{\"symbole_kreyol\":\"Lyon\",\"traduction_francais\":\"Lion\",\"numeros_associes\":[4,42]},{\"symbole_kreyol\":\"Li\",\"traduction_francais\":\"Lire\",\"numeros_associes\":[7,6,42]},{\"symbole_kreyol\":\"Kabann\",\"traduction_francais\":\"Lit\",\"numeros_associes\":[57,59,46]},{\"symbole_kreyol\":\"Liv\",\"traduction_francais\":\"Livre\",\"numeros_associes\":[43]},{\"symbole_kreyol\":\"Lougawou\",\"traduction_francais\":\"Loup-garou\",\"numeros_associes\":[37,47]},{\"symbole_kreyol\":\"Limyè\",\"traduction_francais\":\"Lumière\",\"numeros_associes\":[28,80,42]},{\"symbole_kreyol\":\"Lalin\",\"traduction_francais\":\"Lune\",\"numeros_associes\":[15,41,17,6]},{\"symbole_kreyol\":\"Linèt\",\"traduction_francais\":\"Lunettes\",\"numeros_associes\":[88,85,52]},{\"symbole_kreyol\":\"Magazen\",\"traduction_francais\":\"Magasin\",\"numeros_associes\":[37,22]},{\"symbole_kreyol\":\"Mayi an gren\",\"traduction_francais\":\"Mais\",\"numeros_associes\":[20,18,97]},{\"symbole_kreyol\":\"Mayi Moulen\",\"traduction_francais\":\"Semoule\",\"numeros_associes\":[27]},{\"symbole_kreyol\":\"Majistra\",\"traduction_francais\":\"Magistrat\",\"numeros_associes\":[0,50,21]},{\"symbole_kreyol\":\"Malad\",\"traduction_francais\":\"Malade\",\"numeros_associes\":[66,67,58,75]},{\"symbole_kreyol\":\"Manje\",\"traduction_francais\":\"Manger\",\"numeros_associes\":[57,40]},{\"symbole_kreyol\":\"Machann\",\"traduction_francais\":\"Marchand\",\"numeros_associes\":[7]},{\"symbole_kreyol\":\"Mache\",\"traduction_francais\":\"Marcher\",\"numeros_associes\":[27,25]},{\"symbole_kreyol\":\"Madigra\",\"traduction_francais\":\"Mardi Gras\",\"numeros_associes\":[37,11,77]},{\"symbole_kreyol\":\"Mato\",\"traduction_francais\":\"Marteau\",\"numeros_associes\":[51,62]},{\"symbole_kreyol\":\"Matla\",\"traduction_francais\":\"Matelas\",\"numeros_associes\":[4,3]},{\"symbole_kreyol\":\"Mekanik\",\"traduction_francais\":\"Mécanicien\",\"numeros_associes\":[21,63]},{\"symbole_kreyol\":\"Melon\",\"traduction_francais\":\"Melon\",\"numeros_associes\":[11,82,29,62]},{\"symbole_kreyol\":\"Lamès\",\"traduction_francais\":\"Messe\",\"numeros_associes\":[92,93,5]},{\"symbole_kreyol\":\"Mèb\",\"traduction_francais\":\"Meubles\",\"numeros_associes\":[20]},{\"symbole_kreyol\":\"Glas (miroir)\",\"traduction_francais\":\"Verre/miroir\",\"numeros_associes\":[29,84,22]},{\"symbole_kreyol\":\"Monsegnè\",\"traduction_francais\":\"Monseigneur\",\"numeros_associes\":[78,79]},{\"symbole_kreyol\":\"Môn\",\"traduction_francais\":\"Montagne\",\"numeros_associes\":[12,50]},{\"symbole_kreyol\":\"Metrès\",\"traduction_francais\":\"Maîtresse\",\"numeros_associes\":[13,22,0]},{\"symbole_kreyol\":\"Mont\",\"traduction_francais\":\"Montre\",\"numeros_associes\":[25,90,21]},{\"symbole_kreyol\":\"Moun mouri\",\"traduction_francais\":\"Mort\",\"numeros_associes\":[8,33,74]},{\"symbole_kreyol\":\"Motosikiêt\",\"traduction_francais\":\"Moto\",\"numeros_associes\":[53,21]},{\"symbole_kreyol\":\"Mouch\",\"traduction_francais\":\"Mouche\",\"numeros_associes\":[45,25,9]},{\"symbole_kreyol\":\"Mouchwa\",\"traduction_francais\":\"Mouchoir\",\"numeros_associes\":[84]},{\"symbole_kreyol\":\"Moustik\",\"traduction_francais\":\"Moustique\",\"numeros_associes\":[35,96]},{\"symbole_kreyol\":\"Mizisyen\",\"traduction_francais\":\"Musicien\",\"numeros_associes\":[39]},{\"symbole_kreyol\":\"Mi\",\"traduction_francais\":\"Mur\",\"numeros_associes\":[44,67]},{\"symbole_kreyol\":\"Milèt\",\"traduction_francais\":\"Millet\",\"numeros_associes\":[34,43]},{\"symbole_kreyol\":\"Miskad\",\"traduction_francais\":\"Muscade\",\"numeros_associes\":[10,45,28,65]},{\"symbole_kreyol\":\"Ze\",\"traduction_francais\":\"Œuf\",\"numeros_associes\":[60,0,13,16,75,87]},{\"symbole_kreyol\":\"Parapli\",\"traduction_francais\":\"Parapluie\",\"numeros_associes\":[27,57]},{\"symbole_kreyol\":\"Parapli (bis)\",\"traduction_francais\":\"Parapluie\",\"numeros_associes\":[80,57,21]},{\"symbole_kreyol\":\"Zwazo\",\"traduction_francais\":\"Oiseau\",\"numeros_associes\":[47,60,27,2]},{\"symbole_kreyol\":\"Loray\",\"traduction_francais\":\"Orage\",\"numeros_associes\":[44,99,22,47]},{\"symbole_kreyol\":\"Zoranj\",\"traduction_francais\":\"Orange\",\"numeros_associes\":[44,2,40,13]},{\"symbole_kreyol\":\"Zouti\",\"traduction_francais\":\"Outil\",\"numeros_associes\":[29]},{\"symbole_kreyol\":\"Pay\",\"traduction_francais\":\"Paille\",\"numeros_associes\":[27,48,41,4]},{\"symbole_kreyol\":\"Pen\",\"traduction_francais\":\"Pain\",\"numeros_associes\":[60,33,58,50]},{\"symbole_kreyol\":\"Palè\",\"traduction_francais\":\"Palais\",\"numeros_associes\":[53,9]},{\"symbole_kreyol\":\"Panye\",\"traduction_francais\":\"Panier\",\"numeros_associes\":[19,69,89]},{\"symbole_kreyol\":\"Pantalon\",\"traduction_francais\":\"Pantalon\",\"numeros_associes\":[88,20,77]},{\"symbole_kreyol\":\"Papye\",\"traduction_francais\":\"Papier\",\"numeros_associes\":[79,7]},{\"symbole_kreyol\":\"Papiyon\",\"traduction_francais\":\"Papillon\",\"numeros_associes\":[2,94,12,35]},{\"symbole_kreyol\":\"Pafen\",\"traduction_francais\":\"Parfum\",\"numeros_associes\":[91,23]},{\"symbole_kreyol\":\"Paspô\",\"traduction_francais\":\"Passeport\",\"numeros_associes\":[79,15]},{\"symbole_kreyol\":\"Patat\",\"traduction_francais\":\"Patate\",\"numeros_associes\":[3,30]},{\"symbole_kreyol\":\"Pate\",\"traduction_francais\":\"Pâté\",\"numeros_associes\":[89,2]},{\"symbole_kreyol\":\"Pyano\",\"traduction_francais\":\"Piano\",\"numeros_associes\":[98,99,29]},{\"symbole_kreyol\":\"Pijon\",\"traduction_francais\":\"Pigeon\",\"numeros_associes\":[24,15]},{\"symbole_kreyol\":\"Piman\",\"traduction_francais\":\"Piment\",\"numeros_associes\":[71]},{\"symbole_kreyol\":\"Pentad\",\"traduction_francais\":\"Pintade\",\"numeros_associes\":[33,13,73]},{\"symbole_kreyol\":\"Pip\",\"traduction_francais\":\"Pipe\",\"numeros_associes\":[56,12,17]},{\"symbole_kreyol\":\"Plenn\",\"traduction_francais\":\"Plaine\",\"numeros_associes\":[72,21,26,43]},{\"symbole_kreyol\":\"Planch\",\"traduction_francais\":\"Planche\",\"numeros_associes\":[81,88]},{\"symbole_kreyol\":\"Plante\",\"traduction_francais\":\"Planter\",\"numeros_associes\":[97]},{\"symbole_kreyol\":\"Lapli\",\"traduction_francais\":\"Pluie\",\"numeros_associes\":[11,22,99,21]},{\"symbole_kreyol\":\"Plim\",\"traduction_francais\":\"Plume\",\"numeros_associes\":[7,22,33,18]},{\"symbole_kreyol\":\"Pwa\",\"traduction_francais\":\"Pois\",\"numeros_associes\":[87,19,90]},{\"symbole_kreyol\":\"Pwason\",\"traduction_francais\":\"Poisson\",\"numeros_associes\":[27,18,78]},{\"symbole_kreyol\":\"Lapolis\",\"traduction_francais\":\"Police\",\"numeros_associes\":[4,44]},{\"symbole_kreyol\":\"Pòm\",\"traduction_francais\":\"Pomme\",\"numeros_associes\":[28,59]},{\"symbole_kreyol\":\"Pon\",\"traduction_francais\":\"Pont\",\"numeros_associes\":[12,73]},{\"symbole_kreyol\":\"Poul\",\"traduction_francais\":\"Poule\",\"numeros_associes\":[23,70,37]},{\"symbole_kreyol\":\"Prezidan\",\"traduction_francais\":\"Président\",\"numeros_associes\":[11,26,45,79]},{\"symbole_kreyol\":\"Pè\",\"traduction_francais\":\"Père\",\"numeros_associes\":[45,16]},{\"symbole_kreyol\":\"Pinèz\",\"traduction_francais\":\"Punaise\",\"numeros_associes\":[97,99,30]},{\"symbole_kreyol\":\"Bouzen\",\"traduction_francais\":\"Prostituée\",\"numeros_associes\":[66,21]},{\"symbole_kreyol\":\"Radyo\",\"traduction_francais\":\"Radio\",\"numeros_associes\":[43,24]},{\"symbole_kreyol\":\"Rezen\",\"traduction_francais\":\"Raisin\",\"numeros_associes\":[19,90,42]},{\"symbole_kreyol\":\"Rara\",\"traduction_francais\":\"Rara (fête)\",\"numeros_associes\":[79,97]},{\"symbole_kreyol\":\"Rat\",\"traduction_francais\":\"Rat\",\"numeros_associes\":[29,90,26]},{\"symbole_kreyol\":\"Ravèt\",\"traduction_francais\":\"Cafard\",\"numeros_associes\":[48,33,30]},{\"symbole_kreyol\":\"Ravin\",\"traduction_francais\":\"Ravin\",\"numeros_associes\":[1]},{\"symbole_kreyol\":\"Recho\",\"traduction_francais\":\"Réchaud\",\"numeros_associes\":[13]},{\"symbole_kreyol\":\"Reken\",\"traduction_francais\":\"Requin\",\"numeros_associes\":[45]},{\"symbole_kreyol\":\"Rèn\",\"traduction_francais\":\"Reine\",\"numeros_associes\":[56,31,82]},{\"symbole_kreyol\":\"Restoran\",\"traduction_francais\":\"Restaurant\",\"numeros_associes\":[68,28,78]},{\"symbole_kreyol\":\"Zam\",\"traduction_francais\":\"Revolver\",\"numeros_associes\":[44,45,30]},{\"symbole_kreyol\":\"Richès\",\"traduction_francais\":\"Richesse\",\"numeros_associes\":[50,51]},{\"symbole_kreyol\":\"Rido\",\"traduction_francais\":\"Rideau\",\"numeros_associes\":[51,53,45]},{\"symbole_kreyol\":\"Rigôl\",\"traduction_francais\":\"Rigole\",\"numeros_associes\":[56,85]},{\"symbole_kreyol\":\"Ri\",\"traduction_francais\":\"Rire\",\"numeros_associes\":[64,13]},{\"symbole_kreyol\":\"Rivyè klè\",\"traduction_francais\":\"Rivière claire\",\"numeros_associes\":[19,33]},{\"symbole_kreyol\":\"Rivyè sal\",\"traduction_francais\":\"Rivière sale\",\"numeros_associes\":[7,9,23]},{\"symbole_kreyol\":\"Wòb\",\"traduction_francais\":\"Robe\",\"numeros_associes\":[2,51,21,75]},{\"symbole_kreyol\":\"Wòch\",\"traduction_francais\":\"Roche\",\"numeros_associes\":[25,96,21]},{\"symbole_kreyol\":\"Wa\",\"traduction_francais\":\"Roi\",\"numeros_associes\":[27,56,78]},{\"symbole_kreyol\":\"Woz\",\"traduction_francais\":\"Rose\",\"numeros_associes\":[32,35]},{\"symbole_kreyol\":\"Sab\",\"traduction_francais\":\"Sable\",\"numeros_associes\":[89,97]},{\"symbole_kreyol\":\"Sak\",\"traduction_francais\":\"Sac\",\"numeros_associes\":[33,78]},{\"symbole_kreyol\":\"San\",\"traduction_francais\":\"Sang\",\"numeros_associes\":[45,61,5]},{\"symbole_kreyol\":\"Sandal\",\"traduction_francais\":\"Sandale\",\"numeros_associes\":[9,52]},{\"symbole_kreyol\":\"Sosis\",\"traduction_francais\":\"Saucisse\",\"numeros_associes\":[8,97,22]},{\"symbole_kreyol\":\"Savon\",\"traduction_francais\":\"Savon\",\"numeros_associes\":[76,34,15,92]},{\"symbole_kreyol\":\"Sèl\",\"traduction_francais\":\"Sel\",\"numeros_associes\":[9,16,18]},{\"symbole_kreyol\":\"Siwo\",\"traduction_francais\":\"Sirop\",\"numeros_associes\":[82,90]},{\"symbole_kreyol\":\"Swaf\",\"traduction_francais\":\"Soif\",\"numeros_associes\":[25,75,51]},{\"symbole_kreyol\":\"Solèy\",\"traduction_francais\":\"Soleil\",\"numeros_associes\":[61,25,33]},{\"symbole_kreyol\":\"Soulye\",\"traduction_francais\":\"Chaussures\",\"numeros_associes\":[88,11,28]},{\"symbole_kreyol\":\"Soup\",\"traduction_francais\":\"Soupe\",\"numeros_associes\":[38,45,58]},{\"symbole_kreyol\":\"Sourit\",\"traduction_francais\":\"Souris\",\"numeros_associes\":[15,29,5,89]},{\"symbole_kreyol\":\"Soutyen\",\"traduction_francais\":\"Soutien\",\"numeros_associes\":[61,6,43]},{\"symbole_kreyol\":\"Sik\",\"traduction_francais\":\"Sucre\",\"numeros_associes\":[6]},{\"symbole_kreyol\":\"Sirèt\",\"traduction_francais\":\"Sucette\",\"numeros_associes\":[38,51,56]},{\"symbole_kreyol\":\"Estati\",\"traduction_francais\":\"Statue\",\"numeros_associes\":[19,55,66]},{\"symbole_kreyol\":\"Tabak\",\"traduction_francais\":\"Tabac\",\"numeros_associes\":[21,32,43,51]},{\"symbole_kreyol\":\"Rab\",\"traduction_francais\":\"Raboter\",\"numeros_associes\":[37,4]},{\"symbole_kreyol\":\"Tablo\",\"traduction_francais\":\"Tableau\",\"numeros_associes\":[17,60]},{\"symbole_kreyol\":\"Tanbou\",\"traduction_francais\":\"Tambour\",\"numeros_associes\":[30,28]},{\"symbole_kreyol\":\"Tapi\",\"traduction_francais\":\"Tapis\",\"numeros_associes\":[17]},{\"symbole_kreyol\":\"Telefôn\",\"traduction_francais\":\"Téléphone\",\"numeros_associes\":[70]},{\"symbole_kreyol\":\"Teren\",\"traduction_francais\":\"Terrain\",\"numeros_associes\":[65]},{\"symbole_kreyol\":\"Teyat\",\"traduction_francais\":\"Théâtre\",\"numeros_associes\":[80,2]},{\"symbole_kreyol\":\"Tòl\",\"traduction_francais\":\"Tôle\",\"numeros_associes\":[63]},{\"symbole_kreyol\":\"Tomat\",\"traduction_francais\":\"Tomate\",\"numeros_associes\":[74,45]},{\"symbole_kreyol\":\"Tonb\",\"traduction_francais\":\"Tombe\",\"numeros_associes\":[67,8]},{\"symbole_kreyol\":\"Tren\",\"traduction_francais\":\"Train\",\"numeros_associes\":[73,12,70]},{\"symbole_kreyol\":\"Travay\",\"traduction_francais\":\"Travail\",\"numeros_associes\":[54,25,78]},{\"symbole_kreyol\":\"Tribunal\",\"traduction_francais\":\"Tribunal\",\"numeros_associes\":[35,37]},{\"symbole_kreyol\":\"Twou\",\"traduction_francais\":\"Trou\",\"numeros_associes\":[7,9]},{\"symbole_kreyol\":\"Twonpèt\",\"traduction_francais\":\"Trompette\",\"numeros_associes\":[32]},{\"symbole_kreyol\":\"Tiyo\",\"traduction_francais\":\"Tuyau\",\"numeros_associes\":[22,5,34]},{\"symbole_kreyol\":\"Izin\",\"traduction_francais\":\"Usine\",\"numeros_associes\":[19,27]},{\"symbole_kreyol\":\"Van\",\"traduction_francais\":\"Vent\",\"numeros_associes\":[75,86,32]},{\"symbole_kreyol\":\"Vòlè\",\"traduction_francais\":\"Voler\",\"numeros_associes\":[59,47,7]},{\"symbole_kreyol\":\"Vwayaj\",\"traduction_francais\":\"Voyage\",\"numeros_associes\":[44,61,92,16,8,21]}]');
  dynamic get tchala => _tchala;
  set tchala(dynamic value) {
    _tchala = value;
  }

  dynamic _saints = jsonDecode(
      '[{\"mois\":\"Janvier\",\"saints\":[{\"saint\":\"Odilon\",\"date\":\"2025-01-04\"},{\"saint\":\"Rémi\",\"date\":\"2025-01-15\"},{\"saint\":\"Marcel\",\"date\":\"2025-01-16\"},{\"saint\":\"Roseline\",\"date\":\"2025-01-17\"},{\"saint\":\"Prisca\",\"date\":\"2025-01-18\"},{\"saint\":\"Marius\",\"date\":\"2025-01-19\"},{\"saint\":\"Sébastien\",\"date\":\"2025-01-20\"},{\"saint\":\"Agnès\",\"date\":\"2025-01-21\"},{\"saint\":\"Vincent\",\"date\":\"2025-01-22\"},{\"saint\":\"Barnard\",\"date\":\"2025-01-23\"},{\"saint\":\"Armand\",\"date\":\"2025-01-23\"},{\"saint\":\"Natacha\",\"date\":\"2025-01-26\"},{\"saint\":\"Angèle\",\"date\":\"2025-01-27\"},{\"saint\":\"Martine\",\"date\":\"2025-01-30\"},{\"saint\":\"Marcelle\",\"date\":\"2025-01-31\"}]},{\"mois\":\"Février\",\"saints\":[{\"saint\":\"Blaise\",\"date\":\"2025-02-03\"},{\"saint\":\"Sylvain\",\"date\":\"2025-02-04\"},{\"saint\":\"Apolline\",\"date\":\"2025-02-09\"},{\"saint\":\"Jacqueline\",\"date\":\"2025-02-08\"},{\"saint\":\"Claude\",\"date\":\"2025-02-15\"},{\"saint\":\"Matthias\",\"date\":\"2025-02-14\"},{\"saint\":\"Béatrice\",\"date\":\"2025-02-13\"},{\"saint\":\"Isabelle\",\"date\":\"2025-02-22\"},{\"saint\":\"Pierre Damien\",\"date\":\"2025-02-21\"},{\"saint\":\"Aimée\",\"date\":\"2025-02-20\"},{\"saint\":\"Gabin\",\"date\":\"2025-02-19\"},{\"saint\":\"Modeste\",\"date\":\"2025-02-24\"},{\"saint\":\"Lazare\",\"date\":\"2025-02-23\"},{\"saint\":\"Roméo\",\"date\":\"2025-02-25\"},{\"saint\":\"Nestor\",\"date\":\"2025-02-26\"},{\"saint\":\"Honorine\",\"date\":\"2025-02-27\"},{\"saint\":\"Séverin\",\"date\":\"2025-02-27\"},{\"saint\":\"Romain\",\"date\":\"2025-02-28\"}]},{\"mois\":\"Mars\",\"saints\":[{\"saint\":\"Guénolé\",\"date\":\"2025-03-03\"},{\"saint\":\"Casimir\",\"date\":\"2025-03-04\"},{\"saint\":\"Félicité\",\"date\":\"2025-03-07\"},{\"saint\":\"Jean de Dieu\",\"date\":\"2025-03-08\"},{\"saint\":\"Françoise Amour\",\"date\":\"2025-03-09\"},{\"saint\":\"Rosine\",\"date\":\"2025-03-11\"},{\"saint\":\"Rodrigue\",\"date\":\"2025-03-13\"},{\"saint\":\"Louise\",\"date\":\"2025-03-15\"},{\"saint\":\"Benoît-Joseph\",\"date\":\"2025-03-16\"},{\"saint\":\"Joseph\",\"date\":\"2025-03-19\"},{\"saint\":\"Herbert\",\"date\":\"2025-03-20\"},{\"saint\":\"Clémence\",\"date\":\"2025-03-21\"},{\"saint\":\"Léa\",\"date\":\"2025-03-22\"},{\"saint\":\"Habib\",\"date\":\"2025-03-27\"},{\"saint\":\"Gontran\",\"date\":\"2025-03-28\"},{\"saint\":\"Gwladys\",\"date\":\"2025-03-29\"},{\"saint\":\"Benjamin\",\"date\":\"2025-03-31\"}]},{\"mois\":\"Avril\",\"saints\":[{\"saint\":\"Isidore\",\"date\":\"2025-04-04\"},{\"saint\":\"Irène\",\"date\":\"2025-04-05\"},{\"saint\":\"Mariette\",\"date\":\"2025-04-05\"},{\"saint\":\"Marcellin\",\"date\":\"2025-04-06\"},{\"saint\":\"J-B. de la Salle\",\"date\":\"2025-04-07\"},{\"saint\":\"Julie\",\"date\":\"2025-04-08\"},{\"saint\":\"Gautier\",\"date\":\"2025-04-09\"},{\"saint\":\"Fulbert\",\"date\":\"2025-04-10\"},{\"saint\":\"Inès\",\"date\":\"2025-04-10\"},{\"saint\":\"Stanislas\",\"date\":\"2025-04-11\"},{\"saint\":\"Jules\",\"date\":\"2025-04-12\"},{\"saint\":\"Paterne\",\"date\":\"2025-04-15\"},{\"saint\":\"Évrard\",\"date\":\"2025-04-14\"},{\"saint\":\"Parfait\",\"date\":\"2025-04-18\"},{\"saint\":\"Bernadette\",\"date\":\"2025-04-18\"},{\"saint\":\"Emma\",\"date\":\"2025-04-19\"},{\"saint\":\"Alexandre\",\"date\":\"2025-04-22\"},{\"saint\":\"Georges\",\"date\":\"2025-04-23\"},{\"saint\":\"Fidèle\",\"date\":\"2025-04-24\"},{\"saint\":\"Marc\",\"date\":\"2025-04-25\"},{\"saint\":\"Valérie\",\"date\":\"2025-04-28\"}]},{\"mois\":\"Mai\",\"saints\":[{\"saint\":\"Philippe, Jacques\",\"date\":\"2025-05-01\"},{\"saint\":\"Boris\",\"date\":\"2025-05-02\"},{\"saint\":\"Prudence\",\"date\":\"2025-05-06\"},{\"saint\":\"Gisèle\",\"date\":\"2025-05-07\"},{\"saint\":\"Pacôme\",\"date\":\"2025-05-09\"},{\"saint\":\"Solange\",\"date\":\"2025-05-10\"},{\"saint\":\"Achille\",\"date\":\"2025-05-12\"},{\"saint\":\"Rolande\",\"date\":\"2025-05-13\"},{\"saint\":\"Denise\",\"date\":\"2025-05-15\"},{\"saint\":\"Honoré\",\"date\":\"2025-05-16\"},{\"saint\":\"Pascal\",\"date\":\"2025-05-17\"},{\"saint\":\"Éric\",\"date\":\"2025-05-18\"},{\"saint\":\"Yves\",\"date\":\"2025-05-19\"},{\"saint\":\"Constantin\",\"date\":\"2025-05-21\"},{\"saint\":\"Didier\",\"date\":\"2025-05-23\"},{\"saint\":\"Germain\",\"date\":\"2025-05-28\"}]},{\"mois\":\"Juin\",\"saints\":[{\"saint\":\"Justin\",\"date\":\"2025-06-01\"},{\"saint\":\"Blandine\",\"date\":\"2025-06-02\"},{\"saint\":\"Kévin\",\"date\":\"2025-06-03\"},{\"saint\":\"Clotilde\",\"date\":\"2025-06-04\"},{\"saint\":\"Norbert\",\"date\":\"2025-06-06\"},{\"saint\":\"Raoul\",\"date\":\"2025-06-07\"},{\"saint\":\"Barnabé\",\"date\":\"2025-06-11\"},{\"saint\":\"Guy\",\"date\":\"2025-06-12\"},{\"saint\":\"Antoine de Padoue\",\"date\":\"2025-06-13\"},{\"saint\":\"Élisée\",\"date\":\"2025-06-14\"},{\"saint\":\"Maxime\",\"date\":\"2025-06-14\"},{\"saint\":\"Hervé\",\"date\":\"2025-06-17\"},{\"saint\":\"Léonce\",\"date\":\"2025-06-18\"},{\"saint\":\"Émilie\",\"date\":\"2025-06-19\"},{\"saint\":\"Silvère\",\"date\":\"2025-06-20\"},{\"saint\":\"Alban\",\"date\":\"2025-06-22\"},{\"saint\":\"Audrey\",\"date\":\"2025-06-23\"},{\"saint\":\"Prosper\",\"date\":\"2025-06-25\"},{\"saint\":\"Anthelme\",\"date\":\"2025-06-26\"},{\"saint\":\"Alida\",\"date\":\"2025-06-26\"},{\"saint\":\"Fernand\",\"date\":\"2025-06-27\"},{\"saint\":\"Irénée\",\"date\":\"2025-06-28\"},{\"saint\":\"Pierre, Paul\",\"date\":\"2025-06-29\"},{\"saint\":\"Martial\",\"date\":\"2025-06-30\"}]},{\"mois\":\"Juillet\",\"saints\":[{\"saint\":\"Thomas\",\"date\":\"2025-07-03\"},{\"saint\":\"Antoine\",\"date\":\"2025-07-05\"},{\"saint\":\"Mariette\",\"date\":\"2025-07-05\"},{\"saint\":\"Raïssa\",\"date\":\"2025-07-05\"},{\"saint\":\"N-D. Mt-Carmel\",\"date\":\"2025-07-16\"},{\"saint\":\"Donald\",\"date\":\"2025-07-15\"},{\"saint\":\"Alexis\",\"date\":\"2025-07-17\"},{\"saint\":\"Charlotte\",\"date\":\"2025-07-17\"},{\"saint\":\"Frédéric\",\"date\":\"2025-07-18\"},{\"saint\":\"Arsène\",\"date\":\"2025-07-19\"},{\"saint\":\"Marina\",\"date\":\"2025-07-20\"},{\"saint\":\"Victor\",\"date\":\"2025-07-21\"},{\"saint\":\"Christophe\",\"date\":\"2025-07-21\"},{\"saint\":\"Marie-Madeleine\",\"date\":\"2025-07-22\"},{\"saint\":\"Brigitte\",\"date\":\"2025-07-23\"},{\"saint\":\"Christine\",\"date\":\"2025-07-24\"},{\"saint\":\"Jacques\",\"date\":\"2025-07-25\"},{\"saint\":\"Hermann\",\"date\":\"2025-07-25\"},{\"saint\":\"Nathalie\",\"date\":\"2025-07-27\"},{\"saint\":\"Samson\",\"date\":\"2025-07-28\"},{\"saint\":\"Marthe\",\"date\":\"2025-07-29\"},{\"saint\":\"Ignace De Loyola\",\"date\":\"2025-07-31\"}]},{\"mois\":\"Août\",\"saints\":[{\"saint\":\"Alphonse\",\"date\":\"2025-08-01\"},{\"saint\":\"Sandrine\",\"date\":\"2025-08-01\"},{\"saint\":\"Julien Eymard\",\"date\":\"2025-08-02\"},{\"saint\":\"Lydie\",\"date\":\"2025-08-03\"},{\"saint\":\"Jean-M. Vianney\",\"date\":\"2025-08-04\"},{\"saint\":\"Abel\",\"date\":\"2025-08-05\"},{\"saint\":\"Gaétan\",\"date\":\"2025-08-07\"},{\"saint\":\"Gilbert\",\"date\":\"2025-08-07\"},{\"saint\":\"Dominique\",\"date\":\"2025-08-08\"},{\"saint\":\"Estelle\",\"date\":\"2025-08-10\"},{\"saint\":\"Laurent\",\"date\":\"2025-08-10\"},{\"saint\":\"Vivien\",\"date\":\"2025-08-10\"},{\"saint\":\"Claire\",\"date\":\"2025-08-11\"},{\"saint\":\"J.-F. Chantal\",\"date\":\"2025-08-12\"},{\"saint\":\"Hippolyte\",\"date\":\"2025-08-13\"},{\"saint\":\"Sidoine\",\"date\":\"2025-08-14\"},{\"saint\":\"Armel\",\"date\":\"2025-08-16\"},{\"saint\":\"Hyacinthe\",\"date\":\"2025-08-17\"},{\"saint\":\"Hélène\",\"date\":\"2025-08-18\"},{\"saint\":\"Jean-Eudes\",\"date\":\"2025-08-19\"},{\"saint\":\"Bernard\",\"date\":\"2025-08-20\"},{\"saint\":\"Fabrice\",\"date\":\"2025-08-22\"},{\"saint\":\"Rose de Lima\",\"date\":\"2025-08-23\"},{\"saint\":\"Barthélémy\",\"date\":\"2025-08-24\"},{\"saint\":\"Louis\",\"date\":\"2025-08-25\"},{\"saint\":\"Monique\",\"date\":\"2025-08-27\"},{\"saint\":\"Augustin\",\"date\":\"2025-08-28\"},{\"saint\":\"Sabine\",\"date\":\"2025-08-29\"},{\"saint\":\"Fiacre\",\"date\":\"2025-08-30\"},{\"saint\":\"Aristide\",\"date\":\"2025-08-31\"}]},{\"mois\":\"Septembre\",\"saints\":[{\"saint\":\"Gilles\",\"date\":\"2025-09-01\"},{\"saint\":\"Ingrid\",\"date\":\"2025-09-02\"},{\"saint\":\"Grégoire\",\"date\":\"2025-09-03\"},{\"saint\":\"Rosalie\",\"date\":\"2025-09-04\"},{\"saint\":\"Raïssa\",\"date\":\"2025-09-05\"},{\"saint\":\"Bertrand\",\"date\":\"2025-09-06\"},{\"saint\":\"Reine\",\"date\":\"2025-09-07\"},{\"saint\":\"Alain\",\"date\":\"2025-09-09\"},{\"saint\":\"Arnaud\",\"date\":\"2025-09-10\"},{\"saint\":\"Adelphe\",\"date\":\"2025-09-11\"},{\"saint\":\"Firmin\",\"date\":\"2025-09-11\"},{\"saint\":\"Aimé\",\"date\":\"2025-09-13\"},{\"saint\":\"Ida\",\"date\":\"2025-09-13\"},{\"saint\":\"Édith\",\"date\":\"2025-09-16\"},{\"saint\":\"Renaud\",\"date\":\"2025-09-17\"},{\"saint\":\"Nadège\",\"date\":\"2025-09-18\"},{\"saint\":\"Matthieu\",\"date\":\"2025-09-21\"},{\"saint\":\"Maurice\",\"date\":\"2025-09-22\"},{\"saint\":\"Constant\",\"date\":\"2025-09-23\"},{\"saint\":\"Thècle\",\"date\":\"2025-09-23\"},{\"saint\":\"Delphine\",\"date\":\"2025-09-26\"},{\"saint\":\"Côme\",\"date\":\"2025-09-26\"},{\"saint\":\"Damien\",\"date\":\"2025-09-26\"},{\"saint\":\"Venceslas\",\"date\":\"2025-09-28\"},{\"saint\":\"Michel\",\"date\":\"2025-09-29\"},{\"saint\":\"Jérôme\",\"date\":\"2025-09-30\"}]},{\"mois\":\"Octobre\",\"saints\":[{\"saint\":\"Thérèse de l\'E.-J.\",\"date\":\"2025-10-01\"},{\"saint\":\"Léger\",\"date\":\"2025-10-02\"},{\"saint\":\"Gérard\",\"date\":\"2025-10-03\"},{\"saint\":\"François d\'Assise\",\"date\":\"2025-10-04\"},{\"saint\":\"Fleur\",\"date\":\"2025-10-05\"},{\"saint\":\"Gérald\",\"date\":\"2025-10-05\"},{\"saint\":\"Bruno\",\"date\":\"2025-10-06\"},{\"saint\":\"Serge\",\"date\":\"2025-10-07\"},{\"saint\":\"Pélagie\",\"date\":\"2025-10-08\"},{\"saint\":\"Denis\",\"date\":\"2025-10-09\"},{\"saint\":\"Ghislain\",\"date\":\"2025-10-10\"},{\"saint\":\"Wilfried\",\"date\":\"2025-10-12\"},{\"saint\":\"Juste\",\"date\":\"2025-10-14\"},{\"saint\":\"Edwige\",\"date\":\"2025-10-16\"},{\"saint\":\"Baudouin\",\"date\":\"2025-10-17\"},{\"saint\":\"Luc\",\"date\":\"2025-10-18\"},{\"saint\":\"René\",\"date\":\"2025-10-19\"},{\"saint\":\"Adeline\",\"date\":\"2025-10-20\"},{\"saint\":\"Céline\",\"date\":\"2025-10-21\"},{\"saint\":\"Élodie\",\"date\":\"2025-10-22\"},{\"saint\":\"Florentin\",\"date\":\"2025-10-24\"},{\"saint\":\"Crépin\",\"date\":\"2025-10-25\"},{\"saint\":\"Dimitri\",\"date\":\"2025-10-26\"},{\"saint\":\"Émeline\",\"date\":\"2025-10-27\"},{\"saint\":\"Narcisse\",\"date\":\"2025-10-29\"},{\"saint\":\"Bienvenue\",\"date\":\"2025-10-30\"},{\"saint\":\"Thérèse d\'Avila\",\"date\":\"2025-10-15\"}]},{\"mois\":\"Novembre\",\"saints\":[{\"saint\":\"Défunts\",\"date\":\"2025-11-02\"},{\"saint\":\"Hubert\",\"date\":\"2025-11-03\"},{\"saint\":\"Charles\",\"date\":\"2025-11-04\"},{\"saint\":\"Sylvie\",\"date\":\"2025-11-05\"},{\"saint\":\"Melaine\",\"date\":\"2025-11-06\"},{\"saint\":\"Léonard\",\"date\":\"2025-11-06\"},{\"saint\":\"Carine\",\"date\":\"2025-11-07\"},{\"saint\":\"Geoffroy\",\"date\":\"2025-11-08\"},{\"saint\":\"Théodore\",\"date\":\"2025-11-09\"},{\"saint\":\"Léon\",\"date\":\"2025-11-10\"},{\"saint\":\"Martin\",\"date\":\"2025-11-11\"},{\"saint\":\"Christian\",\"date\":\"2025-11-12\"},{\"saint\":\"Brice\",\"date\":\"2025-11-13\"},{\"saint\":\"Albert\",\"date\":\"2025-11-15\"},{\"saint\":\"Marguerite\",\"date\":\"2025-11-16\"},{\"saint\":\"Élisabeth\",\"date\":\"2025-11-17\"},{\"saint\":\"Aude\",\"date\":\"2025-11-18\"},{\"saint\":\"Tanguy\",\"date\":\"2025-11-19\"},{\"saint\":\"Edmond\",\"date\":\"2025-11-20\"},{\"saint\":\"Cécile\",\"date\":\"2025-11-22\"},{\"saint\":\"Clément\",\"date\":\"2025-11-23\"},{\"saint\":\"Flora\",\"date\":\"2025-11-24\"},{\"saint\":\"Jacques de la M.\",\"date\":\"2025-11-28\"},{\"saint\":\"Saturnin\",\"date\":\"2025-11-29\"},{\"saint\":\"André\",\"date\":\"2025-11-30\"}]},{\"mois\":\"Décembre\",\"saints\":[{\"saint\":\"Ambroise\",\"date\":\"2025-12-07\"},{\"saint\":\"Nicolas\",\"date\":\"2025-12-06\"},{\"saint\":\"Barbara\",\"date\":\"2025-12-04\"},{\"saint\":\"Daniel\",\"date\":\"2025-12-11\"},{\"saint\":\"Lucie\",\"date\":\"2025-12-13\"},{\"saint\":\"Ninon\",\"date\":\"2025-12-15\"},{\"saint\":\"Alice\",\"date\":\"2025-12-16\"},{\"saint\":\"Judicaël\",\"date\":\"2025-12-17\"},{\"saint\":\"Gatien\",\"date\":\"2025-12-18\"},{\"saint\":\"Urbain\",\"date\":\"2025-12-19\"},{\"saint\":\"Davy\",\"date\":\"2025-12-20\"},{\"saint\":\"Pierre\",\"date\":\"2025-12-21\"},{\"saint\":\"Théophile\",\"date\":\"2025-12-21\"},{\"saint\":\"Françoise Xavière\",\"date\":\"2025-12-23\"},{\"saint\":\"Adèle\",\"date\":\"2025-12-24\"},{\"saint\":\"Noël\",\"date\":\"2025-12-25\"},{\"saint\":\"Étienne\",\"date\":\"2025-12-26\"},{\"saint\":\"Jean\",\"date\":\"2025-12-27\"},{\"saint\":\"Innocents\",\"date\":\"2025-12-28\"},{\"saint\":\"David\",\"date\":\"2025-12-29\"},{\"saint\":\"François de Sales\",\"date\":\"2025-12-29\"},{\"saint\":\"Roger\",\"date\":\"2025-12-30\"},{\"saint\":\"Sylvestre\",\"date\":\"2025-12-31\"}]}]');
  dynamic get saints => _saints;
  set saints(dynamic value) {
    _saints = value;
  }

  BingoStruct _bingo = BingoStruct();
  BingoStruct get bingo => _bingo;
  set bingo(BingoStruct value) {
    _bingo = value;
    prefs.setString('ff_bingo', value.serialize());
  }

  void updateBingoStruct(Function(BingoStruct) updateFn) {
    updateFn(_bingo);
    prefs.setString('ff_bingo', _bingo.serialize());
  }

  List<DateTime> _haiti = [
    DateTime.fromMillisecondsSinceEpoch(1781323200000),
    DateTime.fromMillisecondsSinceEpoch(1781150400000),
    DateTime.fromMillisecondsSinceEpoch(1781841600000),
    DateTime.fromMillisecondsSinceEpoch(1782273600000)
  ];
  List<DateTime> get haiti => _haiti;
  set haiti(List<DateTime> value) {
    _haiti = value;
    prefs.setStringList('ff_haiti',
        value.map((x) => x.millisecondsSinceEpoch.toString()).toList());
  }

  void addToHaiti(DateTime value) {
    haiti.add(value);
    prefs.setStringList('ff_haiti',
        _haiti.map((x) => x.millisecondsSinceEpoch.toString()).toList());
  }

  void removeFromHaiti(DateTime value) {
    haiti.remove(value);
    prefs.setStringList('ff_haiti',
        _haiti.map((x) => x.millisecondsSinceEpoch.toString()).toList());
  }

  void removeAtIndexFromHaiti(int index) {
    haiti.removeAt(index);
    prefs.setStringList('ff_haiti',
        _haiti.map((x) => x.millisecondsSinceEpoch.toString()).toList());
  }

  void updateHaitiAtIndex(
    int index,
    DateTime Function(DateTime) updateFn,
  ) {
    haiti[index] = updateFn(_haiti[index]);
    prefs.setStringList('ff_haiti',
        _haiti.map((x) => x.millisecondsSinceEpoch.toString()).toList());
  }

  void insertAtIndexInHaiti(int index, DateTime value) {
    haiti.insert(index, value);
    prefs.setStringList('ff_haiti',
        _haiti.map((x) => x.millisecondsSinceEpoch.toString()).toList());
  }

  List<StoriesStruct> _stories = [];
  List<StoriesStruct> get stories => _stories;
  set stories(List<StoriesStruct> value) {
    _stories = value;
  }

  void addToStories(StoriesStruct value) {
    stories.add(value);
  }

  void removeFromStories(StoriesStruct value) {
    stories.remove(value);
  }

  void removeAtIndexFromStories(int index) {
    stories.removeAt(index);
  }

  void updateStoriesAtIndex(
    int index,
    StoriesStruct Function(StoriesStruct) updateFn,
  ) {
    stories[index] = updateFn(_stories[index]);
  }

  void insertAtIndexInStories(int index, StoriesStruct value) {
    stories.insert(index, value);
  }

  BetaFeaturesStruct _betaFeatures = BetaFeaturesStruct.fromSerializableMap(
      jsonDecode('{\"stories\":\"false\"}'));
  BetaFeaturesStruct get betaFeatures => _betaFeatures;
  set betaFeatures(BetaFeaturesStruct value) {
    _betaFeatures = value;
    prefs.setString('ff_betaFeatures', value.serialize());
  }

  void updateBetaFeaturesStruct(Function(BetaFeaturesStruct) updateFn) {
    updateFn(_betaFeatures);
    prefs.setString('ff_betaFeatures', _betaFeatures.serialize());
  }

  final _newYorkTirageManager = FutureRequestManager<List<ResultatsRecord>>();
  Future<List<ResultatsRecord>> newYorkTirage({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<ResultatsRecord>> Function() requestFn,
  }) =>
      _newYorkTirageManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearNewYorkTirageCache() => _newYorkTirageManager.clear();
  void clearNewYorkTirageCacheKey(String? uniqueKey) =>
      _newYorkTirageManager.clearRequest(uniqueKey);

  final _floridaTirageManager = FutureRequestManager<List<ResultatsRecord>>();
  Future<List<ResultatsRecord>> floridaTirage({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<ResultatsRecord>> Function() requestFn,
  }) =>
      _floridaTirageManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearFloridaTirageCache() => _floridaTirageManager.clear();
  void clearFloridaTirageCacheKey(String? uniqueKey) =>
      _floridaTirageManager.clearRequest(uniqueKey);
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
