// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import './native_tab_bar_platform_interface.dart';

/// The iOS implementation of [NativeTabBarPlatform].
class NativeTabBarIOS extends NativeTabBarPlatform {
  /// Registers this class as the default instance of [NativeTabBarPlatform]
  static void registerWith() {
    NativeTabBarPlatform.instance = NativeTabBarIOS();
  }

  @override
  double get defaultHeight => 49;

  @override
  String get viewType => 'com.dra11y.flutter.native_tab_bar.ios';

  @override
  Widget buildPlatformWidget(NativeTabBarState state, BuildContext context) =>
      UiKitView(
        viewType: viewType,
        creationParamsCodec: const JSONMessageCodec(),
        creationParams: {
          'id': state.id,
        },
        onPlatformViewCreated: (viewId) async =>
            onPlatformViewCreated(id: state.id, state: state, context: context),
      );
}
