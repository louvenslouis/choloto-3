import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/support/support_chat_view.dart';
import '/support/support_conversation.dart';
import '/support/support_text.dart';

class CustomerserviceWidget extends StatefulWidget {
  const CustomerserviceWidget({super.key, this.repository});

  static String routeName = 'customerservice';
  static String routePath = '/customerservice';

  final SupportConversationRepository? repository;

  @override
  State<CustomerserviceWidget> createState() => _CustomerserviceWidgetState();
}

class _CustomerserviceWidgetState extends State<CustomerserviceWidget> {
  late final SupportConversationRepository _repository =
      widget.repository ?? SupportConversationRepository();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderRadius: theme.designToken.radius.sm,
          buttonSize: 40,
          icon: Icon(Icons.arrow_back_rounded,
              color: theme.primaryText, size: 24),
          onPressed: context.safePop,
        ),
        title: Text(supportText(context, 'title'), style: theme.titleLarge),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: AuthUserStreamWidget(
          builder: (context) {
            if (!loggedIn || currentUserUid.isEmpty) {
              return const _SignedOutSupport();
            }
            final uid = currentUserUid;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: SupportChatView(
                  messages: _repository.watchMessages(uid),
                  onSend: (text) => _repository.sendUserMessage(
                    userUid: uid,
                    userEmail: currentUserEmail,
                    userDisplayName: currentUserDisplayName,
                    text: text,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SignedOutSupport extends StatelessWidget {
  const _SignedOutSupport();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline_rounded, size: 48, color: theme.primary),
            SizedBox(height: spacing.md),
            Text(
              supportText(context, 'signin'),
              textAlign: TextAlign.center,
              style: theme.bodyLarge,
            ),
            SizedBox(height: spacing.md),
            OutlinedButton.icon(
              onPressed: () => launchUrl(
                Uri(scheme: 'mailto', path: 'contact@choloto.com'),
              ),
              icon: const Icon(Icons.email_outlined),
              label: Text(supportText(context, 'emailFallback')),
            ),
          ],
        ),
      ),
    );
  }
}
