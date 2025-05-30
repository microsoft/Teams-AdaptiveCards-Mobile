// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package com.example.ac_sdk

data class AdaptiveWarning(
    val code: Int,
    val message: String
) {
    companion object {
        const val UNKNOWN_ELEMENT_TYPE = 1
        const val UNABLE_TO_LOAD_IMAGE = 2
        const val INTERACTIVITY_DISALLOWED = 3
        const val MAX_ACTIONS_EXCEEDED = 4
        const val TOGGLE_MISSING_VALUE = 5
        const val SELECT_SHOW_CARD_ACTION = 6
        const val INVALID_COLUMN_WIDTH_VALUE = 7
        const val EMPTY_LABEL_IN_REQUIRED_INPUT = 8
        const val MISSING_RENDER_ARGS = 8
    }
}