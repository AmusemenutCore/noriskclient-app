import 'dart:async';
import 'package:flutter/material.dart';
import 'package:noriskclient/main.dart';
import 'package:noriskclient/l10n/app_localizations.dart';
import 'package:noriskclient/config/Colors.dart';
import 'package:noriskclient/provider/localeProvider.dart';
import 'package:noriskclient/provider/themeModeProvider.dart';
import 'package:noriskclient/screens/Chats.dart';
import 'package:noriskclient/screens/McReal.dart';
import 'package:noriskclient/screens/News.dart';
import 'package:noriskclient/screens/NoRiskProfile.dart';
import 'package:noriskclient/widgets/BottomNavigationBar.dart';
import 'package:noriskclient/screens/SignIn.dart';
import 'package:noriskclient/widgets/NoRiskContainer.dart';
import 'package:noriskclient/widgets/NoRiskText.dart';
import 'package:provider/provider.dart';

class NoRiskClient extends StatefulWidget {
  const NoRiskClient({super.key, this.isGuest = false});

  /// True when there is no token: only News is reachable, and the nav's
  /// "You" tab becomes a "Login" entry point instead of a profile screen.
  final bool isGuest;

  @override
  State<NoRiskClient> createState() => NoRiskClientState();
}

class NoRiskClientState extends State<NoRiskClient> {
  StreamController<int> activeTabIndexController = StreamController<int>();
  late int tabIndex = widget.isGuest ? 0 : activeTabIndex;
  late final PageController _pageController;
  late final StreamSubscription _tabSub;

  @override
  void dispose() {
    _tabSub.cancel();
    _pageController.dispose();
    activeTabIndexController.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    provider.loadLocale();
    Provider.of<ThemeModeProvider>(context, listen: false).loadThemeMode();

    _pageController = PageController(initialPage: tabIndex);

    _tabSub = activeTabIndexController.stream.listen((index) {
      updateStream.add(["tabIndex", index]);
      setState(() {
        tabIndex = index;
      });
      // Switch immediately to the requested tab so taps do not pass through
      // intermediate pages during a short animation.
      if (_pageController.hasClients) {
        _pageController.jumpToPage(index);
      }
    });
  }

  Widget getActiveTab() {
    // Guests only have a token-free screen to show; Chats/McReal/Profile all
    // require a signed-in user, so the nav never routes a guest to them.
    if (widget.isGuest) {
      return News();
    }
    switch (tabIndex) {
      case 0:
        return News(); // News
      case 1:
        return Chats(); // Chat
      case 2:
        return McReal();
      case 3:
        return Profile(uuid: userData['uuid'], isSettings: true); // You
      default:
        return McReal();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Use a PageView for both guests and signed-in users so swiping
          // between tabs works in both modes. Guests receive a reduced set
          // of pages (News + Login placeholder).
          PageView(
            controller: _pageController,
            onPageChanged: (index) async {
              // If guest swipes to the login slot, open SignIn and return
              // the PageView back to the News tab instead of showing a
              // placeholder page.
              updateStream.add(["tabIndex", index]);
              if (widget.isGuest && index == 1) {
                // animate back to the first page to avoid leaving a blank
                // placeholder visible.
                if (_pageController.hasClients) {
                  _pageController.animateToPage(0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut);
                }
                if (!mounted) return;
                await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SignIn()));
                return;
              }
              setState(() {
                tabIndex = index;
              });
            },
            children: widget.isGuest
                ? [
                    News(),
                    // Lightweight placeholder prompting sign-in; keeps the
                    // SignIn flow as a pushed route to preserve its scaffold.
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            NoRiskText(
                              AppLocalizations.of(context)!
                                  .navbar_login
                                  .toLowerCase(),
                              style: TextStyle(
                                fontSize: 26,
                                color: NoRiskClientColors.text,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            NoRiskText(
                              AppLocalizations.of(context)!
                                  .signIn_explanation
                                  .toLowerCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: NoRiskClientColors.textLight),
                            ),
                            const SizedBox(height: 18),
                            NoRiskContainer(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 18),
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SignIn(),
                                  ),
                                ),
                                child: NoRiskText(
                                  AppLocalizations.of(context)!
                                      .navbar_login
                                      .toLowerCase(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]
                : [
                    News(),
                    Chats(),
                    McReal(),
                    Profile(uuid: userData['uuid'], isSettings: true),
                  ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: NoRiskBottomNavigationBar(
              isGuest: widget.isGuest,
              currentIndex: tabIndex,
              currentIndexController: activeTabIndexController,
              pageController: _pageController,
            ),
          ),
        ],
      ),
    );
  }
}
