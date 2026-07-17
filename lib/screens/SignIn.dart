import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:noriskclient/l10n/app_localizations.dart';
import 'package:noriskclient/config/Colors.dart';
import 'package:noriskclient/config/Config.dart';
import 'package:noriskclient/main.dart';
import 'package:noriskclient/provider/localeProvider.dart';
import 'package:noriskclient/provider/themeModeProvider.dart';
import 'package:noriskclient/screens/QrGuide.dart';
import 'package:noriskclient/utils/NoRiskApi.dart';
import 'package:noriskclient/widgets/NoRiskContainer.dart';
import 'package:noriskclient/widgets/NoRiskText.dart';
import 'package:noriskclient/widgets/QRScannerOverlayShape.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

class SignIn extends StatefulWidget {
  const SignIn({
    super.key,
    this.autoOpenScanner = false,
    this.onContinueAsGuest,
  });

  /// When true, the QR scanner opens automatically once this screen mounts.
  /// Used when the user taps "Scan QR Code Now" on the onboarding guide.
  final bool autoOpenScanner;

  /// When set, shows a "continue without an account" link that lets the user
  /// back out into guest browsing instead of completing sign-in. Only passed
  /// when this screen is shown as the app's root (right after onboarding);
  /// when pushed on top of guest mode, a back button is used instead.
  final void Function()? onContinueAsGuest;

  @override
  State<SignIn> createState() => SignInState();
}

class SignInState extends State<SignIn> {
  bool isProcessingResult = false;
  String? errorMessageKey;

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<LocaleProvider>(context, listen: false);
    provider.loadLocale();
    Provider.of<ThemeModeProvider>(context, listen: false).loadThemeMode();

    if (widget.autoOpenScanner) {
      WidgetsBinding.instance.addPostFrameCallback((_) => scanQrCode());
    }
  }

  void openQrGuide() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return QrGuide(
            onScanNow: () {
              Navigator.of(context).pop();
              scanQrCode();
            },
            onLater: () => Navigator.of(context).pop(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canGoBack = Navigator.of(context).canPop();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: NoRiskClientColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 15,
                right: 15,
                top: 0,
                bottom: 0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: isProcessingResult
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.125,
                      ),
                      GestureDetector(
                        onLongPress: showDeveloperSignInPopup,
                        child: Image.asset(
                          'lib/assets/app/norisk_logo.png',
                          height: 150,
                        ),
                      ),
                      NoRiskText(
                        'NoRisk Client'.toLowerCase(),
                        style: TextStyle(
                          color: NoRiskClientColors.text,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.15,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      NoRiskText(
                        AppLocalizations.of(
                          context,
                        )!.signIn_explanation.toLowerCase(),
                        spaceTop: false,
                        spaceBottom: false,
                        style: TextStyle(
                          height: 0.85,
                          fontSize: 17.5,
                          color: NoRiskClientColors.textLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      NoRiskText(
                        AppLocalizations.of(context)!.signIn_eula.toLowerCase(),
                        spaceTop: false,
                        spaceBottom: false,
                        style: TextStyle(
                          fontSize: 15,
                          color: NoRiskClientColors.textLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: openQrGuide,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: NoRiskText(
                            AppLocalizations.of(
                              context,
                            )!.qrGuide_helpLink.toLowerCase(),
                            spaceTop: false,
                            spaceBottom: false,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: NoRiskClientColors.blue,
                              decoration: TextDecoration.underline,
                              decorationColor: NoRiskClientColors.blue,
                            ),
                          ),
                        ),
                      ),
                      if (widget.onContinueAsGuest != null)
                        GestureDetector(
                          onTap: widget.onContinueAsGuest,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: NoRiskText(
                              AppLocalizations.of(
                                context,
                              )!.signIn_continueAsGuest.toLowerCase(),
                              spaceTop: false,
                              spaceBottom: false,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: NoRiskClientColors.textLight,
                                decoration: TextDecoration.underline,
                                decorationColor: NoRiskClientColors.textLight,
                              ),
                            ),
                          ),
                        ),
                      if (errorMessageKey != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: NoRiskText(
                            errorMessageKey == 'network'
                                ? AppLocalizations.of(
                                    context,
                                  )!.signIn_error_network
                                : AppLocalizations.of(
                                    context,
                                  )!.signIn_error_invalid,
                            spaceTop: false,
                            spaceBottom: false,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFFE05B5B),
                            ),
                          ),
                        ),
                      GestureDetector(
                        onTap: scanQrCode,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: NoRiskContainer(
                            height: 65,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isProcessingResult
                                  ? NoRiskClientColors.blue.withValues(alpha: 0.5)
                                  : NoRiskClientColors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: isProcessingResult
                                    ? [
                                        NoRiskText(
                                          AppLocalizations.of(
                                            context,
                                          )!.signIn_signingIn.toLowerCase(),
                                          spaceTop: false,
                                          spaceBottom: false,
                                          style: TextStyle(
                                            fontSize: 35,
                                            color: Colors.white.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                        ),
                                      ]
                                    : [
                                        NoRiskText(
                                          AppLocalizations.of(
                                            context,
                                          )!.signIn_scanQrCode.toLowerCase(),
                                          spaceTop: false,
                                          spaceBottom: false,
                                          style: TextStyle(
                                            color: isProcessingResult
                                                ? Colors.white.withValues(alpha: 0.5)
                                                : Colors.white,
                                            fontSize: 35,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => launchUrl(
                              Config.privacyUrl,
                              mode: LaunchMode.externalApplication,
                            ),
                            child: NoRiskText(
                              AppLocalizations.of(
                                context,
                              )!.settings_privacyPolicy.toLowerCase(),
                              style: TextStyle(
                                fontSize: 22.5,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 50),
                          GestureDetector(
                            onTap: () => launchUrl(
                              Config.termsUrl,
                              mode: LaunchMode.externalApplication,
                            ),
                            child: NoRiskText(
                              AppLocalizations.of(
                                context,
                              )!.settings_tos.toLowerCase(),
                              style: TextStyle(
                                fontSize: 22.5,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ],
              ),
            ),
            if (canGoBack)
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 5),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void scanQrCode() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          MobileScannerController controller = MobileScannerController();
          return Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: NoRiskClientColors.background,
            body: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: MobileScanner(
                    fit: BoxFit.fitHeight,
                    controller: controller,
                    onDetect: (BarcodeCapture result) {
                      handleQrCodeResult(
                        controller,
                        result.barcodes[0].rawValue ?? '',
                      );
                    },
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: ShapeDecoration(
                      shape: QrScannerOverlayShape(
                        borderColor: NoRiskClientColors.light,
                        borderRadius: 10,
                        borderLength: 15,
                        borderWidth: 7.5,
                        cutOutSize: MediaQuery.of(context).size.width / 1.5,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10, top: 40),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {
                        controller.stop();
                        controller.dispose();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: IconButton(
                      onPressed: () async {
                        await controller.toggleTorch();
                      },
                      icon: const Icon(
                        Icons.flash_on_rounded,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> handleQrCodeResult(
    MobileScannerController controller,
    String result,
  ) async {
    // Validate QR payload before trusting any fields.
    Map<String, dynamic> userData;
    try {
      final decoded = jsonDecode(result);
      if (decoded is! Map<String, dynamic>) return;
      userData = decoded;
    } catch (_) {
      return;
    }

    final uuid = userData['uuid'];
    final token = userData['token'];
    final experimental = userData['experimental'];
    if (uuid is! String ||
        uuid.isEmpty ||
        token is! String ||
        token.isEmpty ||
        experimental is! bool) {
      return;
    }

    Vibration.vibrate(duration: 500);

    controller.stop();
    controller.dispose();
    Navigator.of(context).pop();

    await signIn(userData);
  }

  void showDeveloperSignInPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController uuidController = TextEditingController();
        TextEditingController tokenController = TextEditingController();

        Map<String, dynamic> userData = {
          'uuid': '',
          'experimental': false,
          'token': '',
        };

        uuidController.addListener(
          () => userData['uuid'] = uuidController.text,
        );
        tokenController.addListener(
          () => userData['token'] = tokenController.text,
        );

        return AlertDialog(
          title: const Text('Developer Sign In'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'If you are not a developer, please close this dialog and use the QR code scanner.',
              ),
              const SizedBox(height: 10),
              TextField(
                controller: uuidController,
                decoration: const InputDecoration(labelText: 'UUID'),
              ),
              TextField(
                controller: tokenController,
                decoration: const InputDecoration(labelText: 'Token'),
              ),
              const SizedBox(height: 15),
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Sign In Environment:', textAlign: TextAlign.start),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      userData['experimental'] = true;
                      Navigator.of(context).pop();
                      signIn(userData);
                    },
                    child: const Text('Experimental'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      userData['experimental'] = false;
                      Navigator.of(context).pop();
                      signIn(userData);
                    },
                    child: const Text('Production'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> signIn(Map<String, dynamic> userData) async {
    setState(() {
      isProcessingResult = true;
      errorMessageKey = null;
    });

    http.Response res;
    try {
      res = await http.get(
        Uri.parse(
          '${NoRiskApi().getBaseUrl(userData['experimental'], 'mcreal')}/user/validateToken?uuid=${userData['uuid']}',
        ),
        headers: {'Authorization': 'Bearer ${userData['token']}'},
      );
    } catch (_) {
      setState(() {
        isProcessingResult = false;
        errorMessageKey = 'network';
      });
      return;
    }

    if (res.statusCode != 200) {
      setState(() {
        isProcessingResult = false;
        errorMessageKey = 'invalid';
      });
      return;
    }
    updateStream.sink.add(['signIn', userData]);
    // Close the SignIn screen after successful sign-in so the app can
    // rebuild and show the authenticated home state.
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }
}
