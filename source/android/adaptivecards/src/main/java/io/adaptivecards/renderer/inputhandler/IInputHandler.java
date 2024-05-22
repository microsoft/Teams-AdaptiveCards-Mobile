// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.inputhandler;


public interface IInputHandler
{
    /**
     * @return id of the Input View
     */
    String getId();

    /**
     * @return value/text of the given input view
     */
    String getInput();

    /**
     * set value/text in the given input view
     * @param input
     */
    void setInput(String input);

    /**
     * @return check if the input view is valid or not and shows error if it isn't
     */
    boolean isValid();

    /**
     * @return check if the input view is valid or not
     * and can skip showing the error if required
     */
    boolean isValid(boolean showError);

    /**
     * request focus on the given input view
     */
    void setFocusToView();

    /**
     * Add InputWatcher as an observer in the list of observers for input change event
     * @param observer
     */
    void addInputWatcher(IInputWatcher observer);

    /**
     * Add actual inputChangeObserver for the given input view
     * like setOnCheckedChangeListener or addTextChangedListener
     * For some views with view hierarchy like combo checkbox not all the child views are
     * available at InputHandler initialization or at setView
     * in that case explicit call to add observer is required after adding child views.
     */
    void registerInputObserver();

    void setDefaultValue();
}
