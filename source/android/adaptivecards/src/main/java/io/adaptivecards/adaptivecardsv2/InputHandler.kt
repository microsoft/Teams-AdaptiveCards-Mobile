// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.adaptivecardsv2


interface IInputHandler {
    /**
     * @return id of the Input View
     */
    val id: String

    /**
     * @return value/text of the given input view
     */
    var input: String

    /**
     * @return check if the input view is valid or not and shows error if it isn't
     */
    fun isValid(): Boolean

    /**
     * @return check if the input view is valid or not
     * and can skip showing the error if required
     */
    fun isValid(showError: Boolean): Boolean

    /**
     * @return true if the inputElement is a required value
     */
    fun isRequiredInput(): Boolean

    /**
     * request focus on the given input view
     */
    fun setFocusToView()

    /**
     * Add InputWatcher as an observer in the list of observers for input change event
     * @param observer
     */
    fun addInputWatcher(observer: IInputWatcher)

    /**
     * Add actual inputChangeObserver for the given input view
     * like setOnCheckedChangeListener or addTextChangedListener
     * For some views with view hierarchy like combo checkbox not all the child views are
     * available at InputHandler initialization or at setView
     * in that case explicit call to add observer is required after adding child views.
     */
    fun registerInputObserver()

    /**
     * default value for the input filed
     */
    val defaultValue: String
}

interface IInputWatcher {
    fun onInputChange(id: String?, value: String?)
}