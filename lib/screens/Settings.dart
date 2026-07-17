import 'dart:async';
import 'package:flutter/material.dart';
import 'package:noriskclient/l10n/app_localizations.dart';
import 'package:noriskclient/config/Colors.dart';
import 'package:noriskclient/main.dart';
import 'package:noriskclient/config/Config.dart';
import 'package:noriskclient/provider/localeProvider.dart';
import 'package:noriskclient/provider/themeModeProvider.dart';
import 'package:noriskclient/screens/ScanQRCode.dart';
import 'package:noriskclient/screens/settings/Blocked.dart';
import 'package:noriskclient/widgets/NoRiskBackButton.dart';
import 'package:noriskclient/widgets/NoRiskText.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:noriskclient/utils/NRIcons.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  PackageInfo? packageInfo;

  @override
  void initState() {
    loadAppInfo();
    super.initState();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isAdmin = ['DEVELOPER', 'ADMIN'].contains(
      cache['profiles']?[getUserData['uuid']]?['nrcUser']?['rank']
              ?.toString()
              .toUpperCase() ??
          'DEFAULT',
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: NoRiskClientColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            // ── Header ───────────────────────────────────────────────────
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 7.5),
                    child: NoRiskBackButton(
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                NoRiskText(
                  loc.settings_title.toLowerCase(),
                  spaceTop: false,
                  spaceBottom: false,
                  style: TextStyle(
                    color: NoRiskClientColors.text,
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // ── Scrollable body ──────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 48),
                children: [
                  // Language
                  _SectionHeader(loc.settings_language),
                  _SettingsCard(
                    children: [
                      _ChoiceRow(
                        label: 'Deutsch',
                        selected:
                            AppLocalizations.of(context)!.localeName == 'de',
                        onTap: () => setLanguage('de'),
                      ),
                      _Divider(),
                      _ChoiceRow(
                        label: 'English',
                        selected:
                            AppLocalizations.of(context)!.localeName == 'en',
                        onTap: () => setLanguage('en'),
                      ),
                    ],
                  ),

                  // Theme
                  _SectionHeader(loc.settings_theme),
                  _SettingsCard(
                    children: [
                      _ChoiceRow(
                        label: loc.settings_theme_dark,
                        leadingWidget: NRIcons.svg('dark', size: 16),
                        selected:
                            NoRiskClientColors.mode == NoRiskThemeMode.dark,
                        onTap: () => setThemeMode(NoRiskThemeMode.dark),
                      ),
                      _Divider(),
                      _ChoiceRow(
                        label: loc.settings_theme_light,
                        leadingWidget: NRIcons.svg('light', size: 16),
                        selected:
                            NoRiskClientColors.mode == NoRiskThemeMode.light,
                        onTap: () => setThemeMode(NoRiskThemeMode.light),
                      ),
                    ],
                  ),

                  // Privacy
                  _SectionHeader(loc.settings_blockedPlayers),
                  _SettingsCard(
                    children: [
                      _NavRow(
                        label: loc.settings_blockedPlayers,
                        leadingIcon: Icons.block_rounded,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Blocked()),
                        ),
                      ),
                    ],
                  ),

                  // Legal
                  _SectionHeader(loc.settings_legal),
                  _SettingsCard(
                    children: [
                      _NavRow(
                        label: loc.settings_tos,
                        leadingIcon: Icons.description_rounded,
                        onTap: () => launchUrl(
                          Config.termsUrl,
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                      _Divider(),
                      _NavRow(
                        label: loc.settings_privacyPolicy,
                        leadingIcon: Icons.privacy_tip_rounded,
                        onTap: () => launchUrl(
                          Config.privacyUrl,
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                      _Divider(),
                      _NavRow(
                        label: loc.settings_imprint,
                        leadingIcon: Icons.info_outline_rounded,
                        onTap: () => launchUrl(
                          Config.imprintUrl,
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                    ],
                  ),

                  // Support
                  _SectionHeader(loc.settings_support),
                  _SettingsCard(
                    children: [
                      _NavRow(
                        label: loc.settings_support,
                        leadingWidget: NRIcons.svg(
                          'support',
                          color: NoRiskClientColors.success,
                          size: 16,
                        ),
                        leadingIconColor: NoRiskClientColors.success,
                        onTap: () => launchUrl(Config.supportUrl),
                      ),
                    ],
                  ),

                  // Admin (conditional)
                  if (isAdmin) ...[
                    _SectionHeader('Admin Options'),
                    _SettingsCard(
                      children: [
                        _NavRow(
                          label: 'Get Giveaway Info',
                          leadingIcon: Icons.qr_code_scanner_rounded,
                          leadingIconColor: NoRiskClientColors.blue,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ScanQRCode(isAdminScan: true),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Updates
                  _SectionHeader('Updates'),
                  _SettingsCard(
                    children: [
                      _NavRow(
                        label: isAndroid ? 'PlayStore' : 'AppStore',
                        leadingIcon: isAndroid
                            ? Icons.shop_rounded
                            : Icons.apple_rounded,
                        onTap: () => launchUrl(
                          isAndroid ? Config.playStoreUrl : Config.appStoreUrl,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Sign out — destructive
                  _SettingsCard(
                    children: [
                      _NavRow(
                        label: loc.settings_signOut,
                        leadingWidget: NRIcons.svg(
                          'sign_out',
                          color: NoRiskClientColors.danger,
                          size: 16,
                        ),
                        leadingIconColor: NoRiskClientColors.danger,
                        labelColor: NoRiskClientColors.danger,
                        showChevron: false,
                        onTap: () {
                          getUpdateStream.sink.add(['signOut']);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),

                  // ── Footer ────────────────────────────────────────────
                  const SizedBox(height: 32),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (packageInfo != null)
                          NoRiskText(
                            'Version ${packageInfo!.version} (${packageInfo!.buildNumber})'
                                .toLowerCase(),
                            spaceTop: false,
                            spaceBottom: false,
                            style: TextStyle(
                              color: NoRiskClientColors.textLight,
                              fontSize: 18,
                            ),
                          ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => launchUrlString(
                            'https://timlohrer.dev',
                            mode: LaunchMode.externalApplication,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'made with ',
                                style: TextStyle(
                                  fontFamily: 'SmallCapsMC',
                                  color: NoRiskClientColors.textLight,
                                  fontSize: 16,
                                ),
                              ),
                              NRIcons.svg('heart', color: Colors.orange, size: 16),
                              Text(
                                ' by tim lohrer',
                                style: TextStyle(
                                  fontFamily: 'SmallCapsMC',
                                  color: NoRiskClientColors.textLight,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Future<void> setLanguage(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    provider.setLocale(language);
  }

  void setThemeMode(NoRiskThemeMode mode) {
    setState(() {
      Provider.of<ThemeModeProvider>(context, listen: false).setMode(mode);
    });
  }

  void loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      packageInfo = info;
    });
  }
}

// ── Private helper widgets ─────────────────────────────────────────────────

/// A bold label above a settings card group.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 6),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: 'SmallCapsMC',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: NoRiskClientColors.textLight,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// Rounded card that groups related rows.
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NoRiskClientColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: NoRiskClientColors.light.withAlpha(120),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

/// A thin horizontal divider for use inside a [_SettingsCard].
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 48,
      color: NoRiskClientColors.light.withAlpha(100),
    );
  }
}

/// A settings row that navigates somewhere (chevron on the right).
///
/// Provide either [leadingIcon] (a Material [IconData]) OR [leadingWidget]
/// (any widget, e.g. from [NRIcons.svg]) as the row icon.
/// [leadingIconColor] controls both the icon tint and the bubble background.
class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.label,
    required this.onTap,
    this.leadingIcon,
    this.leadingWidget,
    this.leadingIconColor,
    this.labelColor,
    this.showChevron = true,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? leadingIcon;
  /// Alternative to [leadingIcon] — pass a pre-built widget (e.g. NRIcons.svg).
  final Widget? leadingWidget;
  final Color? leadingIconColor;
  final Color? labelColor;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final iconColor = leadingIconColor ?? NoRiskClientColors.blue;
    final textColor = labelColor ?? NoRiskClientColors.text;
    final hasLeading = leadingIcon != null || leadingWidget != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            if (hasLeading) ...[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: leadingWidget != null
                      ? leadingWidget!
                      : Icon(leadingIcon, size: 16, color: iconColor),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                label.toLowerCase(),
                style: TextStyle(
                  fontFamily: 'SmallCapsMC',
                  fontSize: 22,
                  color: textColor,
                ),
              ),
            ),
            if (showChevron)
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: NoRiskClientColors.textLight,
              ),
          ],
        ),
      ),
    );
  }
}

/// A settings row with a check-mark when selected (for language / theme).
///
/// Provide either [leadingIcon] (a Material [IconData]) or [leadingWidget]
/// (any widget, e.g. from [NRIcons.svg]) as the row icon.
class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.selected,
    required this.onTap,
    this.leadingWidget,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leadingWidget;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            if (leadingWidget != null) ...[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: NoRiskClientColors.blue.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: leadingWidget!),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                label.toLowerCase(),
                style: TextStyle(
                  fontFamily: 'SmallCapsMC',
                  fontSize: 22,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
                  color: selected
                      ? NoRiskClientColors.blue
                      : NoRiskClientColors.text,
                ),
              ),
            ),
            if (selected)
              Icon(
                Icons.check_rounded,
                size: 22,
                color: NoRiskClientColors.blue,
              ),
          ],
        ),
      ),
    );
  }
}
