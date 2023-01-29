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
class NativeTab {
  String? title;
  NativeTabIconData? nativeTabIcon;
}

class RGBAColor {
  double? red;
  double? green;
  double? blue;
  double? alpha;
}

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

class NativeTabBarApiStyle {
  bool? isDarkTheme;

  /// Whether Material 3 is active on Android, which affects the tab bar height.
  /// Defaults to `true`. Does not affect iOS.
  bool? isMaterial3;
  RGBAColor? itemColor;
  RGBAColor? selectedItemColor;
  RGBAColor? backgroundColor;
  RGBAColor? backgroundColorDark;
  RGBAColor? materialIndicatorBackgroundColor;
  RGBAColor? materialIndicatorForegroundColor;
}

@FlutterApi()
abstract class NativeTabBarFlutterApi {
  void wantsHeight(String id, double height);
  void valueChanged(String id, int selectedIndex);
  void refresh(String id);
}

// Until Flutter team fixes the following issue, methods returning `void` generate errors:
// https://github.com/flutter/flutter/issues/111083
@HostApi()
abstract class NativeTabBarHostApi {
  /// Pigeon currently only supports one channel and one shared API instance.
  /// Therefore, we must register our state IDs with the API on the native side
  /// and send commands to the appropriate state by its instance id, otherwise
  /// all commands are sent to the final view instance on the screen.
  bool setTabs(String id, List<NativeTab> tabs, int? selectedIndex);

  bool setStyle(String id, NativeTabBarApiStyle style);

  bool setSelected(String id, int? index);
}
