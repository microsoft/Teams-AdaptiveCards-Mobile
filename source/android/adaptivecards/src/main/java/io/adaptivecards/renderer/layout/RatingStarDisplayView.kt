// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.layout

import android.content.Context
import android.graphics.Typeface
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import android.view.Gravity
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.res.ResourcesCompat
import com.google.android.flexbox.AlignItems
import com.google.android.flexbox.FlexWrap
import com.google.android.flexbox.FlexboxLayout
import io.adaptivecards.R
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.RatingColor
import io.adaptivecards.objectmodel.RatingStyle
import io.adaptivecards.objectmodel.RatingLabel
import io.adaptivecards.objectmodel.RatingSize
import io.adaptivecards.renderer.Util
import io.adaptivecards.renderer.readonly.RatingElementRendererUtil

/**
 * View to display the read only rating stars
 **/
class RatingStarDisplayView: FlexboxLayout {

    private var value: Double = 0.0

    private var maxStarsCount = 5

    private var size = RatingSize.Medium

    private var style = RatingStyle.Default

    private var count: Long? = null

    private lateinit var color: RatingColor

    private val ratingStars: MutableList<ImageView> = ArrayList()

    private lateinit var hostConfig: HostConfig

    constructor(
        context: Context,
        ratingLabel: RatingLabel,
        hostConfig: HostConfig
    ) : super(context) {
        this.maxStarsCount = (ratingLabel.GetMax().toInt()).coerceAtMost(5)
        this.value = ratingLabel.GetValue()
        this.hostConfig = hostConfig
        this.size = ratingLabel.GetRatingSize()
        this.style = ratingLabel.GetRatingStyle()
        this.count = ratingLabel.GetCount()
        this.color = ratingLabel.GetRatingColor()
        initStars()
    }

    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs) {
        initStars()
    }

    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(context, attrs, defStyleAttr) {
        initStars()
    }

    private fun initStars() {
        flexWrap = FlexWrap.WRAP
        alignItems = AlignItems.CENTER
        layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT)

        when (style) {
            RatingStyle.Compact -> compactStyle()
            else -> defaultStyle()
        }
    }

    private fun defaultStyle() {
        for (i in 0 until maxStarsCount) {
            val star = ImageView(context)
            star.apply {
                setImageDrawable(getStarDrawable())
                isActivated = true
                setColorFilter(RatingElementRendererUtil.getReadOnlyStarColor(color, i < value.toInt(), hostConfig))
                layoutParams = LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT)
            }
            ratingStars.add(star)
            val rightMargin = if (i < maxStarsCount - 1) MARGIN_BETWEEN_STARS else MARGIN_BETWEEN_STARS_AND_RATING_TEXT
            addViewWithMargin(star, rightMargin)
        }
        addRatingAndCount()
    }

    /**
     * A single activated star with the rating value is shown in the compact style
     * if count is present, it is shown next to the rating value
     **/
    private fun compactStyle() {
        val star = ImageView(context)
        star.apply {
            setImageDrawable(getStarDrawable())
            isActivated = true
            setColorFilter(RatingElementRendererUtil.getReadOnlyStarColor(color, true, hostConfig))
            layoutParams = LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT)
        }
        ratingStars.add(star)
        addViewWithMargin(star, MARGIN_BETWEEN_STARS_AND_RATING_TEXT)
        addRatingAndCount()
    }

    private fun addUsersCountTextView(countValue: Long) {
        val dotTextView = createTextView("·", hostConfig.GetRatingLabelConfig().ratingTextColor, Typeface.BOLD)
        addViewWithMargin(dotTextView, MARGIN_BETWEEN_RATING_TEXT_AND_DOT_COUNT)

        val formattedCount = RatingElementRendererUtil.formatNumberWithCommas(countValue)
        val countTextView = createTextView(formattedCount, hostConfig.GetRatingLabelConfig().countTextColor, Typeface.NORMAL)
        addView(countTextView)
    }

    /**
     * adds the rating and count value to the stars
     **/
    private fun addRatingAndCount() {
        val rating = if (value.rem(1.0) == 0.0) value.toInt() else value
        val ratingTextView = createTextView(rating.toString(), hostConfig.GetRatingLabelConfig().ratingTextColor, Typeface.BOLD)
        count?.let {
            if (it == 0L) {
                addView(ratingTextView)
            } else {
                addViewWithMargin(ratingTextView, MARGIN_BETWEEN_RATING_TEXT_AND_DOT_COUNT)
                addUsersCountTextView(it)
            }
        } ?: addView(ratingTextView)
    }

    private fun createTextView(text: String, textColor: String, style: Int): TextView {
        val color = RatingElementRendererUtil.getColorFromHexCode(textColor)
        val textView = TextView(context)
        textView.apply {
            setText(text)
            setTextColor(color)
            textSize = 16F
            setTypeface(null, style)
            layoutParams = LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT)
            gravity = Gravity.CENTER_VERTICAL
        }
        return textView
    }

    private fun addViewWithMargin(view: View, rightMargin: Int) {
        val rightMarginInPixels = Util.dpToPixels(context, rightMargin.toFloat())
        val params = view.layoutParams as LayoutParams
        params.rightMargin = rightMarginInPixels
        addView(view, params)
    }

    /**
     * get the star drawable based on the size
     **/
    private fun getStarDrawable(): Drawable? {
        return when (size) {
            RatingSize.Large -> ResourcesCompat.getDrawable(resources, R.drawable.rating_star_selector_medium, null)
            else -> ResourcesCompat.getDrawable(resources, R.drawable.rating_star_selector_small, null)
        }
    }

    companion object {
        private const val MARGIN_BETWEEN_STARS = 4
        private const val MARGIN_BETWEEN_STARS_AND_RATING_TEXT = 8
        private const val MARGIN_BETWEEN_RATING_TEXT_AND_DOT_COUNT = 4
    }
}