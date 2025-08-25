// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.adaptivecardsv2.objectmodel.parser

import io.adaptivecards.adaptivecardsv2.objectmodel.AdaptiveCard
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.ErrorStatusCode
import io.adaptivecards.adaptivecardsv2.objectmodel.utils.WarningStatusCode

data class ParseResult(val adaptiveCard: AdaptiveCard, val warnings: List<ParseWarning>?, val serlizedJson: String? = null)

data class ParseWarning(
    val statusCode: WarningStatusCode,
    val message: String
)

class ParseException(
    val statusCode: ErrorStatusCode,
    message: String
) : Exception(message)