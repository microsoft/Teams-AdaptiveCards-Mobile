// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.inputhandler

import io.adaptivecards.objectmodel.ValueChangedAction
import io.adaptivecards.objectmodel.ValueChangedActionType
import io.adaptivecards.renderer.RenderedAdaptiveCard
import java.util.Vector

/**
 * input watcher for value changed action
 */
class ValueChangedActionInputWatcher(
    private val valueChangedAction: ValueChangedAction,
    private val renderedCard: RenderedAdaptiveCard,
    private val cardId: Long
): IInputWatcher {

    /**
     * When the input value changes, all the input fields
     * that belong to the targetIds of that input field needs to be notified
     * and their default value needs to be set
     * By iterating through the all the input handlers for that card id
     * and setting the default value of the input field where input id matches the target id
     */
    override fun onInputChange(id: String?, value: String?) {
        if(valueChangedAction.GetValueChangedActionType() == ValueChangedActionType.ResetInputs) {
            for (target in valueChangedAction.GetTargetInputIds()) {
                val inputHandlers: Vector<IInputHandler> =
                    renderedCard.getInputsHandlerFromCardId(cardId)
                for (handler in inputHandlers) {
                    if (handler.getId() == target) {
                        handler.resetValue()
                        break
                    }
                }
            }
        }
    }
}