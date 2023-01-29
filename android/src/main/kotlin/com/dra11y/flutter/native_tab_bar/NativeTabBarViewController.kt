package com.dra11y.flutter.native_tab_bar

import android.content.Context
import android.view.MenuItem
import android.view.View
import android.view.View.IMPORTANT_FOR_ACCESSIBILITY_YES
import com.google.android.material.bottomnavigation.BottomNavigationMenuView
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.google.android.material.navigation.NavigationBarView
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.platform.PlatformView

interface NativeTabBarViewControllerApi {
    val viewId: Int
    fun setTabs(tabs: List<NativeTab>, selectedIndex: Int?): Boolean
    fun setStyle(style: NativeTabBarApiStyle): Boolean
}

class NativeTabBarViewController(
    val id: String,
    private val context: Context,
    override val viewId: Int,
    private val hostApi: NativeTabBarHostApiAndroid,
    private val flutterApi: NativeTabBarFlutterApi,
    private val flutterAssets: FlutterPlugin.FlutterAssets,
) : PlatformView, NativeTabBarViewControllerApi {
    private var bottomNavigation = MyNativeTabBarNavigation(
        id = id,
        context = context,
        flutterApi = flutterApi,
        flutterAssets = flutterAssets,
    )

    private fun setup() {
        bottomNavigation.setOnItemSelectedListener(object : NavigationBarView.OnItemSelectedListener {
            override fun onNavigationItemSelected(item: MenuItem): Boolean {
                flutterApi.valueChanged(id, item.itemId.toLong()) { }
                return true
            }
        })
    }

    init {
        setup()
        hostApi.register(this)
    }

    override fun getView(): View {
        // MUST set `importantForAccessibility` to 'YES' HERE in `getView`, NOT in `init`, `setup`, or elsewhere.
        bottomNavigation.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
        return bottomNavigation
    }

    override fun dispose() {
    }

    override fun setTabs(tabs: List<NativeTab>, selectedIndex: Int?): Boolean {
        bottomNavigation.setTabs(tabs)
        bottomNavigation.setSelected(selectedIndex ?: 0)
        return true
    }

    override fun setStyle(style: NativeTabBarApiStyle): Boolean = bottomNavigation.setStyle(style)
}
