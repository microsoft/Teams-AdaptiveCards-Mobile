package com.example.ac_sdk

import android.view.View
import androidx.annotation.NonNull
import androidx.annotation.Nullable
import java.util.*

class RenderedAdaptiveCard(
    val adaptiveCard: AdaptiveCard
) {
    var view: View? = null
        private set
    private val warnings: MutableList<AdaptiveWarning> = Vector()
    private val handlers: MutableList<IInputHandler> = Vector()
    private val submitActionCard: MutableMap<Long, Long> = HashMap()
    private val inputsInCard: MutableMap<Long, MutableMap<String, IInputHandler>> = HashMap()
    private val parentCardForCard: MutableMap<Long, Long> = HashMap()
    private var prevalidatedInputs: MutableMap<String, String> = HashMap()
    private var lastValidationResult = false

    fun addWarning(warning: AdaptiveWarning) {
        warnings.add(warning)
    }

    fun getWarnings(): List<AdaptiveWarning> = warnings

    fun registerInputHandler(handler: IInputHandler, renderArgs: RenderArgs) {
        registerInputHandler(handler, renderArgs.containerCardId)
    }

    fun registerInputHandler(handler: IInputHandler, cardId: Long) {
        inputsInCard.computeIfAbsent(cardId) { HashMap() }[handler.id] = handler
        handlers.add(handler)
    }

    fun getInputs(): Map<String, String> = prevalidatedInputs

    fun setParentToCard(cardId: Long, parentCardId: Long) {
        parentCardForCard[cardId] = parentCardId
    }

    fun setCardForSubmitAction(actionId: Long, parentCardId: Long) {
        submitActionCard[actionId] = parentCardId
    }

    @NonNull
    fun getInputsToValidate(clickedActionId: Long): List<IInputHandler> {
        val inputHandlers = Vector<IInputHandler>()
        var cardId: Long? = submitActionCard[clickedActionId]

        while (cardId != null && cardId != View.NO_ID) {
            inputsInCard[cardId]?.values?.let { inputHandlers.addAll(it) }
            cardId = parentCardForCard[cardId]
        }

        return inputHandlers
    }

    @Nullable
    fun getInputsHandlerFromCardId(cardId: Long): Map<String, IInputHandler>? {
        return inputsInCard[cardId]
    }

    fun areInputsValid(actionId: Long): Boolean {
        var allInputsAreValid = true
        var hasSetFocusToElement = false
        val validatedInputs = HashMap<String, String>()

        val inputsToValidate = getInputsToValidate(actionId)

        for (i in inputsToValidate) {
            allInputsAreValid = allInputsAreValid && i.isValid

            if (allInputsAreValid) {
                validatedInputs[i.id] = i.input
            }

            if (!allInputsAreValid && !hasSetFocusToElement) {
                (i as? BaseInputHandler)?.setFocusToView()
                hasSetFocusToElement = true
            }
        }

        if (allInputsAreValid) {
            prevalidatedInputs = validatedInputs
        }

        lastValidationResult = allInputsAreValid
        return lastValidationResult
    }

    fun areInputsValid(): Boolean = lastValidationResult

    fun setView(view: View) {
        this.view = view
    }

    fun registerSubmittableAction(renderedAction: View, renderArgs: RenderArgs) {
        val actionId = Util.getViewId(renderedAction)
        setCardForSubmitAction(actionId, renderArgs.containerCardId)
    }

    fun isActionSubmittable(action: View): Boolean {
        val actionId = action.id
        return submitActionCard.containsKey(actionId)
    }

    fun clearValidatedInputs() {
        prevalidatedInputs.clear()
        lastValidationResult = false
    }
}