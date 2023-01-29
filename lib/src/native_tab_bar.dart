import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:visibility_detector/visibility_detector.dart';

import './native_tab_bar_platform_interface.dart';
import './pigeons.g.dart';

/// Render a native tab bar platform widget.
class NativeTabBar extends StatefulWidget {
  const NativeTabBar({
    Key? key,
    required this.tabs,
    required this.style,
    this.onTap,
    this.controller,
    this.currentIndex = 0,
  })  : assert(tabs.length > 1),
        super(key: key);

  final List<NativeTab> tabs;
  final int currentIndex;
  final NativeTabBarStyle style;
  final ValueChanged<int>? onTap;
  final TabController? controller;

  @override
  NativeTabBarState createState() => NativeTabBarState();
}

/// Icon data for a tab that provides both Material (Android)
/// and Cupertino (iOS) Flutter icons.
class NativeTabIcon extends NativeTabIconData {
  factory NativeTabIcon.adaptive({
    required IconData material,
    IconData? materialSelected,
    required IconData cupertino,
    IconData? cupertinoSelected,
  }) =>
      NativeTabIcon(
        icon: Platform.isIOS ? cupertino : material,
        selectedIcon: Platform.isIOS
            ? cupertinoSelected ?? cupertino
            : materialSelected ?? material,
      );

  NativeTabIcon({
    IconData? icon,
    IconData? selectedIcon,
  }) : super(
          codePoint: icon?.codePoint,
          fontFamily: icon?.fontFamily,
          selectedCodePoint:
              (selectedIcon == null) ? icon?.codePoint : selectedIcon.codePoint,
          selectedFontFamily: (selectedIcon == null)
              ? icon?.fontFamily
              : selectedIcon.fontFamily,
        );
}

/// The style of the native tab bar widget.
class NativeTabBarStyle extends NativeTabBarApiStyle {
  NativeTabBarStyle({
    super.isDarkTheme,
    super.isMaterial3,
    Color? itemColor,
    Color? selectedItemColor,
    Color? backgroundColor,
    Color? backgroundColorDark,
    Color? materialIndicatorBackgroundColor,
    Color? materialIndicatorForegroundColor,
  }) : super(
          itemColor: itemColor?.toRGBAColor(),
          selectedItemColor: selectedItemColor?.toRGBAColor(),
          backgroundColor: backgroundColor?.toRGBAColor(),
          backgroundColorDark: backgroundColorDark?.toRGBAColor(),
          materialIndicatorBackgroundColor:
              materialIndicatorBackgroundColor?.toRGBAColor(),
          materialIndicatorForegroundColor:
              materialIndicatorForegroundColor?.toRGBAColor(),
        );
}

/// The state of the tab bar widget that survives a re-render.
/// This state gets invalidated when `refresh()` is called from the
/// platform, or when `widget.style.isMaterial3` is toggled.
class NativeTabBarState extends State<NativeTabBar> {
  @override
  void dispose() {
    super.dispose();
    if (viewId > -1) {
      NativeTabBarPlatform.instance.deregister(this);
    }
  }

  GlobalKey _globalKey = GlobalKey();

  int get selectedIndex => _selectedIndex;
  List<NativeTab> get tabs => _tabs;

  final String id = const Uuid().v4();
  int viewId = -1;
  int _selectedIndex = 0;
  double wantedHeight = NativeTabBarPlatform.instance.defaultHeight;
  List<NativeTab> _tabs = [];
  final hostApi = NativeTabBarHostApi();
  bool _isVisible = false;
  late NativeTabBarStyle _style = widget.style;

  void setViewId(int id) {
    setState(() {
      viewId = id;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabs = widget.tabs;
    _selectedIndex = widget.currentIndex;
  }

  void onValueChanged(int nativeTabIndex) {
    setState(() {
      _selectedIndex = nativeTabIndex;
    });
    widget.onTap?.call(nativeTabIndex);
    widget.controller?.index = nativeTabIndex;
  }

  void setWantedHeight(double height) {
    if (height == wantedHeight) return;

    setState(() {
      wantedHeight = height;
    });
  }

  void refresh() {
    setState(() {
      _globalKey = GlobalKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_style.isMaterial3 != widget.style.isMaterial3) {
      setState(() {
        _globalKey = GlobalKey();
        _style = widget.style;
      });
    }
    // debugDumpSemanticsTree(DebugSemanticsDumpOrder.traversalOrder);
    return VisibilityDetector(
      key: _globalKey,
      onVisibilityChanged: (visibilityInfo) {
        final isVisible = visibilityInfo.visibleFraction == 1.0;
        if (isVisible != _isVisible) {
          setState(() {
            _isVisible = isVisible;
          });
        }
      },
      child: SizedBox(
          height: wantedHeight,
          child: AnimatedOpacity(
              duration: Duration(milliseconds: 50),
              opacity: _isVisible ? 1.0 : 0.0,
              child: NativeTabBarPlatform.instance
                  .buildPlatformWidget(this, context))),
    );
  }
}

extension on Color {
  /// Convert a Flutter color to a type-safe RGBAColor for the platform API.
  RGBAColor toRGBAColor() {
    return RGBAColor(
      red: red / 255.0,
      green: green / 255.0,
      blue: blue / 255.0,
      alpha: alpha / 255.0,
    );
  }
}
