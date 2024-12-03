package com.example.ac_sdk


interface ICardActionHandler {
    fun onAction(actionElement: BaseActionElement, renderedAdaptiveCard: RenderedAdaptiveCard)

    fun onMediaPlay(mediaElement: BaseCardElement, renderedAdaptiveCard: RenderedAdaptiveCard)
    fun onMediaStop(mediaElement: BaseCardElement, renderedAdaptiveCard: RenderedAdaptiveCard)
}