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
    cornerRadiusDp: Float = 8f,
    paddingHorizontalDp: Float = 8f,
    paddingVerticalDp: Float = 4f
) : ReplacementSpan() {

    private val cornerRadius: Float = cornerRadiusDp.dpToPx(context)
    private val paddingHorizontal: Float = paddingHorizontalDp.dpToPx(context)
    private val paddingVertical: Float = paddingVerticalDp.dpToPx(context)

    override fun getSize(
        paint: Paint,
        text: CharSequence,
        start: Int,
        end: Int,
        fm: Paint.FontMetricsInt?
    ): Int {
        val textWidth = paint.measureText(text, start, end)
        return (textWidth + 2 * paddingHorizontal).toInt()
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
        val rectLeft = x
        val rectRight = x + textWidth + 2 * paddingHorizontal

        val backgroundPaint = Paint(paint).apply {
            color = backgroundColor
            isAntiAlias = true
        }

        val rect = RectF(rectLeft, rectTop, rectRight, rectBottom)
        canvas.drawRoundRect(rect, cornerRadius, cornerRadius, backgroundPaint)

        paint.color = textColor
        canvas.drawText(text, start, end, x + paddingHorizontal, y.toFloat(), paint)

        paint.color = originalColor
    }
}