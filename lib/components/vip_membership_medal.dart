import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

import 'home_feature_card.dart';

class VipMembershipMedal extends StatelessWidget {
  const VipMembershipMedal({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: HomeRaisedArtwork(
          asset: 'assets/images/home/vip_amethyst_medal.webp',
          imageKey: const ValueKey('vip-membership-medal'),
          width: size,
          fallback: Icons.workspace_premium_rounded,
          foreground: FlutterFlowTheme.of(context).designToken.vip.goldLight,
        ),
      );
}
