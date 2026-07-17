import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noriskclient/config/Colors.dart';
import 'package:noriskclient/l10n/app_localizations.dart';
import 'package:noriskclient/main.dart';
import 'package:noriskclient/screens/SignIn.dart';
import 'package:noriskclient/utils/NoRiskIcon.dart';
import 'package:noriskclient/widgets/NoRiskContainer.dart';
import 'package:noriskclient/widgets/NoRiskIconButton.dart';
import 'package:noriskclient/widgets/NoRiskText.dart';

class NoRiskBottomNavigationBar extends StatefulWidget {
  NoRiskBottomNavigationBar({
    super.key,
    required this.currentIndexController,
    this.currentIndex = 2,
    this.isGuest = false,
    this.pageController,
  });

  final StreamController<int> currentIndexController;
  final int currentIndex;
  final PageController? pageController;

  /// Guests only get News + a Login entry point; Chats/McReal/You all need
  /// an account and are hidden rather than shown disabled, per the decision
  /// to keep guest browsing to a single, uncluttered tab.
  final bool isGuest;

  @override
  State<NoRiskBottomNavigationBar> createState() =>
      NoRiskBottomNavigationBarState();
}

class NoRiskBottomNavigationBarState extends State<NoRiskBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return NoRiskContainer(
      height: isAndroid ? 60 + MediaQuery.of(context).viewPadding.bottom : 70,
      width: MediaQuery.of(context).size.width,
      color: NoRiskClientColors.light,
      backgroundOpacity: 225,
      borderOpacity: 200,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: isAndroid ? MediaQuery.of(context).viewPadding.bottom : 0,
        ),
        child: LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;
          final itemCount = widget.isGuest ? 2 : 4;
          final itemWidth = width / itemCount;

          return Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: widget.isGuest
                    ? [
                        _BottomNavigationBarButton(
                          index: 0,
                          currentIndex: widget.currentIndex,
                          icon: NoRiskIcon.news,
                          label: 'news',
                          onTap: () {
                            widget.pageController?.jumpToPage(0);
                            widget.currentIndexController.sink.add(0);
                          },
                          maxLabelWidth: itemWidth * 0.9,
                        ),
                        _BottomNavigationBarButton(
                          index: 1,
                          currentIndex: widget.currentIndex,
                          icon: NoRiskIcon.profile,
                          label: AppLocalizations.of(
                            context,
                          )!.navbar_login.toLowerCase(),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => SignIn()),
                          ),
                          maxLabelWidth: itemWidth * 0.9,
                        ),
                      ]
                    : [
                        _BottomNavigationBarButton(
                          index: 0,
                          currentIndex: widget.currentIndex,
                          icon: NoRiskIcon.news,
                          label: 'news',
                          onTap: () => widget.currentIndexController.sink.add(0),
                          maxLabelWidth: itemWidth * 0.9,
                        ),
                        _BottomNavigationBarButton(
                          index: 1,
                          currentIndex: widget.currentIndex,
                          icon: NoRiskIcon.chats,
                          label: 'chats',
                          onTap: () {
                            widget.pageController?.jumpToPage(1);
                            widget.currentIndexController.sink.add(1);
                          },
                          maxLabelWidth: itemWidth * 0.9,
                        ),
                        _BottomNavigationBarButton(
                          index: 2,
                          currentIndex: widget.currentIndex,
                          icon: NoRiskIcon.mcreal,
                          label: 'mcreal',
                          onTap: () {
                            widget.pageController?.jumpToPage(2);
                            widget.currentIndexController.sink.add(2);
                          },
                          maxLabelWidth: itemWidth * 0.9,
                        ),
                        // Gamescom was a time-limited placeholder tab (event has
                        // since passed); hidden rather than shown disabled so it
                        // doesn't read as a broken tab. Re-add if there's an
                        // active event to link again.
                        _BottomNavigationBarButton(
                          index: 3,
                          currentIndex: widget.currentIndex,
                          icon: NoRiskIcon.profile,
                          label: AppLocalizations.of(
                            context,
                          )!.navbar_you.toLowerCase(),
                          onTap: () {
                            widget.pageController?.jumpToPage(3);
                            widget.currentIndexController.sink.add(3);
                          },
                          maxLabelWidth: itemWidth * 0.9,
                        ),
                      ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _BottomNavigationBarButton extends StatelessWidget {
  const _BottomNavigationBarButton({
    required this.onTap,
    required this.currentIndex,
    required this.label,
    required this.icon,
    required this.index,
    this.maxLabelWidth,
  }) : disabled = false, fontSize = 23.5;


  final void Function() onTap;
  final int currentIndex;
  final String label;
  final Widget icon;
  final int index;
  final bool disabled;
  final double fontSize;
  final double? maxLabelWidth;

  @override
  Widget build(BuildContext context) {
    final bool active = currentIndex == index;
    void handleTap() {
      if (disabled) return;
      HapticFeedback.selectionClick();
      onTap();
    }

    return GestureDetector(
      onTap: handleTap,
      child: SizedBox(
        width: 65,
        height: 55,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Active-tab indicator positioned directly above the icon
            Positioned(
              top: 4,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 3,
                width: active ? 26 : 0,
                decoration: BoxDecoration(
                  color: NoRiskClientColors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Icon (slightly shifted upward)
            Positioned(
              top: 6,
              child: NoRiskIconButton(
                onTap: handleTap,
                transparent: true,
                height: 35,
                width: 35,
                icon: Opacity(
                  opacity: disabled ? 0.4 : (active ? 1 : 0.75),
                  child: icon,
                ),
              ),
            ),
            // Label below the icon (fit within maxLabelWidth if provided)
            Positioned(
              bottom: 2,
              child: SizedBox(
                width: maxLabelWidth ?? 65,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: NoRiskText(
                    label,
                    spaceTop: false,
                    spaceBottom: false,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: disabled
                          ? NoRiskClientColors.text.withAlpha((100).floor())
                          : active
                              ? NoRiskClientColors.blue
                              : NoRiskClientColors.text.withAlpha((200).floor()),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
