package com.example.ac_sdk


/**
 * Exception for signaling that an element could not be rendered and fallback should be performed
 */
class AdaptiveFallbackException : Exception {

    val element: BaseElement
    val featureRegistration: FeatureRegistration?

    constructor(element: BaseElement) : super("No renderer exists for element type: ${element.getElementTypeString()}") {
        this.element = element
        this.featureRegistration = null
    }

    constructor(element: BaseElement, featureRegistration: FeatureRegistration) : super("Requirements are not met for element type: ${element.getElementTypeString()}") {
        this.element = element
        this.featureRegistration = featureRegistration
    }
}