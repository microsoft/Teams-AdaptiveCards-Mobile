package com.example.ac_sdk.objectmodel

class AdaptiveCardParseException(
    val statusCode: ErrorStatusCode,
    message: String
) : Exception(message)