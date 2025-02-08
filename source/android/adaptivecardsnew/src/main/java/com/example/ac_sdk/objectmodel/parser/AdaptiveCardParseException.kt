package com.example.ac_sdk.objectmodel.parser

import com.example.ac_sdk.objectmodel.utils.ErrorStatusCode

class AdaptiveCardParseException(
    val statusCode: ErrorStatusCode,
    message: String
) : Exception(message)