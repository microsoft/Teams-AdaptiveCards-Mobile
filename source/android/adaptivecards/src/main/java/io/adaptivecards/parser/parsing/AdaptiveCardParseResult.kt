package io.adaptivecards.parser.parsing

import io.adaptivecards.parser.AdaptiveCard

data class ParseResult(
    var adaptiveCard: AdaptiveCard,
    var warnings: List<AdaptiveCardParseWarning>
)
