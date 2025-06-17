// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.inputhandler

import android.view.accessibility.AccessibilityEvent
import io.adaptivecards.objectmodel.BaseInputElement
import io.adaptivecards.objectmodel.RatingInput
import io.adaptivecards.renderer.RenderArgs
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.Util
import io.adaptivecards.renderer.layout.RatingStarInputView
import io.adaptivecards.renderer.layout.RatingStarInputViewListener

/**
 * Input handler for Rating input
 **/
class RatingInputHandler(
    baseInputElement: BaseInputElement,
    renderedAdaptiveCard: RenderedAdaptiveCard?,
    renderArgs: RenderArgs
): BaseInputHandler(baseInputElement, renderedAdaptiveCard, renderArgs) {

    override fun getInput() = (m_view as RatingStarInputView).getRating().toString()

    override fun setInput(input: String) {
        try {
            (m_view as RatingStarInputView).setRating(input.toDouble())
        } catch(e: NumberFormatException) {
            return
        }
    }

    override fun setFocusToView() {
        val focusView = (m_view as RatingStarInputView).getChildAt(0)
        Util.forceFocus(focusView)
        focusView.sendAccessibilityEvent(AccessibilityEvent.TYPE_VIEW_ACCESSIBILITY_FOCUSED)
    }

    override fun isValid(showError: Boolean): Boolean {
        var isValid = true
        if (m_baseInputElement.GetIsRequired()) {
            isValid = try {
                input.toDouble() > 0
            } catch(e: NumberFormatException) {
                false
            }
        }
        isValid = isValid && isValidOnSpecifics(input)
        if (showError) {
            showValidationErrors(isValid)
        }
        return isValid
    }


    override fun getDefaultValue(): String {
        if (Util.isOfType(m_baseInputElement, RatingInput::class.java)) {
            val ratingInput = Util.castTo(m_baseInputElement, RatingInput::class.java)
            return ratingInput.GetValue().toString()
        }
        return super.getDefaultValue()
    }

    override fun registerInputObserver() {
        (m_view as RatingStarInputView).setRatingStarInputViewListener(object: RatingStarInputViewListener {
            override fun onRatingChanged() {
                notifyAllInputWatchers()
            }
        })
        addValueChangedActionInputWatcher()
    }
}
