package com.example.ac_sdk.objectmodel


import org.json.JSONObject

data class RemoteResourceInformation(
    val url: String,
    val mimeType: String
)

class BaseActionElement(
    val type: ActionType,
    var title: String = "",
    var iconUrl: String = "",
    var style: String = DEFAULT_STYLE,
    var tooltip: String = "",
    var isEnabled: Boolean = true,
    var mode: Mode = Mode.Primary,
    var role: ActionRole = if (type == ActionType.OpenUrl) ActionRole.Link else ActionRole.Button
) {

    companion object {
        const val DEFAULT_STYLE = "default"

        fun deserializeBasePropertiesFromString(jsonString: String): BaseActionElement {
            val json = JSONObject(jsonString)
            return deserializeBaseProperties(json)
        }

        fun deserializeBaseProperties(json: JSONObject): BaseActionElement {
            val type = ActionType.valueOf(json.getString("type"))
            val element = BaseActionElement(type)
            element.title = json.optString("title", "")
            element.iconUrl = json.optString("iconUrl", "")
            element.style = json.optString("style", DEFAULT_STYLE)
            element.tooltip = json.optString("tooltip", "")
            element.isEnabled = json.optBoolean("isEnabled", true)
            element.mode = Mode.valueOf(json.optString("mode", Mode.Primary.name))
            element.role = ActionRole.valueOf(json.optString("role", ActionRole.Button.name))
            return element
        }
    }

    fun getSVGPath(): String {
        val config = iconUrl.split("[:,]+".toRegex())
        val iconName = if (config.size >= 2) config[1] else ""
        val iconStyle = if (config.size > 2) config.last() else "Regular"
        return "$iconName/$iconName.json"
    }

    fun serializeToJsonValue(): JSONObject {
        val json = JSONObject()
        if (iconUrl.isNotEmpty()) json.put("iconUrl", iconUrl)
        if (title.isNotEmpty()) json.put("title", title)
        if (style != DEFAULT_STYLE) json.put("style", style)
        if (mode != Mode.Primary) json.put("mode", mode.name)
        if (tooltip.isNotEmpty()) json.put("tooltip", tooltip)
        if (!isEnabled) json.put("isEnabled", isEnabled)
        if (role != ActionRole.Button) json.put("role", role.name)
        return json
    }

    fun getResourceInformation(): List<RemoteResourceInformation> {
        return if (iconUrl.isNotEmpty()) {
            listOf(RemoteResourceInformation(iconUrl, "image"))
        } else {
            emptyList()
        }
    }
}