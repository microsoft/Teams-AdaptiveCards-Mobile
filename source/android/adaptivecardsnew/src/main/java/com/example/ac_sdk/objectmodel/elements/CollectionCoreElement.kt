// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package com.example.ac_sdk.objectmodel.elements

import kotlinx.serialization.Serializable

@Serializable
sealed class CollectionCoreElement : BaseCardElement() {
    var elements: List<BaseCardElement>? = null
}