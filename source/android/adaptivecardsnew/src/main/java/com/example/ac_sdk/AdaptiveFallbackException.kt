// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package com.example.ac_sdk

import com.example.ac_sdk.objectmodel.elements.BaseCardElement


/**
 * Exception for signaling that an element could not be rendered and fallback should be performed
 */
class AdaptiveFallbackException : Exception {

    val element: BaseCardElement
    val featureRegistration: FeatureRegistration?

    constructor(element: BaseCardElement) : super("No renderer exists for element type: $element") {
        this.element = element
        this.featureRegistration = null
    }

    constructor(element: BaseCardElement, featureRegistration: FeatureRegistration) : super("Requirements are not met for element type: $element") {
        this.element = element
        this.featureRegistration = featureRegistration
    }
}