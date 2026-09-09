import 'package:flutter/material.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/support/support_chat_view.dart';
import '/support/support_conversation.dart';
import '/support/support_guest_session.dart';
import '/support/support_text.dart';

class CustomerserviceWidget extends StatefulWidget {
  const CustomerserviceWidget({
    super.key,
    this.repository,
    this.guestIdLoader,
  });

  static String routeName = 'customerservice';
  static String routePath = '/customerservice';

  final SupportConversationRepository? repository;
  final Future<String> Function()? guestIdLoader;

  @override
  State<CustomerserviceWidget> createState() => _CustomerserviceWidgetState();
}

class _CustomerserviceWidgetState extends State<CustomerserviceWidget> {
  late final SupportConversationRepository _repository =
      widget.repository ?? SupportConversationRepository();
  late final Future<String> _guestId =
      (widget.guestIdLoader ?? GuestSupportSession.loadOrCreateId)();

  Widget _chat({
    required String conversationId,
    required bool guestWithoutAuth,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: SupportChatView(
          messages: guestWithoutAuth
              ? _repository.watchGuestMessages(conversationId)
              : _repository.watchMessages(conversationId),
          onSend: (text) => guestWithoutAuth
              ? _repository.sendGuestMessage(
                  guestId: conversationId,
                  text: text,
                )
              : _repository.sendUserMessage(
                  userUid: conversationId,
                  userEmail: currentUserEmail,
                  userDisplayName: currentUserDisplayName,
                  text: text,
                ),
          showOptionalPhoneOnFirstMessage:
              guestWithoutAuth || currentUserIsAnonymous,
        ),
      ),
    );
  }

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
            if (hasFirebaseSession && currentUserUid.isNotEmpty) {
              return _chat(
                conversationId: currentUserUid,
                guestWithoutAuth: false,
              );
            }
            return FutureBuilder<String>(
              future: _guestId,
              builder: (context, snapshot) {
                final guestId = snapshot.data;
                if (guestId == null) {
                  return Center(
                    child: CircularProgressIndicator(color: theme.primary),
                  );
                }
                return _chat(
                  conversationId: guestId,
                  guestWithoutAuth: true,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
