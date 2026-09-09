import 'package:flutter/widgets.dart';

import '/flutter_flow/internationalization.dart';

String supportText(BuildContext context, String key) {
  final values = _supportLabels[key]!;
  return FFLocalizations.of(context).getVariableText(
    frText: values[0],
    enText: values[1],
    crText: values[2],
  );
}

const _supportLabels = <String, List<String>>{
  'title': [
    'Chat service client',
    'Customer support chat',
    'Chat sèvis kliyan'
  ],
  'subscriptionTitle': [
    'Besoin d’aide pour vous abonner ?',
    'Need help subscribing?',
    'Bezwen èd pou abònman an?'
  ],
  'subscriptionBody': [
    'Échangez directement avec l’équipe CHOLOTO avant d’envoyer votre paiement.',
    'Chat directly with the CHOLOTO team before sending your payment.',
    'Pale dirèkteman ak ekip CHOLOTO a anvan ou voye peman an.'
  ],
  'open': ['Ouvrir le chat', 'Open chat', 'Ouvri chat la'],
  'intro': [
    'Posez vos questions sur le prix, le paiement ou l’activation VIP. Un administrateur vous répondra ici.',
    'Ask about pricing, payment, or VIP activation. An administrator will reply here.',
    'Poze kesyon sou pri, peman oswa aktivasyon VIP. Yon administratè ap reponn ou isit la.'
  ],
  'responseTime': [
    'Réponse habituelle sous 24 heures ouvrables',
    'Usually replies within 24 business hours',
    'Nou reponn anjeneral nan 24 èdtan ouvrab'
  ],
  'emptyTitle': [
    'Démarrez la conversation',
    'Start the conversation',
    'Kòmanse konvèsasyon an'
  ],
  'emptyBody': [
    'Écrivez votre question ci-dessous. Votre message restera disponible dans l’application.',
    'Write your question below. Your message will remain available in the app.',
    'Ekri kesyon ou anba a. Mesaj ou a ap rete disponib nan aplikasyon an.'
  ],
  'hint': [
    'Votre question sur l’abonnement…',
    'Your subscription question…',
    'Kesyon ou sou abònman an…'
  ],
  'send': ['Envoyer', 'Send', 'Voye'],
  'sending': ['Envoi…', 'Sending…', 'N ap voye…'],
  'attachImage': ['Ajouter une image', 'Attach an image', 'Ajoute yon imaj'],
  'removeImage': ['Retirer l’image', 'Remove image', 'Retire imaj la'],
  'selectedImage': ['Image sélectionnée', 'Selected image', 'Imaj ki chwazi a'],
  'imageMessage': ['Photo', 'Photo', 'Foto'],
  'messageImage': [
    'Image jointe au message',
    'Image attached to the message',
    'Imaj ki tache ak mesaj la'
  ],
  'openImage': ['Ouvrir l’image', 'Open image', 'Ouvri imaj la'],
  'close': ['Fermer', 'Close', 'Fèmen'],
  'imageError': [
    'Cette image ne peut pas être ajoutée. Choisissez un fichier JPEG ou PNG valide.',
    'This image cannot be attached. Choose a valid JPEG or PNG file.',
    'Nou pa ka ajoute imaj sa a. Chwazi yon fichye JPEG oswa PNG ki valid.'
  ],
  'imageLoadError': [
    'Impossible de charger l’image.',
    'Unable to load the image.',
    'Nou pa ka chaje imaj la.'
  ],
  'admin': ['Équipe CHOLOTO', 'CHOLOTO team', 'Ekip CHOLOTO'],
  'you': ['Vous', 'You', 'Ou'],
  'error': [
    'Impossible de charger la conversation. Vérifiez votre connexion puis réessayez.',
    'Unable to load the conversation. Check your connection and try again.',
    'Nou pa ka chaje konvèsasyon an. Verifye koneksyon ou epi eseye ankò.'
  ],
  'sendError': [
    'Message non envoyé. Vérifiez votre connexion puis réessayez.',
    'Message not sent. Check your connection and try again.',
    'Mesaj la pa voye. Verifye koneksyon ou epi eseye ankò.'
  ],
  'retry': ['Réessayer', 'Retry', 'Eseye ankò'],
  'signin': [
    'Connectez-vous pour discuter avec le service client dans l’application.',
    'Sign in to chat with customer support in the app.',
    'Konekte pou pale ak sèvis kliyan nan aplikasyon an.'
  ],
  'phoneOptionalLabel': [
    'Téléphone (facultatif)',
    'Phone (optional)',
    'Telefòn (opsyonèl)'
  ],
  'phoneOptionalHint': [
    'Ex. +509 37 00 00 00',
    'E.g. +509 37 00 00 00',
    'Eg. +509 37 00 00 00'
  ],
  'phoneMessageLabel': ['Téléphone', 'Phone', 'Telefòn'],
  'emailFallback': ['Écrire par e-mail', 'Write by email', 'Ekri pa imèl'],
};
