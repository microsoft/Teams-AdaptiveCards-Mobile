package io.adaptivecards.parser.elements

import io.adaptivecards.objectmodel.ActionRole
import io.adaptivecards.objectmodel.ActionType
import io.adaptivecards.objectmodel.Mode
import kotlinx.serialization.Polymorphic
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable(with = BaseActionElementSerializer::class)
@Polymorphic
sealed class BaseActionElement : BaseElement() {

    @SerialName("title")
    var title: String? = null

    @SerialName("iconUrl")
    var iconUrl: String? = null

    @SerialName("style")
    var style: String? = null

    @SerialName("tooltip")
    var tooltip: String? = null

    @SerialName("isEnabled")
    var isEnabled: Boolean? = null

    @SerialName("type")
    var type: ActionType? = null

    @SerialName("mode")
    var mode: Mode? = null

    @SerialName("role")
    var role: ActionRole? = null
}
