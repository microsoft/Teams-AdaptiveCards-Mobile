// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.layout

import android.content.Context
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import android.widget.ImageView
import android.widget.LinearLayout
import androidx.core.content.res.ResourcesCompat
import io.adaptivecards.R
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.RatingColor
import io.adaptivecards.objectmodel.RatingInput
import io.adaptivecards.objectmodel.RatingSize
import io.adaptivecards.renderer.Util
import io.adaptivecards.renderer.inputhandler.RatingInputHandler
import io.adaptivecards.renderer.readonly.RatingElementRendererUtil
import java.lang.ref.WeakReference

/**
 * View to display the input rating stars
 **/
class RatingStarInputView: LinearLayout {

    private var value = 0

    private var maxStarsCount = 5

    private lateinit var color: RatingColor

    private var size = RatingSize.Medium

    private val ratingStars: MutableList<ImageView> = ArrayList()

    private var rating = 0

    private lateinit var hostConfig: HostConfig

    private var ratingInputHandler: WeakReference<RatingInputHandler>? = null

    constructor(
        context: Context,
        hostConfig: HostConfig,
        ratingInput: RatingInput,
        ratingInputHandler: RatingInputHandler
    ) : super(context) {
        isSaveEnabled = true
        this.maxStarsCount = (ratingInput.GetMax().toInt()).coerceAtMost(5)
        this.value = (ratingInput.GetValue().toInt()).coerceAtMost(5)
        this.color = ratingInput.GetRatingColor()
        this.rating = value
        this.size = ratingInput.GetRatingSize()
        this.hostConfig = hostConfig
        this.ratingInputHandler = WeakReference(ratingInputHandler)
        initStars(context)
    }

    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs) {
        initStars(context)
    }

    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(context, attrs, defStyleAttr) {
        initStars(context)
    }

    private fun initStars(context: Context) {
        orientation = HORIZONTAL
        layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT)
        val rightMargin = Util.dpToPixels(context, RIGHT_MARGIN.toFloat())
        for (index in 0 until maxStarsCount) {
            val star = ImageView(context)
            star.apply {
                layoutParams = LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT, 0f)
                contentDescription = "Rating Star $index+1"
                setImageDrawable(getStarDrawable())
                setColorFilter(RatingElementRendererUtil.getInputStarColor(color, index < value, hostConfig))
                isActivated = index < value
                setOnClickListener {
                    handleClick(index)
                }
            }
            ratingStars.add(star)
            val params = star.layoutParams as LayoutParams
            if (index < maxStarsCount - 1) {
                params.rightMargin = rightMargin
            }
            addView(star, params)
        }
    }

    private fun handleClick(index: Int) {
        rating = index + 1
        for (i in 0 until maxStarsCount) {
            ratingStars[i].isActivated = i < rating
        }
        ratingInputHandler?.get()?.registerInputObserver()
    }

    private fun getStarDrawable(): Drawable? {
        return when (size) {
            RatingSize.Large -> ResourcesCompat.getDrawable(resources, R.drawable.rating_star_selector_large, null)
            else -> ResourcesCompat.getDrawable(resources, R.drawable.rating_star_selector_medium, null)
        }
    }

    fun getRating(): Int {
        return rating
    }

    companion object {
        private const val RIGHT_MARGIN = 12
    }
}
