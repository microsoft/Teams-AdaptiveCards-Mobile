package io.adaptivecards.parser.parsing

import kotlinx.serialization.Serializable


@Serializable
enum class AdaptiveCardParseWarningCode {
    UNKNOWN,
    ASSET_LOAD_FAILED,
    UNSUPPORTED_SCHEMA_VERSION
}

@Serializable
data class AdaptiveCardParseWarning(
    private val code: AdaptiveCardParseWarningCode,
    private val message: String
) {
    fun getWarningCode(): AdaptiveCardParseWarningCode = code
    fun getReason(): String = message
}