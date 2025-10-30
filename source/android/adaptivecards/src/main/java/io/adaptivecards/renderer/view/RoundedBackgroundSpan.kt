package io.adaptivecards.renderer.view

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import android.text.TextPaint
import android.text.style.ReplacementSpan
import android.util.TypedValue
import io.adaptivecards.renderer.Utils.dpToPx

class RoundedBackgroundSpan(
    private val context: Context,
    private val textColor: Int = 0xFF424242.toInt(),
    private val backgroundColor: Int = 0xFFFAFAFA.toInt(),
    private val borderColor: Int = 0xFFE0E0E0.toInt(),
    cornerRadiusDp: Float = 4f,
    borderWidthDp: Float = 1f,
    paddingHorizontalDp: Float = 4f,
    paddingVerticalDp: Float = 2f,
    marginHorizontalDp: Float = 2f,
    private val textSizeSp: Float = 12f
) : ReplacementSpan() {

    private val cornerRadius: Float = cornerRadiusDp.dpToPx(context)
    private val borderWidth: Float = borderWidthDp.dpToPx(context)
    private val paddingHorizontal: Float = paddingHorizontalDp.dpToPx(context)
    private val paddingVertical: Float = paddingVerticalDp.dpToPx(context)
    private val marginHorizontal: Float = marginHorizontalDp.dpToPx(context)

    override fun getSize(
        paint: Paint,
        text: CharSequence,
        start: Int,
        end: Int,
        fm: Paint.FontMetricsInt?
    ): Int {
        val textPaint = getConfiguredTextPaint(paint)
        val textWidth = textPaint.measureText(text, start, end)
        val fontMetrics = textPaint.fontMetricsInt
        fm?.let {
            it.ascent = fontMetrics.ascent - paddingVertical.toInt()
            it.descent = fontMetrics.descent + paddingVertical.toInt()
            it.top = it.ascent
            it.bottom = it.descent
        }
        return (textWidth + 2 * paddingHorizontal + 2 * marginHorizontal).toInt()
    }

    override fun draw(
        canvas: Canvas,
        text: CharSequence,
        start: Int,
        end: Int,
        x: Float,
        top: Int,
        y: Int,
        bottom: Int,
        paint: Paint
    ) {
        val textPaint = getConfiguredTextPaint(paint)
        val textWidth = textPaint.measureText(text, start, end)
        val fontMetrics = textPaint.fontMetrics

        // Rectangle bounds
        val rectTop = y + fontMetrics.ascent - paddingVertical
        val rectBottom = y + fontMetrics.descent + paddingVertical

        // Detect RTL text direction
        val isRtl =
            Character.getDirectionality(text[start]) == Character.DIRECTIONALITY_RIGHT_TO_LEFT
        val rectLeft: Float
        val rectRight: Float
        val textX: Float

        if (isRtl) {
            rectRight = x - marginHorizontal
            rectLeft = rectRight - textWidth - 2 * paddingHorizontal
            textX = rectRight - paddingHorizontal - textWidth
        } else {
            rectLeft = x + marginHorizontal
            rectRight = rectLeft + textWidth + 2 * paddingHorizontal
            textX = rectLeft + paddingHorizontal
        }

        // Draw background
        val backgroundPaint = Paint(textPaint).apply {
            color = backgroundColor
            style = Paint.Style.FILL
            isAntiAlias = true
        }
        val rect = RectF(rectLeft, rectTop, rectRight, rectBottom)
        canvas.drawRoundRect(rect, cornerRadius, cornerRadius, backgroundPaint)

        // Draw border
        val borderPaint = Paint(textPaint).apply {
            color = borderColor
            style = Paint.Style.STROKE
            strokeWidth = borderWidth
            isAntiAlias = true
        }
        canvas.drawRoundRect(rect, cornerRadius, cornerRadius, borderPaint)

        // Draw text centered vertically
        textPaint.color = textColor
        val textBaseline = y.toFloat()
        canvas.drawText(text, start, end, textX, textBaseline, textPaint)
    }

    private fun getConfiguredTextPaint(basePaint: Paint): TextPaint {
        val textPaint = if (basePaint is TextPaint) TextPaint(basePaint) else TextPaint(basePaint)
        // Set text size to textSizeSp
        textPaint.textSize = TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_SP, textSizeSp, context.resources.displayMetrics
        )
        textPaint.isAntiAlias = true
        return textPaint
    }
}
