package com.example.ac_sdk.objectmodel.parser

import com.example.ac_sdk.objectmodel.utils.WarningStatusCode

data class AdaptiveCardParseWarning(
    val statusCode: WarningStatusCode,
    val message: String
)