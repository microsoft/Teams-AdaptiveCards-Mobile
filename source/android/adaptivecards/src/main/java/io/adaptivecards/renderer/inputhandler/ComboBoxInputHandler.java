// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

package io.adaptivecards.renderer.inputhandler;

import android.view.View;
import android.view.accessibility.AccessibilityEvent;
import android.widget.AdapterView;
import android.widget.Spinner;

import io.adaptivecards.objectmodel.BaseInputElement;
import io.adaptivecards.objectmodel.ChoiceInput;
import io.adaptivecards.objectmodel.ChoiceInputVector;
import io.adaptivecards.objectmodel.ChoiceSetInput;
import io.adaptivecards.renderer.RenderedAdaptiveCard;
import io.adaptivecards.renderer.Util;
import io.adaptivecards.renderer.input.customcontrols.ValidatedSpinnerLayout;


public class ComboBoxInputHandler extends BaseInputHandler
{
    public ComboBoxInputHandler(BaseInputElement baseInputElement, RenderedAdaptiveCard renderedAdaptiveCard, long cardId)
    {
        super(baseInputElement, renderedAdaptiveCard, cardId);
    }

    protected Spinner getSpinner()
    {
        // For validation visual cues we draw the spinner inside a ValidatedSpinnerLayout so we query for this
        if (m_view instanceof ValidatedSpinnerLayout)
        {
            return (Spinner)(((ValidatedSpinnerLayout)m_view).getChildAt(0));
        }
        return (Spinner) m_view;
    }

    public String getInput()
    {
        // no need to validate
        ChoiceSetInput choiceSetInput = (ChoiceSetInput) m_baseInputElement;
        int index = getSpinner().getSelectedItemPosition();
        String selectedItem = "";
        if (index >= 0 && index < choiceSetInput.GetChoices().size())
        {
            selectedItem = choiceSetInput.GetChoices().get(index).GetValue();
        }
        return selectedItem;
    }

    public void setInput(String value)
    {
        ChoiceSetInput choiceSetInput = (ChoiceSetInput) m_baseInputElement;
        ChoiceInputVector choiceInputVector = choiceSetInput.GetChoices();
        // When the input has an empty default a new option is added as the last element
        int selectedPosition = choiceSetInput.GetValue().isEmpty() ? choiceInputVector.size() : 0;

        for (int i = 0; i < choiceInputVector.size(); i++)
        {
            ChoiceInput choiceInput = choiceInputVector.get(i);
            if (value.equals(choiceInput.GetValue()))
            {
                selectedPosition = i;
                break;
            }
        }

        getSpinner().setSelection(selectedPosition);
    }

    @Override
    public void registerInputObserver() {
        getSpinner().setOnItemSelectedListener(new AdapterView.OnItemSelectedListener()
        {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id)
            {
                notifyAllInputWatchers();
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent)
            {
                notifyAllInputWatchers();
            }
        });
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
        Util.forceFocus(m_view);
        m_view.sendAccessibilityEvent(AccessibilityEvent.TYPE_VIEW_ACCESSIBILITY_FOCUSED);
    }
}
