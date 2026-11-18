import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'home_header_actions.dart';

class HomePageScaffold extends StatelessWidget {
  const HomePageScaffold({
    super.key,
    this.scaffoldKey,
    required this.inTabShell,
    required this.support,
    required this.children,
  });

  final GlobalKey<ScaffoldState>? scaffoldKey;
  final bool inTabShell;
  final HomeSupportFab support;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final spacing = tokens.spacing;
    final showHeader =
        !inTabShell || MediaQuery.sizeOf(context).width < kBreakpointMedium;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: tokens.background.home,
        floatingActionButton: showHeader ? null : support,
        body: DecoratedBox(
          key: const ValueKey('home-background-gradient'),
          decoration: BoxDecoration(gradient: tokens.background.homeGradient),
          child: SafeArea(
            top: false,
            child: CustomScrollView(
              slivers: [
                if (showHeader)
                  SliverAppBar(
                    pinned: true,
                    toolbarHeight: 64,
                    backgroundColor: tokens.background.home,
                    surfaceTintColor: tokens.background.home,
                    automaticallyImplyLeading: false,
                    titleSpacing: spacing.sm,
                    title: const HomeHeaderBrand(),
                    actions: [
                      Center(
                          child:
                              SizedBox.square(dimension: 44, child: support)),
                      SizedBox(width: spacing.xs),
                      HomeHeaderActions.navigation(context),
                      SizedBox(width: spacing.sm),
                    ],
                    shape: Border(bottom: BorderSide(color: tokens.home.edge)),
                    centerTitle: false,
                    elevation: 0,
                    scrolledUnderElevation: 0,
                  ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                      spacing.md,
                      showHeader ? spacing.sm : spacing.lg,
                      spacing.md,
                      showHeader ? spacing.lg : spacing.xl * 3),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                        child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1360),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: children.divide(SizedBox(height: spacing.sm)),
                      ),
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
