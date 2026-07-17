import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:noriskclient/config/Colors.dart';

/// Centralised icon system.
///
/// Standard PNG icons adapt their tint to the active theme (white in dark
/// mode, black in light mode). Pass [color] to pin a specific colour.
///
/// SVG icons work the same way via [NRIcons.svg]:
///   NRIcons.svg('sign_out')                         // theme-aware
///   NRIcons.svg('sign_out', color: Colors.red)      // fixed red, no dark/light reaction
///
/// PNG icons via [NRIcons.get]:
///   NRIcons.get('delete')                           // theme-aware tint
///   NRIcons.get('delete', color: Colors.blue)       // fixed colour
///
/// Navigation/widget icons:
///   NRIcons.nav('news')
///
/// Untinted (already colourful) icons:
///   NRIcons.raw('fire', ext: 'webp')
class NRIcons {
  NRIcons._();

  // ── Resolved theme colour ──────────────────────────────────────────────────
  /// White in dark mode, black in light mode.
  static Color get _themeColor =>
      NoRiskClientColors.mode == NoRiskThemeMode.dark
          ? Colors.white
          : Colors.black;

  // ── SVG icons ─────────────────────────────────────────────────────────────
  /// Returns a tinted SVG icon from [lib/assets/<dir>/].
  ///
  /// [dir] defaults to `'icons'`; pass `'widgets'` for navbar icons.
  ///
  /// If [color] is given, that colour is applied regardless of theme.
  /// If [color] is omitted, the icon follows dark/light mode automatically.
  static Widget svg(
    String name, {
    Color? color,
    double size = 24,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    String dir = 'icons',
  }) {
    final tint = color ?? _themeColor;
    return SvgPicture.asset(
      'lib/assets/$dir/$name.svg',
      width: width ?? size,
      height: height ?? size,
      fit: fit,
      colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
    );
  }

  // ── PNG icons ──────────────────────────────────────────────────────────────
  /// Returns a theme-tinted PNG icon from [lib/assets/icons/].
  ///
  /// Pass [color] to override the automatic theme tint.
  static Widget get(
    String name, {
    Color? color,
    double size = 24,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    String ext = 'png',
  }) {
    return Image.asset(
      'lib/assets/icons/$name.$ext',
      width: width ?? size,
      height: height ?? size,
      fit: fit,
      color: color ?? _themeColor,
      colorBlendMode: BlendMode.srcIn,
    );
  }

  /// Returns a theme-tinted navigation icon from [lib/assets/widgets/].
  static Widget nav(
    String name, {
    Color? color,
    double size = 25,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    String ext = 'png',
  }) {
    return Image.asset(
      'lib/assets/widgets/$name.$ext',
      width: width ?? size,
      height: height ?? size,
      fit: fit,
      color: color ?? _themeColor,
      colorBlendMode: BlendMode.srcIn,
    );
  }

  /// Returns a raw (untinted) asset — for already-colourful icons such as
  /// fire.webp, blue_checkmark, or any image that must not be recoloured.
  static Widget raw(
    String name, {
    String dir = 'icons',
    double size = 24,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    String ext = 'png',
  }) {
    return Image.asset(
      'lib/assets/$dir/$name.$ext',
      width: width ?? size,
      height: height ?? size,
      fit: fit,
    );
  }
}
