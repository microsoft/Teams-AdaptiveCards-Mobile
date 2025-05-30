// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package com.example.ac_sdk.objectmodel.parser

import com.example.ac_sdk.objectmodel.AdaptiveCard
import com.example.ac_sdk.objectmodel.utils.ErrorStatusCode
import com.example.ac_sdk.objectmodel.utils.WarningStatusCode

data class ParseResult(val adaptiveCard: AdaptiveCard, val warnings: List<ParseWarning>?)

data class ParseWarning(
    val statusCode: WarningStatusCode,
    val message: String
)

class ParseException(
    val statusCode: ErrorStatusCode,
    message: String
) : Exception(message)