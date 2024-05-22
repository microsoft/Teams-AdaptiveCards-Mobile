// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
//
package io.adaptivecards.renderer.inputhandler

import io.adaptivecards.renderer.registration.CardRendererRegistration

/**
 * Utility class for input handling
 */
object InputUtils {

    /**
     * Register the input observer and add the input watcher in the input handler
     */
    @JvmStatic
    fun IInputHandler.updateInputHandlerInputWatcher() {
        this.registerInputObserver()
        this.addInputWatcher { id, value ->
            CardRendererRegistration.getInstance().notifyInputChange(id, value)
        }
        this.addValueChangedActionInputWatcher()
    }

    /**
     * Check if any input is valid
     * @param inputHandlers List of input handlers
     * @return True if any input is valid, false otherwise
     */
    @JvmStatic
    fun isAnyInputValid(inputHandlers: List<IInputHandler>): Boolean {
        if (inputHandlers.isEmpty()) return true
        for (i in inputHandlers) {
            if (i.isValid(false)) {
                return true
            }
        }
        return false
    }
}