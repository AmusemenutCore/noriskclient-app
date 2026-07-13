import 'package:flutter/material.dart';
import 'package:noriskclient/config/Colors.dart';
import 'package:noriskclient/l10n/app_localizations.dart';
import 'package:noriskclient/widgets/NoRiskButton.dart';
import 'package:noriskclient/widgets/NoRiskContainer.dart';
import 'package:noriskclient/widgets/NoRiskText.dart';

/// Explains where the login QR code comes from (the NoRiskClient Launcher,
/// which is a separate PC download) before the user is asked to scan one.
/// Shown automatically the first time, reachable afterwards from SignIn.
class QrGuide extends StatelessWidget {
  const QrGuide({
    super.key,
    required this.onScanNow,
    required this.onLater,
  });

  /// User understood and wants to scan a QR code right away.
  final void Function() onScanNow;

  /// User wants to get the Launcher / QR code later; go to sign-in as-is.
  final void Function() onLater;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: NoRiskClientColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              NoRiskText(t.qrGuide_title.toLowerCase(),
                  spaceTop: false,
                  spaceBottom: false,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: NoRiskClientColors.text,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              Expanded(
                child: ListView(
                  children: [
                    _GuideStep(number: 1, text: t.qrGuide_step1),
                    _GuideStep(number: 2, text: t.qrGuide_step2),
                    _GuideStep(number: 3, text: t.qrGuide_step3),
                    _GuideStep(number: 4, text: t.qrGuide_step4),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              NoRiskButton(
                height: 60,
                color: NoRiskClientColors.blue,
                onTap: onScanNow,
                child: NoRiskText(
                  t.qrGuide_scanNow.toLowerCase(),
                  spaceTop: false,
                  spaceBottom: false,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: onLater,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: NoRiskText(
                    t.qrGuide_later.toLowerCase(),
                    spaceTop: false,
                    spaceBottom: false,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: NoRiskClientColors.textLight, fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          NoRiskContainer(
            width: 34,
            height: 34,
            color: NoRiskClientColors.blue,
            child: Center(
              child: NoRiskText('$number',
                  spaceTop: false,
                  spaceBottom: false,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: NoRiskText(
              text,
              spaceTop: false,
              spaceBottom: false,
              style: TextStyle(
                  color: NoRiskClientColors.text, fontSize: 18, height: 1.1),
            ),
          ),
        ],
      ),
    );
  }
}
