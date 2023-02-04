package com.dra11y.flutter.native_tab_bar

import android.annotation.SuppressLint
import android.content.Context
import android.content.res.ColorStateList
import android.content.res.Configuration
import android.content.res.Resources
import android.content.res.Resources.Theme
import android.graphics.Color
import android.os.Build
import android.util.TypedValue
import androidx.annotation.RequiresApi
import androidx.core.content.res.ResourcesCompat.ThemeCompat
import com.google.android.material.bottomnavigation.BottomNavigationMenuView
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.google.android.material.navigation.NavigationBarMenuView
import com.google.android.material.shape.CornerSize
import com.google.android.material.shape.EdgeTreatment
import com.google.android.material.shape.ShapeAppearanceModel
import com.google.android.material.theme.MaterialComponentsViewInflater
import com.google.android.material.theme.overlay.MaterialThemeOverlay
import io.flutter.embedding.engine.plugins.FlutterPlugin
import kotlin.math.roundToInt

@SuppressLint("ViewConstructor")
class MyNativeTabBarNavigation(
    private val id: String,
    context: Context,
    private val flutterApi: NativeTabBarFlutterApi,
    private val flutterAssets: FlutterPlugin.FlutterAssets,
    // TODO: Make responsive for different screen sizes.
) : BottomNavigationView(
    context,
    null,
    R.attr.bottomNavigationStyle,
) {
    private var style: NativeTabBarApiStyle? = null

    private fun colorLightness(color: Int): Int {
        val rgb = intArrayOf(Color.red(color), Color.green(color), Color.blue(color))
        return Math.sqrt(
            rgb[0] * rgb[0] * .241 + (rgb[1]
                    * rgb[1] * .691) + rgb[2] * rgb[2] * .068
        ).toInt()
    }

    private fun colorIsLight(color: Int): Boolean = colorLightness(color) > 200

    private fun contrastingWhiteOrBlack(color: Int) = if (colorIsLight(color)) Color.BLACK else Color.WHITE

    // Scale by the `density` rather than the `scaledDensity`, otherwise `scaledDensity` gets applied twice.
    private fun dpToPx(dp: Int): Int =
        (dp.toFloat() * context.resources.displayMetrics.density).roundToInt()

    private fun pxToDp(px: Int): Int =
        (px.toFloat() / context.resources.displayMetrics.density).roundToInt()

    private val tabs: MutableList<NativeTab> = mutableListOf()

    private fun getIsNightMode(isDarkTheme: Boolean? = null): Boolean =
        isDarkTheme ?: (
                Configuration.UI_MODE_NIGHT_YES == (
                        context.resources.configuration.uiMode
                            .and(Configuration.UI_MODE_NIGHT_MASK)
                        )
                )

    fun setTabs(tabs: List<NativeTab>) {
        this.tabs.clear()
        this.tabs.addAll(tabs)
        replaceTabs()
    }

    fun setSelected(index: Int) {
        if (index < 0 || index > tabs.count() - 1) return
        selectedItemId = menu.getItem(index).itemId
    }

    private fun replaceTabs() {
        menu.clear()
        tabs.forEachIndexed { index, tabItem ->
            menu.add(0, index, index, tabItem.title)
        }
        setStyle()
    }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onConfigurationChanged(newConfig: Configuration?) {
        super.onConfigurationChanged(newConfig)
        flutterApi.refresh(id) { }
    }

    override fun getMaxItemCount(): Int = 5

    @SuppressLint("RestrictedApi")
    override fun createNavigationBarMenuView(context: Context): NavigationBarMenuView {
        val view = BottomNavigationMenuView(context)
        return BottomNavigationMenuView(context)
        // TODO: Make responsive for different screen sizes.
        // NOTE: This will not just work as-is.
        // return NavigationRailMenuView(context)
    }

    private fun getDefaultColor(attribute: Int): Int {
        val defaultColor = TypedValue()
        context.theme.resolveAttribute(attribute, defaultColor, true)
        return defaultColor.data
    }

    private fun makeSelectedAndNormalColorStateList(selected: Int, normal: Int) = ColorStateList(
        arrayOf(
            intArrayOf(android.R.attr.state_selected),
            intArrayOf(-android.R.attr.state_selected)
        ),
        intArrayOf(selected, normal),
    )

    fun setStyle(newStyle: NativeTabBarApiStyle? = null): Boolean {
        if (newStyle != null) this.style = newStyle

        val isNightMode = getIsNightMode(style?.isDarkTheme)

        labelVisibilityMode = LABEL_VISIBILITY_LABELED

        backgroundTintList = ColorStateList(
            arrayOf(intArrayOf(android.R.attr.state_enabled)),
            intArrayOf(getDefaultColor(R.attr.colorSurface))
        )

        val isMaterial3 = style?.isMaterial3 != false

        itemActiveIndicatorShapeAppearance = if (!isMaterial3) null else
            ShapeAppearanceModel.builder().setAllCornerSizes(ShapeAppearanceModel.PILL).build()

        val selectedMaterialIndicatorBackgroundColor =
            style?.materialIndicatorBackgroundColor?.color
                ?: getDefaultColor(R.attr.colorSecondaryContainer)

        val material3IconColor = style?.materialIndicatorForegroundColor?.color
            ?: contrastingWhiteOrBlack(selectedMaterialIndicatorBackgroundColor)

        val selectedTextColor = style?.selectedItemColor?.color ?: getDefaultColor(R.attr.colorOnSurface)

        val selectedIconColor = if (isMaterial3) material3IconColor else selectedTextColor

        itemActiveIndicatorColor = if (isMaterial3) ColorStateList(
            arrayOf(intArrayOf(android.R.attr.state_selected)),
            intArrayOf(selectedMaterialIndicatorBackgroundColor),
        ) else ColorStateList(
            arrayOf(intArrayOf(android.R.attr.state_selected)),
            intArrayOf(Color.TRANSPARENT),
        )

        itemTextColor = makeSelectedAndNormalColorStateList(
            selected = selectedTextColor,
            normal = style?.itemColor?.color ?: getDefaultColor(R.attr.colorOnSurfaceVariant),
        )

        itemIconTintList = makeSelectedAndNormalColorStateList(
            selected = selectedIconColor,
            normal = style?.itemColor?.color ?: getDefaultColor(R.attr.colorOnSurfaceVariant),
        )

        val bgColor = if (isNightMode)
            style?.backgroundColorDark?.color
        else
            style?.backgroundColor?.color

        setBackgroundColor(bgColor ?: Color.TRANSPARENT)

        tabs.forEachIndexed { index, tabItem ->
            tabItem.nativeTabIcon?.let { iconData ->
                menu.getItem(index)?.apply {
                    icon = IconDrawable(
                        context = context,
                        iconData = iconData,
                        flutterAssets = flutterAssets,
                    )
                    if (isMaterial3) {
                        itemPaddingTop = dpToPx(12)
                        itemPaddingBottom = dpToPx(16)
                    } else {
                        itemPaddingTop = dpToPx(8)
                        itemPaddingBottom = dpToPx(10)
                    }
                }
            }
        }

        val wantedHeight: Double = if (isMaterial3) 80.0 else 56.0

        flutterApi.wantsHeight(id, wantedHeight) { }

        return true
    }
}
