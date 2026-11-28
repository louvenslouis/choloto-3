import '/components/page_header_app_bar.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/accomplissements/member_vip_badge.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'profil_model.dart';
import '../profile_contact_fields.dart';
export 'profil_model.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.photoUrl, required this.badge});

  final String photoUrl;
  final Widget badge;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(Icons.location_history,
        size: 64, color: FlutterFlowTheme.of(context).primaryText);
    return SizedBox.square(
      dimension: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ExcludeSemantics(
              child: SizedBox.square(
            dimension: 64,
            child: photoUrl.isEmpty
                ? fallback
                : ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: photoUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => fallback,
                      errorWidget: (_, __, ___) => fallback,
                    ),
                  ),
          )),
          Positioned(top: 0, right: 0, child: badge),
        ],
      ),
    );
  }
}

class ProfilWidget extends StatefulWidget {
  const ProfilWidget({super.key});

  static String routeName = 'profil';
  static String routePath = '/profil';

  @override
  State<ProfilWidget> createState() => _ProfilWidgetState();
}

class _ProfilWidgetState extends State<ProfilWidget> {
  late ProfilModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfilModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'profil'});
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = FlutterFlowTheme.of(context).designToken;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      appBar: PageHeaderAppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        leading: FlutterFlowIconButton(
          buttonSize: kMinInteractiveDimension,
          icon: Icon(Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).primaryText),
          onPressed: () async {
            logFirebaseEvent('PROFIL_arrow_back_rounded_ICN_ON_TAP');
            logFirebaseEvent('IconButton_navigate_back');
            context.pop();
          },
        ),
        title: Text(
          FFLocalizations.of(context).getText('xpn42xty'),
          style: FlutterFlowTheme.of(context).titleLarge,
        ),
      ),
      body: SafeArea(
        top: true,
        child: ListView(
          children: [
            AuthUserStreamWidget(builder: (context) {
              final user = currentUserDocument;
              if (!loggedIn ||
                  user == null ||
                  user.reference.id != currentUserUid) {
                return const SizedBox.shrink();
              }
              return Center(
                  child: ProfileAvatar(
                photoUrl: currentUserPhoto,
                badge: MemberVipBadge(user: user),
              ));
            }),
            DecoratedBox(
              decoration: tokens.home.panel,
              child: Material(
                type: MaterialType.transparency,
                borderRadius: BorderRadius.circular(tokens.radius.md),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        AuthUserStreamWidget(
                          builder: (context) => _ProfileEditTile(
                            value: currentUserDisplayName,
                            editLabel:
                                FFLocalizations.of(context).getText('c8eoezku'),
                            onTap: () async {
                              logFirebaseEvent('PROFIL_PAGE_username_ON_TAP');
                              logFirebaseEvent('username_action_block');
                              await _model.edit(context, champ: 1);
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: tokens.spacing.md,
                          right: tokens.spacing.md,
                          child: IgnorePointer(
                            child: Divider(
                                height: 1, color: tokens.home.panelEdge),
                          ),
                        ),
                      ],
                    ),
                    _ProfileEditTile(
                      value: currentUserEmail,
                      editLabel:
                          FFLocalizations.of(context).getText('vkfordrl'),
                      onTap: () async {
                        logFirebaseEvent('PROFIL_PAGE_email_ON_TAP');
                        logFirebaseEvent('email_action_block');
                        await _model.edit(context, champ: 2);
                      },
                    ),
                  ],
                ),
              ),
            ),
            AuthUserStreamWidget(builder: (context) {
              final profile = currentUserDocument;
              if (!loggedIn) return const SizedBox.shrink();
              return ProfileContactFields(
                profile:
                    profile != null && profile.reference.id == currentUserUid
                        ? profile
                        : null,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ProfileEditTile extends StatelessWidget {
  const _ProfileEditTile({
    required this.value,
    required this.editLabel,
    required this.onTap,
  });

  final String value;
  final String editLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final muted = theme.designToken.home.mutedText;
    return ListTile(
      title: Text(value, style: theme.titleLarge),
      subtitle:
          Text(editLabel, style: theme.labelMedium.copyWith(color: muted)),
      trailing: Icon(Icons.create, color: muted, size: 24),
      dense: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      onTap: onTap,
    );
  }
}
