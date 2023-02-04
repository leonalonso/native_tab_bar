package com.dra11y.flutter.native_tab_bar

import android.content.Context
import android.content.res.ColorStateList
import android.graphics.*
import android.graphics.drawable.Drawable
import android.text.TextPaint
import android.util.TypedValue
import io.flutter.embedding.engine.plugins.FlutterPlugin
import com.dra11y.flutter.native_flutter_fonts.FlutterFontRegistry

class IconDrawable(
    private val context: Context,
    private val iconData: NativeTabIconData,
    private val flutterAssets: FlutterPlugin.FlutterAssets,
) : Drawable() {
    private val textPaint = TextPaint()
    private val paint = Paint()
    private var selectedTextValue: String? = null
    private var normalTextValue: String? = null
    private var tintList: ColorStateList? = null
    private var selectedTypeface: Typeface? = null
    private var normalTypeface: Typeface? = null

    override fun setTintList(tint: ColorStateList?) {
        this.tintList = tint
    }

    init {
        textPaint.textAlign = Paint.Align.CENTER
        textPaint.isUnderlineText = false
        textPaint.isAntiAlias = true
        if (iconData.fontFamily != null && iconData.codePoint != null) {
            normalTypeface = FlutterFontRegistry.resolve(iconData.fontFamily)
            normalTextValue = String(intArrayOf(iconData.codePoint.toInt()), 0, 1)
        }
        if (iconData.selectedFontFamily != null && iconData.selectedCodePoint != null) {
            selectedTypeface = FlutterFontRegistry.resolve(iconData.selectedFontFamily)
            selectedTextValue = String(intArrayOf(iconData.selectedCodePoint.toInt()), 0, 1)
        }
    }

    private fun getDefaultColor(attribute: Int): Int {
        val defaultColor = TypedValue()
        context.theme.resolveAttribute(attribute, defaultColor, true)
        return defaultColor.data
    }

    val isSelected: Boolean
        get() = state.contains(android.R.attr.state_selected)

    fun currentColor(): Int {
        val defaultColor = getDefaultColor(if (isSelected) R.attr.colorOnSurfaceVariant else R.attr.colorOnSurface)
        val color = tintList?.getColorForState(state, defaultColor) ?: defaultColor
        return color
    }

    override fun draw(canvas: Canvas) {
        val text = if (isSelected) selectedTextValue else normalTextValue
        text?.let { text ->
            val height = bounds.height()
            textPaint.style = Paint.Style.FILL
            textPaint.textSize = height.toFloat()
            textPaint.color = currentColor()
            textPaint.typeface = if (isSelected) selectedTypeface else normalTypeface
            val xOrigin = bounds.exactCenterX()
            val yBaseline = bounds.bottom.toFloat()
            canvas.drawText(text, xOrigin, yBaseline, textPaint)
        }
    }

    override fun isStateful(): Boolean = true

    override fun setAlpha(alpha: Int) {
        textPaint.alpha = alpha
    }

    override fun setColorFilter(colorFilter: ColorFilter?) {
        textPaint.colorFilter = colorFilter
    }

    @Deprecated("Deprecated in Java")
    override fun getOpacity(): Int = textPaint.alpha
}

