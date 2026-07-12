import 'package:flutter/material.dart';
import 'package:noriskclient/config/Colors.dart';
import 'package:noriskclient/config/Config.dart';
import 'package:noriskclient/provider/localeProvider.dart';
import 'package:noriskclient/widgets/NoRiskButton.dart';
import 'package:noriskclient/widgets/NoRiskText.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shown once, before the sign-in flow, so the user picks a language they
/// understand before reading any onboarding or sign-in copy.
class LanguageSelect extends StatelessWidget {
  const LanguageSelect({super.key, required this.onLanguageChosen});

  final void Function() onLanguageChosen;

  Future<void> _chooseLanguage(BuildContext context, String code) async {
    Provider.of<LocaleProvider>(context, listen: false).setLocale(code);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', code);

    onLanguageChosen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NoRiskClientColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('lib/assets/app/norisk_logo.png', height: 110),
              const SizedBox(height: 30),
              // Shown before a language is picked, so both languages are
              // spelled out at once rather than relying on device locale.
              const NoRiskText('choose your language',
                  spaceTop: false,
                  spaceBottom: false,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: NoRiskClientColors.text,
                      fontSize: 26,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const NoRiskText('wähle deine sprache',
                  spaceTop: false,
                  spaceBottom: false,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: NoRiskClientColors.textLight, fontSize: 20)),
              const SizedBox(height: 40),
              for (final code in Config.availableLanguages)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: NoRiskButton(
                    height: 60,
                    width: double.infinity,
                    color: NoRiskClientColors.blue,
                    onTap: () => _chooseLanguage(context, code),
                    child: NoRiskText(
                      (Config.languageNames[code] ?? code).toLowerCase(),
                      spaceTop: false,
                      spaceBottom: false,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              const NoRiskText('you can change this later in settings',
                  spaceTop: false,
                  spaceBottom: false,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: NoRiskClientColors.textLight, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}
