// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.inputhandler

import android.view.accessibility.AccessibilityEvent
import io.adaptivecards.objectmodel.BaseInputElement
import io.adaptivecards.renderer.Util
import io.adaptivecards.renderer.layout.RatingStarInputView

/**
 * Input handler for Rating input
 **/
class RatingInputHandler(
    baseInputElement: BaseInputElement
): BaseInputHandler(baseInputElement) {
    override fun getInput() = (m_view as RatingStarInputView).getRating().toString()

    override fun setInput(input: String?) {
        // no-op
    }

    override fun setFocusToView() {
        val rating = (m_view as RatingStarInputView).getRating()
        val focusView = (m_view as RatingStarInputView).getChildAt(if (rating == 0) 0 else rating - 1)
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

    override fun registerInputObserver() {
        notifyAllInputWatchers()
    }

}