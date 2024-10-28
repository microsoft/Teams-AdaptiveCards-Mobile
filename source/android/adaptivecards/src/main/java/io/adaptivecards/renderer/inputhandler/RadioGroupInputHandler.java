// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.inputhandler;

import android.view.accessibility.AccessibilityEvent;
import android.widget.RadioButton;
import android.widget.RadioGroup;

import io.adaptivecards.objectmodel.BaseInputElement;
import io.adaptivecards.objectmodel.ChoiceInput;
import io.adaptivecards.objectmodel.ChoiceInputVector;
import io.adaptivecards.objectmodel.ChoiceSetInput;
import io.adaptivecards.renderer.RenderedAdaptiveCard;
import io.adaptivecards.renderer.Util;

public class RadioGroupInputHandler extends BaseInputHandler
{
    public RadioGroupInputHandler(BaseInputElement baseInputElement, RenderedAdaptiveCard renderedAdaptiveCard, long cardId)
    {
        super(baseInputElement, renderedAdaptiveCard, cardId);
    }

    protected RadioGroup getRadioGroup()
    {
        return (RadioGroup) m_view;
    }

    public String getInput()
    {
        // no need to validate
        ChoiceSetInput choiceSetInput = (ChoiceSetInput) m_baseInputElement;
        int index = getRadioGroup().getCheckedRadioButtonId();

        // if no item was selected, index == -1, return empty string
        if (index >= 0)
        {
            return choiceSetInput.GetChoices().get(index).GetValue();
        }
        else
        {
            return "";
        }
    }

    public void setInput(String choice)
    {
        ChoiceSetInput choiceSetInput = (ChoiceSetInput) m_baseInputElement;
        RadioGroup radioGroup = getRadioGroup();
        ChoiceInputVector choiceInputVector = choiceSetInput.GetChoices();

        if (!choice.isEmpty())
        {
            for (int i = 0 ; i < choiceInputVector.size(); i++)
            {
                ChoiceInput choiceInput = choiceInputVector.get(i);
                if (choice.equals(choiceInput.GetValue()))
                {
                    /*
                        We can do this because the id is equal to the index . Check {@link ChoiceSetInputRender}
                     */
                    radioGroup.check(i);
                    break;
                }
            }
        }
        else
        {
            // Indicates no item was selected
            radioGroup.check(-1);
        }
    }

    @Override
    public void registerInputObserver() {
        getRadioGroup().setOnCheckedChangeListener((group, checkedId) -> notifyAllInputWatchers());
        addValueChangedActionInputWatcher();
    }

    @Override
    public String getDefaultValue() {
        if (Util.isOfType(m_baseInputElement, ChoiceSetInput.class)) {
            return Util.castTo(m_baseInputElement, ChoiceSetInput.class).GetValue();
        }
        return super.getDefaultValue();
    }

    @Override
    public void setFocusToView()
    {
        RadioGroup radioGroup = (RadioGroup)m_view;

        if (radioGroup.getChildCount() > 0)
        {
            RadioButton radioButton = (RadioButton)(radioGroup.getChildAt(0));

            Util.forceFocus(radioButton);
            radioButton.sendAccessibilityEvent(AccessibilityEvent.TYPE_VIEW_ACCESSIBILITY_FOCUSED);
        }
    }

}
