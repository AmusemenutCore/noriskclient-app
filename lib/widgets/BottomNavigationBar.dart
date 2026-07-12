import 'dart:async';

import 'package:flutter/material.dart';
import 'package:noriskclient/config/Colors.dart';
import 'package:noriskclient/l10n/app_localizations.dart';
import 'package:noriskclient/main.dart';
import 'package:noriskclient/utils/NoRiskIcon.dart';
import 'package:noriskclient/widgets/NoRiskContainer.dart';
import 'package:noriskclient/widgets/NoRiskIconButton.dart';
import 'package:noriskclient/widgets/NoRiskText.dart';

class NoRiskBottomNavigationBar extends StatefulWidget {
  NoRiskBottomNavigationBar({
    super.key,
    required this.currentIndexController,
    this.currentIndex = 2,
  });

  final StreamController<int> currentIndexController;
  int currentIndex;

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
            bottom: isAndroid ? MediaQuery.of(context).viewPadding.bottom : 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _BottomNavigationBarButton(
                index: 0,
                currentIndex: widget.currentIndex,
                icon: NoRiskIcon.news,
                label: 'news',
                onTap: () => widget.currentIndexController.sink.add(0)),
            _BottomNavigationBarButton(
              index: 1,
              currentIndex: widget.currentIndex,
              icon: NoRiskIcon.chats,
              label: 'chats',
              onTap: () => widget.currentIndexController.sink.add(1),
            ),
            _BottomNavigationBarButton(
                index: 2,
                currentIndex: widget.currentIndex,
                icon: NoRiskIcon.mcreal,
                label: 'mcreal',
                onTap: () => widget.currentIndexController.sink.add(2)),
            // Gamescom was a time-limited placeholder tab (event has since
            // passed); hidden rather than shown disabled so it doesn't read
            // as a broken tab. Re-add when there's an active event to link.
            _BottomNavigationBarButton(
                index: 3,
                currentIndex: widget.currentIndex,
                icon: NoRiskIcon.profile,
                label: AppLocalizations.of(context)!.navbar_you.toLowerCase(),
                onTap: () => widget.currentIndexController.sink.add(3)),
          ],
        ),
      ),
    );
  }
}

class _BottomNavigationBarButton extends StatelessWidget {
  const _BottomNavigationBarButton({
    super.key,
    required this.onTap,
    required this.currentIndex,
    required this.label,
    required this.icon,
    required this.index,
    this.disabled = false,
    this.fontSize = 23.5,
  });

  final void Function() onTap;
  final int currentIndex;
  final String label;
  final Widget icon;
  final int index;
  final bool disabled;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final bool active = currentIndex == index;
    return GestureDetector(
      onTap: disabled ? () {} : onTap,
            child: Stack(
              children: [
                // Active-tab indicator: a small accent-colored bar, clearer
                // at a glance than the previous opacity-only distinction.
                Align(
                  alignment: Alignment.topCenter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(top: 2),
                    height: 3,
                    width: active ? 26 : 0,
                    decoration: BoxDecoration(
                      color: NoRiskClientColors.blue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(
            width: 65,
            height: 55,
                  child: Center(
                    child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                      child: NoRiskIconButton(
                    onTap: disabled ? () {} : onTap,
                          transparent: true,
                          height: 35,
                          width: 35,
                    icon: Opacity(
                        opacity: disabled
                            ? 0.4
                            : active
                                ? 1
                                : 0.75,
                        child: icon)),
                    ),
                  ),
                ),
                SizedBox(
            width: 65,
            height: 55,
                  child: Center(
                    child: Padding(
                padding: const EdgeInsets.only(top: 20),
                          child: NoRiskText(label,
                              spaceTop: false,
                              spaceBottom: false,
                              style: TextStyle(
                        fontSize: fontSize,
                        color: disabled
                            ? Colors.white.withAlpha((100).floor())
                            : active
                                      ? NoRiskClientColors.blue
                                      : Colors.white
                                          .withAlpha((200).floor()))),
                        ),
                  ),
                ),
              ],
            ),
          );
  }
}