import 'package:flutter/material.dart';
import 'package:noriskclient/config/Colors.dart';

/// General-purpose utilities shared across the app.
///
/// Keeps common one-liners DRY and in one place so they stay consistent
/// across screens when the design tokens change.
class AppUtils {
  AppUtils._();

  // ── Spacing ────────────────────────────────────────────────────────────────
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 12;
  static const double spacingL = 16;
  static const double spacingXL = 24;
  static const double spacingXXL = 32;

  // ── Border radii ───────────────────────────────────────────────────────────
  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXL = 24;

  // ── Text helpers ───────────────────────────────────────────────────────────
  /// Headline style – large, bold, primary text colour.
  static TextStyle headline({double fontSize = 45}) => TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: NoRiskClientColors.text,
      );

  /// Section label style – medium, bold, primary text colour.
  static TextStyle sectionLabel({double fontSize = 25}) => TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: NoRiskClientColors.text,
      );

  /// Body / caption style – normal weight, muted text colour.
  static TextStyle caption({double fontSize = 14}) => TextStyle(
        fontSize: fontSize,
        color: NoRiskClientColors.textLight,
      );

  // ── Empty-state widget ─────────────────────────────────────────────────────
  /// A centred column with a large [icon], a bold [title] and a lighter
  /// [subtitle]. Drop this wherever a list or feed has nothing to show.
  static Widget emptyState({
    required String title,
    String? subtitle,
    Widget? icon,
    double topPadding = 60,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding, left: 32, right: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon, const SizedBox(height: 16)],
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: NoRiskClientColors.text,
              fontFamily: 'SmallCapsMC',
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: NoRiskClientColors.textLight,
                fontFamily: 'SmallCapsMC',
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Date / time formatting ─────────────────────────────────────────────────
  /// Returns a short human-readable relative time string (German).
  ///
  /// Examples: "gerade eben", "vor 5 Min.", "vor 3 Std.", "vor 2 Tagen"
  static String relativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'gerade eben';
    if (diff.inMinutes < 60) return 'vor ${diff.inMinutes} Min.';
    if (diff.inHours < 24) return 'vor ${diff.inHours} Std.';
    if (diff.inDays == 1) return 'gestern';
    if (diff.inDays < 7) return 'vor ${diff.inDays} Tagen';
    return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
  }

  /// Parses an ISO-8601 timestamp string and returns [relativeTime] for it.
  /// Returns an empty string if [raw] is null or cannot be parsed.
  static String relativeTimeFromString(String? raw) {
    if (raw == null) return '';
    try {
      return relativeTime(DateTime.parse(raw).toLocal());
    } catch (_) {
      return '';
    }
  }

  // ── Misc ───────────────────────────────────────────────────────────────────
  /// Clamps [value] between [min] and [max].
  static double clamp(double value, double min, double max) =>
      value < min ? min : (value > max ? max : value);

  /// Returns [text] truncated to [maxLength] characters, with an ellipsis
  /// appended when truncation occurs.
  static String truncate(String text, int maxLength) =>
      text.length <= maxLength ? text : '${text.substring(0, maxLength)}…';
}
