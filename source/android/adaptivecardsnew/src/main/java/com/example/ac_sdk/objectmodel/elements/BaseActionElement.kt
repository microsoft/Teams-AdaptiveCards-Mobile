package com.example.ac_sdk.objectmodel.elements

import com.example.ac_sdk.objectmodel.utils.ActionRole
import com.example.ac_sdk.objectmodel.utils.ActionType
import com.example.ac_sdk.objectmodel.utils.Mode
import kotlinx.serialization.Polymorphic
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
sealed class BaseActionElement : BaseElement() {

    @SerialName("title")
    val title: String? = null

    @SerialName("iconUrl")
    val iconUrl: String? = null

    @SerialName("style")
    val style: String? = null

    @SerialName("tooltip")
    val tooltip: String? = null

    @SerialName("isEnabled")
    val isEnabled: Boolean? = null

//    @SerialName("type")
//    var type: ActionType? = null

    @SerialName("mode")
    val mode: Mode? = null

    @SerialName("role")
    val role: ActionRole? = null
}
