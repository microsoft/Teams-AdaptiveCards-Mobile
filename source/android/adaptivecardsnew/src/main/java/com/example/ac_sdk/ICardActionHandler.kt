package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.ActionElement
import com.example.ac_sdk.objectmodel.BaseCardElement


interface ICardActionHandler {
    fun onAction(actionElement: ActionElement, renderedAdaptiveCard: RenderedAdaptiveCard)

    fun onMediaPlay(mediaElement: BaseCardElement, renderedAdaptiveCard: RenderedAdaptiveCard)
    fun onMediaStop(mediaElement: BaseCardElement, renderedAdaptiveCard: RenderedAdaptiveCard)
}