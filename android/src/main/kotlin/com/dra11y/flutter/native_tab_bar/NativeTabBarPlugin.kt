package com.dra11y.flutter.native_tab_bar

import android.graphics.Typeface
import androidx.annotation.NonNull
import com.google.gson.Gson
import com.google.gson.annotations.SerializedName
import com.google.gson.reflect.TypeToken
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding

data class FontManifestEntry(
    @SerializedName("family")
    val family: String,
    @SerializedName("fonts")
    val fonts: List<Asset>,
) {
    data class Asset(
        @SerializedName("asset")
        val asset: String,
    )
}

class FontRegistry {
    companion object {
        private const val defaultFontFamily = "MaterialIcons"
        private val registeredTypefaces = mutableMapOf<String, Typeface>()

        fun resolve(family: String?): Typeface? {
            return registeredTypefaces[family ?: defaultFontFamily]
        }

        fun registerTypefaces(binding: FlutterPluginBinding) {
            val assetManager = binding.applicationContext.assets
            val manifestPath = binding.flutterAssets.getAssetFilePathByName("FontManifest.json")
            val inputStream = assetManager.open(manifestPath)
            val manifestType = object : TypeToken<List<FontManifestEntry>>() {}.type
            val manifest: List<FontManifestEntry> = Gson().fromJson(inputStream.reader(), manifestType)
            manifest.forEach { entry ->
                val family = entry.family.split("/").last()
                entry.fonts.forEach { font ->
                    val assetPath = binding.flutterAssets.getAssetFilePathByName(font.asset)
                    Typeface.createFromAsset(assetManager, assetPath)?.let { typeface ->
                        registeredTypefaces[family] = typeface
                    }
                }
            }
        }
    }
}

class NativeTabBarPlugin : FlutterPlugin {
    companion object {
        const val viewTypeId = "com.dra11y.flutter.native_tab_bar.android"
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPluginBinding) {
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
        FontRegistry.registerTypefaces(flutterPluginBinding)
        NativeTabBarHostApi.setUp(flutterPluginBinding.binaryMessenger, api = hostApi)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPluginBinding) {
        NativeTabBarHostApi.setUp(binding.binaryMessenger, api = null)
    }
}
