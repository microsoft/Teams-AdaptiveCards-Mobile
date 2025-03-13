// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.action

import io.adaptivecards.objectmodel.BaseActionElement

object ActionElementUtil {

    /**
     * Checks if the action is a split button action.
     * @return true if the action has menu actions, false otherwise.
     */
    @JvmStatic
    fun BaseActionElement.isSplitButtonAction() : Boolean {
        return this.GetMenuActions()?.isNotEmpty() ?: false
    }

    const val SPLIT_BUTTON_ICON_URL = "icon:ChevronDown,Filled"
}
