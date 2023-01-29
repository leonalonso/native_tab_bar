package com.dra11y.flutter.native_tab_bar

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.JSONMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import org.json.JSONObject

class NativeTabBarViewFactory(
    private val hostApi: NativeTabBarHostApiAndroid,
    private val flutterApi: NativeTabBarFlutterApi,
    private val flutterAssets: FlutterPlugin.FlutterAssets,
) : PlatformViewFactory(JSONMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val id = (args as? JSONObject)?.optString("id") ?:
            throw Error("Instance ID must be passed from Flutter via JSONMessageCodec as { 'id': String }")
        return NativeTabBarViewController(
            id = id,
            context = context,
            viewId = viewId,
            hostApi = hostApi,
            flutterApi = flutterApi,
            flutterAssets = flutterAssets,
        )
    }
}
