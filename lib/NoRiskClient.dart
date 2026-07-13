import 'dart:async';
import 'package:flutter/material.dart';
import 'package:noriskclient/main.dart';
import 'package:noriskclient/provider/localeProvider.dart';
import 'package:noriskclient/provider/themeModeProvider.dart';
import 'package:noriskclient/screens/Chats.dart';
import 'package:noriskclient/screens/McReal.dart';
import 'package:noriskclient/screens/News.dart';
import 'package:noriskclient/screens/NoRiskProfile.dart';
import 'package:noriskclient/widgets/BottomNavigationBar.dart';
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

  @override
  void dispose() {
    activeTabIndexController.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    provider.loadLocale();
    Provider.of<ThemeModeProvider>(context, listen: false).loadThemeMode();

    activeTabIndexController.stream.listen((index) {
      updateStream.add(["tabIndex", index]);
      setState(() {
        tabIndex = index;
      });
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
          getActiveTab(),
          Align(
            alignment: Alignment.bottomCenter,
            child: NoRiskBottomNavigationBar(
              isGuest: widget.isGuest,
              currentIndex: tabIndex,
              currentIndexController: activeTabIndexController,
            ),
          ),
        ],
      ),
    );
  }
}
