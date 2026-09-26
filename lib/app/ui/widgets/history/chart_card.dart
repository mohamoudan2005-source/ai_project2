import 'package:ai_project/utils/app_theme.dart';
import 'package:flutter/material.dart';

class ChartCard extends StatelessWidget {
  const ChartCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPad,
      decoration: AppDecorations.card,
      child: child,
    );
  }
}
