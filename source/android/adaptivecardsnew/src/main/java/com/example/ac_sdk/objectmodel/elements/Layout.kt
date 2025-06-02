// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package com.example.ac_sdk.objectmodel.elements

import com.example.ac_sdk.objectmodel.utils.LayoutContainerType
import com.example.ac_sdk.objectmodel.utils.TargetWidthType
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

@Serializable
sealed class Layout(
    var layoutContainerType: LayoutContainerType = LayoutContainerType.NONE,
    var targetWidth: TargetWidthType = TargetWidthType.DEFAULT
) : BaseElement() {

    fun shouldSerialize(): Boolean = true

    companion object {

        fun serialize(): String? {
            return try {
                Json.encodeToString(this)
            } catch (e: Exception) {
                null
            }
        }

        fun deserializeFromString(jsonString: String): Layout? {
            return try {
                Json.decodeFromString(jsonString)
            } catch (e: Exception) {
                null
            }
        }

        fun deserializeBaseProperties(jsonString: String): Layout? {
            return try {
                Json.decodeFromString(serializer(), jsonString)
            } catch (e: Exception) {
                null
            }
        }
    }
}