// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.layout.scrollingpage

import android.animation.ArgbEvaluator
import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.util.AttributeSet
import android.util.SparseArray
import android.view.View
import androidx.annotation.ColorInt
import androidx.viewpager.widget.ViewPager
import androidx.viewpager2.widget.ViewPager2
import io.adaptivecards.R
import kotlin.math.abs

/**
 * A page indicator that displays dots for each page.
 * Currently supports [ViewPager] - other sources can be added as needed.
 * Adapted from: https://github.com/tinkoff-mobile-tech/ScrollingPagerIndicator/
 */
class ScrollingPageControlView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
    configuration: ScrollingPageControlViewConfiguration ? = null
) : View(context, attrs, defStyleAttr) {

    /**
     * Maximum number of dots which will be visible at the same time.
     * If pager has more pages than visible_dot_count, indicator will scroll to show extra dots.
     * Must be an odd number.
     */
    private var visibleDotCount = configuration?.visibleDotCount ?: resources.getInteger(R.integer.scrollingpagecontrolview_visibleDotCount)
        set(value) {
            require(value % 2 != 0) { "visibleDotCount must be odd" }
            field = value
            infiniteDotCount = visibleDotCount + 2
            if (attachRunnable != null) {
                reattach()
            } else {
                requestLayout()
            }
        }

    /**
     * Sets the minimum number of dots which should be visible.
     * If pager has less pages than visibleDotThreshold, no dots will be shown.
     */
    private var visibleDotThreshold: Int = configuration?.visibleDotThreshold ?: resources.getInteger(R.integer.scrollingpagecontrolview_visibleDotThreshold)
        set(value) {
            field = value
            if (attachRunnable != null) {
                reattach()
            } else {
                requestLayout()
            }
        }

    @ColorInt
    var dotColor: Int = configuration?.dotColor ?: resources.getColor(R.color.scrollingpagecontrolview_dotColor)
        set(value) {
            field = value
            invalidate()
        }

    @ColorInt
    var selectedDotColor: Int = configuration?.dotSelectedColor ?: resources.getColor(R.color.scrollingpagecontrolview_dotSelectedColor)
        set(value) {
            field = value
            invalidate()
        }

    private var dotMinimumSize: Int = configuration?.dotMinimumSize ?: -1
    private var infiniteDotCount = 0
    private var visibleFramePosition = 0f
    private var visibleFrameWidth = 0f
    private var firstDotOffset = 0f
    private var dotScale: SparseArray<Float> = SparseArray()
    private var itemCount = 0
    private var currentItemPosition = 0
    private val paint: Paint = Paint().apply {
        isAntiAlias = true
    }
    private val colorEvaluator = ArgbEvaluator()
    private var attachRunnable: Runnable? = null
    private var currentAttacher: IPagerAttacher<*>? = null
    private var dotCountInitialized = false
    private val isRtl: Boolean
        get() = layoutDirection == LAYOUT_DIRECTION_RTL

    private var looped: Boolean = configuration?.looped ?: false
        set(value) {
            field = value
            reattach()
            invalidate()
        }

    private var dotSize: Int = configuration?.dotSize ?: resources.getDimensionPixelSize(R.dimen.scrollingpagecontrolview_diameter_unselected)
        set(value) {
            field = value
            invalidate()
        }

    private var dotSelectedSize: Int = configuration?.dotSelectedSize ?: resources.getDimensionPixelSize(R.dimen.scrollingpagecontrolview_diameter_selected)
        set(value) {
            field = value
            invalidate()
        }

    private var dotSpacing: Int = configuration?.dotSpacing ?: resources.getDimensionPixelSize(R.dimen.scrollingpagecontrolview_dotSpacing)
        get() = field + dotSize
        set(value) {
            field = value
            invalidate()
        }

    private var entityDescription: String? = configuration?.entityDescription
        set(value) {
            field = value
            updateContentDescription()
        }

    /**
     * Attaches indicator to ViewPager
     */
    fun attachToPager(pager: ViewPager2) {
        attachToPager(pager, ViewPager2Attacher())
    }

    /**
     * Attaches to any custom pager
     */
    private fun <T> attachToPager(pager: T, attacher: IPagerAttacher<T>) {
        detachFromPager()
        attacher.attachToPager(this, pager)
        currentAttacher = attacher
        attachRunnable = Runnable {
            itemCount = -1
            attachToPager(pager, attacher)
        }
    }

    /**
     * Detaches indicator from pager.
     */
    private fun detachFromPager() {
        currentAttacher?.detachFromPager()
        currentAttacher = null
        attachRunnable = null
        dotCountInitialized = false
    }

    /**
     * Detaches indicator from pager and attaches it again.
     * Potentially useful for refreshing after adapter count change.
     */
    fun reattach() {
        attachRunnable?.let {
            it.run()
            invalidate()
        }
    }

    /**
     * @param page   index of the first page currently being displayed
     * Page position+1 will be visible if offset is nonzero
     * @param offset Value from [0, 1] indicating the offset from the page at position
     */
    fun onPageScrolled(page: Int, offset: Float) {
        if (itemCount <= 0) {
            return
        }

        val clampedPage = page.coerceIn(0, itemCount - 1)

        if (!looped || itemCount in 2..visibleDotCount) {
            dotScale.clear()

            scaleDotByOffset(clampedPage, offset)
            if (clampedPage < itemCount - 1) {
                scaleDotByOffset(clampedPage + 1, 1 - offset)
            } else if (itemCount > 1) {
                scaleDotByOffset(0, 1 - offset)
            }

            invalidate()
        }
        adjustFramePosition(offset, clampedPage)
        invalidate()
    }

    /**
     * @param position new current position
     */
    fun onPositionSelected(position: Int) {
        if (itemCount == 0) {
            return
        }

        val clampedItemPosition = position.coerceIn(0, itemCount - 1)
        currentItemPosition = clampedItemPosition
        updateContentDescription()
    }

    /**
     * Conditionally called after [onPositionSelected].
     * @param position new current position
     */
    fun updateIndicatorDotsAndPosition(position: Int) {
        if (itemCount == 0) {
            return
        }

        val clampedPosition = position.coerceIn(0, itemCount - 1)
        adjustFramePosition(0f, clampedPosition)
        updateScaleInIdleState(clampedPosition)
    }

    @SuppressLint("StringFormatMatches")
    private fun updateContentDescription() {
        // Update the contentDescription on a page change.
        val prefix = entityDescription?.let { "$it " } ?: ""
        contentDescription = prefix + context.getString(R.string.page_control_page_index, currentItemPosition + 1, itemCount)
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val measuredWidth: Int = if (itemCount >= visibleDotCount) {
            visibleFrameWidth.toInt()
        } else {
            (itemCount - 1) * dotSpacing + dotSelectedSize
        }

        val heightMode = MeasureSpec.getMode(heightMeasureSpec)
        val heightSize = MeasureSpec.getSize(heightMeasureSpec)

        val desiredHeight = dotSelectedSize
        val measuredHeight = when (heightMode) {
            MeasureSpec.EXACTLY -> heightSize
            MeasureSpec.AT_MOST -> desiredHeight.coerceAtMost(heightSize)
            MeasureSpec.UNSPECIFIED -> desiredHeight
            else -> desiredHeight
        }

        setMeasuredDimension(measuredWidth, measuredHeight)
    }

    override fun onDraw(canvas: Canvas) {
        val dotCount = dotCount.takeUnless { it < visibleDotThreshold } ?: return

        val scaleDistance = (dotSpacing + (dotSelectedSize - dotSize) / 2) * 0.7f
        val smallScaleDistance = (dotSelectedSize / 2).toFloat()
        val centerScaleDistance = 6f / 7f * dotSpacing
        val firstVisibleDotPos = (visibleFramePosition - firstDotOffset).toInt() / dotSpacing
        var lastVisibleDotPos = (
                firstVisibleDotPos +
                        (visibleFramePosition + visibleFrameWidth - getDotOffsetAt(firstVisibleDotPos)).toInt() / dotSpacing
                )

        if (firstVisibleDotPos == 0 && lastVisibleDotPos + 1 > dotCount) {
            lastVisibleDotPos = dotCount - 1
        }

        for (i in firstVisibleDotPos..lastVisibleDotPos) {
            val dot = getDotOffsetAt(i)
            if (dot >= visibleFramePosition && dot < visibleFramePosition + visibleFrameWidth) {
                var diameter: Float

                // Calculate scale according to current page position
                val scale: Float = if (looped && itemCount > visibleDotCount) {
                    val frameCenter = visibleFramePosition + visibleFrameWidth / 2
                    if (dot >= frameCenter - centerScaleDistance && dot <= frameCenter) {
                        (dot - frameCenter + centerScaleDistance) / centerScaleDistance
                    } else if (dot > frameCenter && dot < frameCenter + centerScaleDistance) {
                        1 - (dot - frameCenter) / centerScaleDistance
                    } else {
                        0f
                    }
                } else {
                    getDotScaleAt(i)
                }
                diameter = dotSize + (dotSelectedSize - dotSize) * scale

                if (itemCount > visibleDotCount) {
                    val currentScaleDistance: Float = if (!looped && (i == 0 || i == dotCount - 1)) {
                        smallScaleDistance
                    } else {
                        scaleDistance
                    }
                    val size = width

                    if (dot - visibleFramePosition < currentScaleDistance) {
                        val calculatedDiameter = diameter * (dot - visibleFramePosition) / currentScaleDistance
                        if (calculatedDiameter <= dotMinimumSize) {
                            diameter = dotMinimumSize.toFloat()
                        } else if (calculatedDiameter < diameter) {
                            diameter = calculatedDiameter
                        }
                    } else if (dot - visibleFramePosition > size - currentScaleDistance) {
                        val calculatedDiameter = diameter * (-dot + visibleFramePosition + size) / currentScaleDistance
                        if (calculatedDiameter <= dotMinimumSize) {
                            diameter = dotMinimumSize.toFloat()
                        } else if (calculatedDiameter < diameter) {
                            diameter = calculatedDiameter
                        }
                    }
                }
                paint.color = calculateDotColor(scale)

                var cx = dot - visibleFramePosition
                if (isRtl) {
                    cx = width - cx
                }
                canvas.drawCircle(
                        cx,
                        (measuredHeight / 2).toFloat(),
                        diameter / 2,
                        paint
                )
            }
        }
    }

    @ColorInt
    private fun calculateDotColor(dotScale: Float): Int {
        return colorEvaluator.evaluate(dotScale, dotColor, selectedDotColor) as Int
    }

    private fun updateScaleInIdleState(currentPos: Int) {
        if (!looped || itemCount < visibleDotCount) {
            dotScale.clear()
            dotScale.put(currentPos, 1f)

            invalidate()
        }
    }

    private fun initDots(itemCount: Int) {
        if (this.itemCount == itemCount && dotCountInitialized) {
            return
        }
        this.itemCount = itemCount
        updateContentDescription()

        dotCountInitialized = true
        dotScale = SparseArray()
        if (itemCount < visibleDotThreshold) {
            requestLayout()
            invalidate()
            return
        }
        firstDotOffset = if (looped && this.itemCount > visibleDotCount) 0f else dotSelectedSize / 2f
        visibleFrameWidth = ((visibleDotCount - 1) * dotSpacing + dotSelectedSize).toFloat()
        requestLayout()
        invalidate()
    }

    var dotCount: Int
        get() = if (looped && itemCount > visibleDotCount) {
            infiniteDotCount
        } else {
            itemCount
        }
        set(count) {
            initDots(count)
        }

    private fun adjustFramePosition(offset: Float, pos: Int) {
        if (itemCount <= visibleDotCount) {
            // Without scroll
            visibleFramePosition = 0f
        } else if (!looped && itemCount > visibleDotCount) {
            // Not looped with scroll
            val center = getDotOffsetAt(pos) + dotSpacing * offset
            visibleFramePosition = center - visibleFrameWidth / 2

            // Block frame offset near start and end
            val firstCenteredDotIndex = visibleDotCount / 2
            val lastCenteredDot = getDotOffsetAt(dotCount - 1 - firstCenteredDotIndex)
            if (visibleFramePosition + visibleFrameWidth / 2 < getDotOffsetAt(firstCenteredDotIndex)) {
                visibleFramePosition = getDotOffsetAt(firstCenteredDotIndex) - visibleFrameWidth / 2
            } else if (visibleFramePosition + visibleFrameWidth / 2 > lastCenteredDot) {
                visibleFramePosition = lastCenteredDot - visibleFrameWidth / 2
            }
        } else {
            // Looped with scroll
            val center = getDotOffsetAt(infiniteDotCount / 2) + dotSpacing * offset
            visibleFramePosition = center - visibleFrameWidth / 2
        }
    }

    private fun scaleDotByOffset(position: Int, offset: Float) {
        if (dotCount == 0) {
            return
        }
        setDotScaleAt(position, 1 - abs(offset))
    }

    private fun getDotOffsetAt(index: Int): Float {
        return firstDotOffset + index * dotSpacing
    }

    private fun getDotScaleAt(index: Int): Float {
        return dotScale[index] ?: 0f
    }

    private fun setDotScaleAt(index: Int, scale: Float) {
        if (scale == 0f) {
            dotScale.remove(index)
        } else {
            dotScale.put(index, scale)
        }
    }
}
