import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:noriskclient/config/Colors.dart';

class NoRiskContainer extends Container {
  // V2: rounder corners + a soft shadow read as "elevated" in both themes,
  // instead of relying purely on a translucent border to separate a card
  // from the background.
  NoRiskContainer({
    super.key,
    super.width,
    super.height,
    Color? color,
    int? backgroundOpacity,
    int? borderOpacity,
    super.alignment,
    super.padding,
    super.constraints,
    Decoration? decoration,
    BorderRadius? borderRadius,
    bool elevated = false,
    super.child,
  }) : super(
         decoration:
             decoration ??
             BoxDecoration(
               color: color == Colors.transparent
                   ? color
                   : color?.withAlpha(backgroundOpacity ?? 115) ??
                         NoRiskClientColors.text.withAlpha(
                           backgroundOpacity ?? 115,
                         ),
               borderRadius: borderRadius ?? BorderRadius.circular(14),
               border: Border.all(
                 color: color == Colors.transparent
                     ? color!
                     : color?.withAlpha(borderOpacity ?? 100) ??
                           NoRiskClientColors.text.withAlpha(
                             borderOpacity ?? 100,
                           ),
                 width: 2,
               ),
               boxShadow: elevated
                   ? [
                       BoxShadow(
                         color: NoRiskClientColors.darkerBackground.withAlpha(
                           90,
                         ),
                         blurRadius: 16,
                         offset: const Offset(0, 6),
                       ),
                     ]
                   : null,
             ),
       );
}
