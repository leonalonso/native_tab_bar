package com.dra11y.flutter.native_tab_bar

import android.graphics.Color
import android.view.ViewGroup
import kotlin.math.roundToInt

val NativeTabBarApiStyle.defaultItemColor: RGBAColor
    get() = RGBAColor(0.0, 0.0, 0.0, 0.75)

val NativeTabBarApiStyle.defaultSelectedItemColor: RGBAColor
    get() = RGBAColor(0.0, 0.0, 0.0, 1.0)

val RGBAColor.css: String
    get() = "rgba(${(red ?: 1.0) * 255}, ${(green ?: 1.0) * 255}, ${(blue ?: 1.0) * 255}, ${(alpha ?: 1.0)})"

val RGBAColor.color: Int
    get() = Color.argb(
        RGBAColor.colorInt(alpha),
        RGBAColor.colorInt(red),
        RGBAColor.colorInt(green),
        RGBAColor.colorInt(blue)
    )

fun RGBAColor.Companion.colorInt(value: Double?): Int =
    ((value ?: 0.0) * 255.0).roundToInt().clamped(0, 255)

fun <T : Comparable<T>> T.clamped(minimum: T, maximum: T): T = minOf(maxOf(this, minimum), maximum)

fun Int.toHex(): String = String.format("#%06X", 0xFFFFFF and this)

fun ViewGroup.invalidateRecursive() {
    for (i in 0 until childCount) {
        getChildAt(i)?.let { child ->
            if (child is ViewGroup) child.invalidateRecursive()
            else child.invalidate()
        }
    }
}
