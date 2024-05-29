// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.inputhandler;

import android.view.accessibility.AccessibilityEvent;
import android.widget.CheckBox;

import io.adaptivecards.objectmodel.BaseInputElement;
import io.adaptivecards.objectmodel.ToggleInput;
import io.adaptivecards.renderer.RenderedAdaptiveCard;
import io.adaptivecards.renderer.Util;

public class ToggleInputHandler extends BaseInputHandler
{
    public ToggleInputHandler(BaseInputElement baseInputElement, RenderedAdaptiveCard renderedAdaptiveCard, long cardId)
    {
        super(baseInputElement, renderedAdaptiveCard, cardId);
    }

    protected CheckBox getCheckBox()
    {
        return (CheckBox) m_view;
    }

    @Override
    public String getInput()
    {
        // no need to validate
        ToggleInput toggleInput = (ToggleInput) m_baseInputElement;
        CheckBox checkBox = getCheckBox();
        return checkBox.isChecked() ? toggleInput.GetValueOn() : toggleInput.GetValueOff();
    }

    public void setInput(String value)
    {
        ToggleInput toggleInput = (ToggleInput) m_baseInputElement;
        CheckBox checkBox = getCheckBox();
        checkBox.setChecked(value.equals(toggleInput.GetValueOn()));
    }

    @Override
    public boolean isValid()
    {
        return isValid(true);
    }

    @Override
    public boolean isValid(boolean showError) {
        boolean isValid = true;

        // Due to toggle not working as all other inputs where isRequired can be satisfied
        // with checking on empty values, we check on the state of the checkBox
        if (m_baseInputElement.GetIsRequired())
        {
            isValid = getCheckBox().isChecked();
        }
        if (showError) {
            showValidationErrors(isValid);
        }

        return isValid;
    }

    @Override
    public void registerInputObserver() {
        getCheckBox().setOnCheckedChangeListener((buttonView, isChecked) -> notifyAllInputWatchers());
        addValueChangedActionInputWatcher();
    }

    @Override
    public void resetValue() {
        ToggleInput toggleInput = Util.castTo(m_baseInputElement, ToggleInput.class);
        setInput(toggleInput.GetValue());
    }

    @Override
    public void setFocusToView()
    {
        Util.forceFocus(m_view);
        m_view.sendAccessibilityEvent(AccessibilityEvent.TYPE_VIEW_ACCESSIBILITY_FOCUSED);
    }
}
