package com.example.ac_sdk.objectmodel

class AdaptiveCardParseException(
    val statusCode: ErrorStatusCode,
    message: String
) : Exception(message) {

    fun getStatusCode(): ErrorStatusCode {
        return statusCode
    }

    fun getReason(): String {
        return message ?: ""
    }
}