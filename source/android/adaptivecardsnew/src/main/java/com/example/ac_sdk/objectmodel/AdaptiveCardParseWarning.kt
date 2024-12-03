package com.example.ac_sdk.objectmodel

data class AdaptiveCardParseWarning(
    val statusCode: WarningStatusCode,
    val message: String
) {
    fun getStatusCode(): WarningStatusCode = statusCode
    fun getReason(): String = message
}