import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';

class PageHeaderBackdrop extends StatelessWidget {
  const PageHeaderBackdrop({super.key, this.vip = false});

  final bool vip;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: FlutterFlowTheme.of(context)
            .designToken
            .background
            .pageHeader(vip: vip),
        child: const SizedBox.expand(),
      );
}

class PageHeaderAppBar extends AppBar {
  PageHeaderAppBar({
    super.key,
    super.title,
    super.leading,
    super.automaticallyImplyLeading,
    super.centerTitle,
    super.actions,
    super.foregroundColor,
    bool vip = false,
  }) : super(
          elevation: 0,
          scrolledUnderElevation: 0,
          forceMaterialTransparency: true,
          flexibleSpace: PageHeaderBackdrop(vip: vip),
        );
}
