import 'package:flutter/material.dart';

import '../utils/all.dart';

class SambazaNavBar extends StatelessWidget {
  final int activeIndex;
  final List<SambazaNav> navs;
  final void Function(int) onTap;

  SambazaNavBar({required this.activeIndex, required this.navs, required this.onTap});

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    TextStyle? textStyle = themeData.textTheme.bodySmall;
    return BottomNavigationBar(
      currentIndex: activeIndex,
      items: navs
          .map<BottomNavigationBarItem>(
            (SambazaNav nav) => BottomNavigationBarItem(
              activeIcon: Icon(
                nav.icon,
                color: themeData.primaryColor,
                semanticLabel: nav.label,
              ),
              icon: Icon(
                nav.icon,
                color: themeData.primaryIconTheme.color,
                semanticLabel: nav.label,
              ),
              label: 
                nav.title,
              // style: _isActive(nav)
              //       ? textStyle
              //           .merge(TextStyle(color: themeData.primaryColorDark))
              //       : textStyle,
              
            ),
          )
          .toList(),
      onTap: onTap,
      showUnselectedLabels: true,
    );
  }

  bool _isActive(SambazaNav nav) => activeIndex == navs.indexOf(nav);
}
