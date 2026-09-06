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
  'emailFallback': ['Écrire par e-mail', 'Write by email', 'Ekri pa imèl'],
};
