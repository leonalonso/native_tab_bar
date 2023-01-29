import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: './lib/src/pigeons.g.dart',
    swiftOut: './ios/Classes/GeneratedPigeons.swift',
    kotlinOut:
        './android/src/main/kotlin/com/dra11y/flutter/native_tab_bar/GeneratedPigeons.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.dra11y.flutter.native_tab_bar',
    ),
  ),
)

/// A tab item that includes the title label and native icon data.
class NativeTab {
  String? title;
  NativeTabIconData? nativeTabIcon;
}

/// A color formatted for the API to pass between Flutter and native code.
class RGBAColor {
  double? red;
  double? green;
  double? blue;
  double? alpha;
}

/// Data for an icon for the API to pass between Flutter and native code.
class NativeTabIconData {
  NativeTabIconData({
    this.codePoint,
    this.fontFamily,
    this.selectedCodePoint,
    this.selectedFontFamily,
  });

  final int? codePoint;
  final String? fontFamily;
  final int? selectedCodePoint;
  final String? selectedFontFamily;
}

/// The style of the NativeTabBar.
class NativeTabBarApiStyle {
  bool? isDarkTheme;

  /// Whether Material 3 is active on Android, which affects the tab bar height.
  /// Defaults to `true`. Does not affect iOS.
  bool? isMaterial3;

  /// The primary color of an unselected tab item.
  RGBAColor? itemColor;

  /// The primary color of the currently selected tab item.
  RGBAColor? selectedItemColor;

  /// The background color of the tab bar in light mode.
  RGBAColor? backgroundColor;

  /// The background color of the tab bar in dark mode.
  RGBAColor? backgroundColorDark;

  /// In Material 3 (Android only), the "pill" color of the selected tab.
  RGBAColor? materialIndicatorBackgroundColor;

  /// In Material 3 (Android only), the color of the icon of the selected tab.
  /// This icon overlays the pill and defaults to either white or black,
  /// depending on the calculated lightness of the pill color.
  RGBAColor? materialIndicatorForegroundColor;
}

/// A callback API for native code to call Flutter code.
@FlutterApi()
abstract class NativeTabBarFlutterApi {
  /// Called when the native platform view renders and knows its intrinsic content height.
  void wantsHeight(String id, double height);

  /// Called by the native platform when the user taps a tab.
  void valueChanged(String id, int selectedIndex);

  /// Called when the platform code needs the widget state to invalidate and recreate the native view.
  void refresh(String id);
}

/// API for our Flutter code to pass data and call methods in native code.
@HostApi()
abstract class NativeTabBarHostApi {
  /// Called from Flutter to send the tabs to the native platform code.
  bool setTabs(String id, List<NativeTab> tabs, int? selectedIndex);

  /// Called from Flutter to pass the style to the native code.
  bool setStyle(String id, NativeTabBarApiStyle style);

  /// Called from Flutter to tell the native code to select the given tab.
  bool setSelected(String id, int? index);
}
