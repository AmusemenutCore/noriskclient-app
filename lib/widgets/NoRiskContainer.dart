import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:noriskclient/config/Colors.dart';

class NoRiskContainer extends Container {
  // V2: rounder corners + a soft shadow read as "elevated" in both themes,
  // instead of relying purely on a translucent border to separate a card
  // from the background.
  NoRiskContainer({
    Key? key,
    double? width,
    double? height,
    Color? color,
    int? backgroundOpacity,
    int? borderOpacity,
    AlignmentGeometry? alignment,
    EdgeInsetsGeometry? padding,
    BoxConstraints? constraints,
    Decoration? decoration,
    BorderRadius? borderRadius,
    bool elevated = false,
    Widget? child,
  }) : super(
         key: key,
         width: width,
         height: height,
         alignment: alignment,
         padding: padding,
         constraints: constraints,
         // Default tint follows `text` (white in dark mode, near-black in
         // light mode) so the untinted "glass" look still reads as a
         // lighter/darker card against the surface in either theme,
         // instead of washing out to near-invisible in light mode.
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
         child: child,
       );
}
