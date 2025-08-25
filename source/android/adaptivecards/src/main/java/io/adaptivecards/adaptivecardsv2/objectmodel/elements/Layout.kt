// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.adaptivecardsv2.objectmodel.elements

import io.adaptivecards.adaptivecardsv2.objectmodel.utils.LayoutContainerType
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.TargetWidthType
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

@Serializable
sealed class Layout(
    var layoutContainerType: LayoutContainerType = LayoutContainerType.NONE,
    var targetWidth: TargetWidthType = TargetWidthType.DEFAULT
) : BaseElement() {

    fun shouldSerialize(): Boolean = true


        override fun serialize(): String? {
            return try {
                Json.encodeToString(Layout.serializer(), this)
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