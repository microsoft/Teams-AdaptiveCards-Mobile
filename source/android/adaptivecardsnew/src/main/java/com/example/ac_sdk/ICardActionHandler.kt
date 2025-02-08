package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.elements.BaseActionElement
import com.example.ac_sdk.objectmodel.elements.BaseCardElement


interface ICardActionHandler {
    fun onAction(actionElement: BaseActionElement, renderedAdaptiveCard: RenderedAdaptiveCard)

    fun onMediaPlay(mediaElement: BaseCardElement, renderedAdaptiveCard: RenderedAdaptiveCard)
    fun onMediaStop(mediaElement: BaseCardElement, renderedAdaptiveCard: RenderedAdaptiveCard)
}