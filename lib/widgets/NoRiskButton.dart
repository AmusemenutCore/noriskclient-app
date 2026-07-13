import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noriskclient/widgets/NoRiskContainer.dart';

class NoRiskButton extends StatelessWidget {
  NoRiskButton({
    super.key,
    this.height,
    this.width,
    this.color = Colors.white,
    required this.onTap,
    required this.child,
  });

  final Widget child;
  Color color;
  final void Function() onTap;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // V2: every primary button gets a light haptic tick, so interactions
      // have physical feedback instead of relying on visual state alone.
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: NoRiskContainer(
        height: height,
        width: width,
        color: color,
        padding: const EdgeInsets.all(2.5),
        child: Center(child: child),
      ),
    );
  }
}
