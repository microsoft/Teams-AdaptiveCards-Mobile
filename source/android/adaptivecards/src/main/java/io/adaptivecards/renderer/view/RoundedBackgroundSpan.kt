package io.adaptivecards.renderer.view

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import android.text.style.ReplacementSpan
import io.adaptivecards.renderer.Utils.dpToPx

class RoundedBackgroundSpan(
    context: Context,
    private val backgroundColor: Int,
    private val textColor: Int,
    cornerRadiusDp: Float,
    paddingHorizontalDp: Float,
    paddingVerticalDp: Float,
    marginHorizontalDp: Float,
) : ReplacementSpan() {

    private val cornerRadius: Float = cornerRadiusDp.dpToPx(context)
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
        val textWidth = paint.measureText(text, start, end)
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
        val originalColor = paint.color
        val textWidth = paint.measureText(text, start, end)
        val fontMetrics = paint.fontMetrics

        val textHeight = fontMetrics.descent - fontMetrics.ascent

        val rectTop = y + fontMetrics.ascent - paddingVertical
        val rectBottom = y + fontMetrics.descent + paddingVertical

        // Detect RTL text direction
        val isRtl = Character.getDirectionality(text[start]) == Character.DIRECTIONALITY_RIGHT_TO_LEFT
        val rectLeft: Float
        val rectRight: Float
        val textX: Float

        if (isRtl) {
            // For RTL, draw expanding to the left
            rectRight = x - marginHorizontal
            rectLeft = rectRight - textWidth - 2 * paddingHorizontal
            textX = rectRight - paddingHorizontal - textWidth
        } else {
            // For LTR, draw expanding to the right
            rectLeft = x + marginHorizontal
            rectRight = rectLeft + textWidth + 2 * paddingHorizontal
            textX = rectLeft + paddingHorizontal
        }

        val backgroundPaint = Paint(paint).apply {
            color = backgroundColor
            isAntiAlias = true
        }

        val rect = RectF(rectLeft, rectTop, rectRight, rectBottom)
        canvas.drawRoundRect(rect, cornerRadius, cornerRadius, backgroundPaint)
        paint.color = textColor
        canvas.drawText(text, start, end, textX, y.toFloat(), paint)
        paint.color = originalColor
    }
}