import 'package:flutter/material.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/settings/profil/edit_profil_texts/edit_profil_texts_widget.dart';
import '/support/support_chat_view.dart';
import '/support/support_conversation.dart';
import '/support/support_phone_gate.dart';
import '/support/support_phone_requirement.dart';
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

  Future<void> _startGuestSupport(BuildContext context) async {
    final appState = GoRouter.of(context).appState;
    appState.updateNotifyOnAuthChange(false);
    try {
      final guest = await authManager.signInAnonymously(context);
      if (guest == null || !context.mounted) {
        return;
      }
      await _addPhoneNumber(context);
    } finally {
      appState.updateNotifyOnAuthChange(true);
    }
  }

  Future<void> _addPhoneNumber(BuildContext context) async {
    final theme = FlutterFlowTheme.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.secondaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(theme.designToken.radius.lg),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (sheetContext) => Padding(
        padding: MediaQuery.viewInsetsOf(sheetContext),
        child: EditProfilTextsWidget(
          champ: 3,
          initialValue: currentPhoneNumber,
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
            final accessState = resolveSupportAccess(
              hasAuthenticatedSession: hasFirebaseSession,
              userUid: currentUserUid,
              profilePhoneNumber: currentUserDocument?.phoneNumber,
            );
            if (accessState == SupportAccessState.signedOut) {
              return SupportPhoneGate(
                onAddPhone: () => _startGuestSupport(context),
              );
            }
            if (accessState == SupportAccessState.phoneRequired) {
              return SupportPhoneGate(
                onAddPhone: () => _addPhoneNumber(context),
              );
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
