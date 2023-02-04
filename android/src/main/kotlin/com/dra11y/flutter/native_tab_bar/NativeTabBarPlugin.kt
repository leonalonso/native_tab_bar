package com.dra11y.flutter.native_tab_bar

import com.dra11y.flutter.native_flutter_fonts.FlutterFontRegistry
import com.dra11y.flutter.native_flutter_fonts.NativeFlutterFontsPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding

class NativeTabBarPlugin : FlutterPlugin {
    companion object {
        const val viewTypeId = "com.dra11y.flutter.native_tab_bar.android"
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPluginBinding) {
        val hostApi = NativeTabBarHostApiAndroid()
        val flutterApi = NativeTabBarFlutterApi(binaryMessenger = flutterPluginBinding.binaryMessenger)

        flutterPluginBinding
            .platformViewRegistry
            .registerViewFactory(
                viewTypeId,
                NativeTabBarViewFactory(
                    hostApi = hostApi,
                    flutterApi = flutterApi,
                    flutterAssets = flutterPluginBinding.flutterAssets,
                ),
            )
        NativeTabBarHostApi.setUp(flutterPluginBinding.binaryMessenger, api = hostApi)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        NativeTabBarHostApi.setUp(binding.binaryMessenger, api = null)
    }
}
