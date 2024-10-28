// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.inputhandler;

import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.adaptivecards.objectmodel.BaseInputElement;
import io.adaptivecards.renderer.RenderedAdaptiveCard;
import io.adaptivecards.renderer.layout.StretchableInputLayout;

import java.util.ArrayList;
import java.util.List;

public abstract class BaseInputHandler implements IInputHandler
{
    public BaseInputHandler(BaseInputElement baseInputElement) {
        m_baseInputElement = baseInputElement;
        m_inputWatchers = new ArrayList<>();
    }

    public BaseInputHandler(@NonNull BaseInputElement baseInputElement, @Nullable RenderedAdaptiveCard renderedAdaptiveCard, long cardId) {
        this(baseInputElement);
        m_renderedAdaptiveCard = renderedAdaptiveCard;
        m_cardId = cardId;
    }

    public void setView(View view)
    {
        m_view = view;
    }

    public BaseInputElement getBaseInputElement()
    {
        return m_baseInputElement;
    }

    public String getId()
    {
        return m_baseInputElement.GetId();
    }

    public void setInputLayout(StretchableInputLayout inputLayout)
    {
        m_inputLayout = inputLayout;
    }

    @Override
    public boolean isValid()
    {
        return isValid(true);
    }

    @Override
    public boolean isValid(boolean showError) {
        boolean isValid = true;
        String inputValue = getInput();

        // This method validates that any field
        if (m_baseInputElement.GetIsRequired())
        {
            isValid = !(inputValue.isEmpty());
        }

        isValid = isValid && isValidOnSpecifics(inputValue);
        if (showError) {
            showValidationErrors(isValid);
        }

        return isValid;
    }

    @Override
    public boolean isRequiredInput() {
        return m_baseInputElement.GetIsRequired();
    }

    public boolean isValidOnSpecifics(String inputValue)
    {
        // By default return true as some inputs don't have any specific inputs (regex, min/max)
        return true;
    }

    public void showValidationErrors(boolean isValid)
    {
        // This must only be performed if there is an errorMessage, inputs rendered
        // without labels or error messages will have no inputLayout
        if (m_inputLayout != null)
        {
            m_inputLayout.setValidationResult(isValid);
        }
    }

    @Override
    public void addInputWatcher(IInputWatcher observer) {
        m_inputWatchers.add(observer);
    }

    protected void addValueChangedActionInputWatcher() {
        if(m_baseInputElement.GetValueChangedAction() != null && m_renderedAdaptiveCard != null){
            addInputWatcher(new ValueChangedActionInputWatcher(m_baseInputElement.GetValueChangedAction(), m_renderedAdaptiveCard, m_cardId));
        }
    }

    @Override
    public void registerInputObserver() {
        // Default implementation does nothing
    }

    @Override
    public String getDefaultValue() {
        return "";
    }

    protected void notifyAllInputWatchers(){
        for (IInputWatcher watcher : m_inputWatchers)
        {
            watcher.onInputChange(getId(), getInput());
        }
    }

    protected BaseInputElement m_baseInputElement;
    protected View m_view = null;
    private StretchableInputLayout m_inputLayout = null;
    List<IInputWatcher> m_inputWatchers;
    @Nullable
    private RenderedAdaptiveCard m_renderedAdaptiveCard;
    private Long m_cardId;

}
