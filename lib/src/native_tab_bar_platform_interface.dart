library native_tab_bar_platform;

import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import './native_tab_bar.dart';
import './pigeons.g.dart';

export './native_tab_bar.dart';
export './pigeons.g.dart'
    show
        NativeTabBarHostApi,
        NativeTabBarFlutterApi,
        NativeTabBarApiStyle,
        RGBAColor,
        NativeTab;

/// The interface that implementations of `native_tab_bar` must implement.
///
/// Platform implementations must **extend** this class rather than implement it
/// as `native_tab_bar` does not consider newly added methods to be breaking changes.
///
/// This is because of the differences between:
/// - Extending this class (using `extends`): implementation gets default
/// implementation, so no work is needed except updating the dependency version.
/// - Implementing this class (using `implements`): interface will be broken
/// by newly added methods, meaning more code to be added (more work),
/// but custom implementation (more control).

class _PlaceholderImplementation extends NativeTabBarPlatform {}

abstract class NativeTabBarPlatform extends PlatformInterface
    implements NativeTabBarFlutterApi {
  NativeTabBarPlatform({double? defaultHeight})
      : this.defaultHeight = defaultHeight ?? 32.0,
        super(token: _token);

  static final Object _token = Object();

  /// The default instance of [NativeTabBarPlatform] to use.
  ///
  /// Defaults to [NativeTabBarPlatform] implemented in `native_tab_bar_platform_interface`.
  static NativeTabBarPlatform _instance = _PlaceholderImplementation();

  /// The instance of [NativeTabBarPlatform] to use.
  ///
  /// Defaults to a placeholder that does not override any methods, and thus
  /// throws `UnimplementedError` in most cases.
  static NativeTabBarPlatform get instance => _instance;

  /// Platform-specific plugins should override this with their own
  /// platform-specific class that extends [NativeTabBarPlatform] when they
  /// register themselves.
  static set instance(NativeTabBarPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Pigeon currently only supports a single API channel/instance. Therefore, we must
  /// "register" each instance of the component with our singleton API instance (exactly
  /// the same as on the host side) so we can pass messages to the proper component instance.
  Map<String, NativeTabBarState> _widgetInstances = {};

  void register(NativeTabBarState state) {
    if (!isFlutterApiSetup) {
      NativeTabBarFlutterApi.setup(this);
      isFlutterApiSetup = true;
    }

    _widgetInstances[state.id] = state;
  }

  void deregister(NativeTabBarState state) {
    _widgetInstances.remove(state.id);
  }

  bool isFlutterApiSetup = false;

  NativeTabBarHostApi api = NativeTabBarHostApi();

  @override
  void wantsHeight(String id, double height) {
    _widgetInstances[id]?.setWantedHeight(height);
  }

  @override
  void valueChanged(String id, int selectedIndex) {
    _widgetInstances[id]?.onValueChanged(selectedIndex);
  }

  @override
  void refresh(String id) {
    _widgetInstances[id]?.refresh();
  }

  // Default bottom tab control height for the platform.
  final double defaultHeight;

  final String viewType = 'com.dra11y.flutter.native_tab_bar';

  Widget buildPlatformWidget(NativeTabBarState state, BuildContext context) {
    throw UnimplementedError(
        'buildPlatformWidget() has not been implemented on this platform.');
  }

  Future<void> onPlatformViewCreated({
    required String id,
    required NativeTabBarState state,
    required BuildContext context,
  }) async {
    register(state);
    final tabItems = state.tabs;
    await api.setTabs(id, tabItems, state.selectedIndex);
    await api.setStyle(id, state.widget.style);
  }
}
