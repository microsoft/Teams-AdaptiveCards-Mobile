// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package com.example.ac_sdk.objectmodel.markdown

import com.microsoft.adaptivecards.markdown.DelimiterType

/**
 * Base class for all Markdown block parsers
 */
open class MarkDownBlockParser {
    // Parsed result
    val markDownBlockParsedResult = MarkDownParsedResult()

    /**
     * Match Markdown syntax in the input stream
     */
    open fun match(stream: Stream){

    }

    /**
     * Parse a block of Markdown
     * This method examines the next character in the stream and delegates to the appropriate parser
     */
    fun parseBlock(stream: Stream) {
        val nextChar = stream.get().code

        // Push back the character so the specific parser can read it
        if (nextChar != -1) {
            stream.putback(nextChar.toChar())
        }

        when (nextChar.toChar()) {
            // Parses link
            '[' -> {
                val linkParser = LinkParser()
                // Do syntax check of link
                linkParser.match(stream)
                // Append link result to the rest
                markDownBlockParsedResult.appendParseResult(linkParser.linkParsedResult)
            }

            // Handles special cases where these tokens are not encountered as part of link
            ']', ')' -> {
                val streamChar = nextChar.toChar()
                // Consume the character
                stream.get()
                // Add these char as token to code gen list
                markDownBlockParsedResult.addNewTokenToParsedResult(streamChar)
            }

            // Handles newlines
            '\n', '\r' -> {
                val streamChar = nextChar.toChar()
                // Consume the character
                stream.get()
                // Add new line char as token to code gen list
                markDownBlockParsedResult.addNewLineTokenToParsedResult(streamChar)
            }

            // Handles list block
            '-', '+', '*' -> {
                val listParser = ListParser()
                // Do syntax check of list
                listParser.match(stream)
                // Append list result to the rest
                markDownBlockParsedResult.appendParseResult(listParser.getParsedResult())
            }

            // Handles ordered lists
            '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' -> {
                val orderedListParser = OrderedListParser()
                // Do syntax check of list
                orderedListParser.match(stream)
                // Append list result to the rest
                markDownBlockParsedResult.appendParseResult(orderedListParser.getParsedResult())
            }

            // Everything else is treated as normal text + emphasis
            else -> {
                parseTextAndEmphasis(stream)
            }
        }
    }

    /**
     * Parse text and emphasis elements
     */
    protected fun parseTextAndEmphasis(stream: Stream) {
        val emphasisParser = EmphasisParser()
        emphasisParser.match(stream)
        markDownBlockParsedResult.appendParseResult(emphasisParser.getParsedResult())
    }

    companion object {
        /**
         * Check if character is a space
         */
        fun isSpace(ch: Int): Boolean {
            return ch > 0 && Character.isWhitespace(ch)
        }

        /**
         * Check if character is punctuation
         */
        fun isPunct(ch: Int): Boolean {
            return ch > 0 && !Character.isLetterOrDigit(ch) && !Character.isWhitespace(ch)
        }

        /**
         * Check if character is alphanumeric
         */
        fun isAlnum(ch: Int): Boolean {
            // Handle UTF-8 encoding as in the C++ version
            return ch > 0x7F || Character.isLetterOrDigit(ch)
        }

        /**
         * Check if character is a control character
         */
        fun isCntrl(ch: Int): Boolean {
            return ch > 0 && Character.isISOControl(ch)
        }

        /**
         * Check if character is a digit
         */
        fun isDigit(ch: Int): Boolean {
            return ch > 0 && Character.isDigit(ch)
        }
    }
}

/**
 * Parser for emphasis elements (bold/italic)
 */
class EmphasisParser : MarkDownBlockParser() {
    enum class EmphasisState {
        Text,     // Text is being handled
        Emphasis, // Emphasis is being handled
        Captured  // Emphasis parsing is complete
    }

    private var checkLookAhead = false
    private var checkIntraWord = false
    private var lookBehind = DelimiterType.Init
    private var delimiterCnts = 0
    private var currentDelimiterType = DelimiterType.Init
    private var currentState = EmphasisState.Text
    private var currentTokenBuilder = StringBuilder()

    /**
     * Match emphasis syntax in the input stream
     */
    override fun match(stream: Stream) {

        // Process the stream character by character
        while (currentState != EmphasisState.Captured) {
            // State machine approach to handle different parsing states
            currentState = when (currentState) {
                EmphasisState.Text -> matchText(stream, currentTokenBuilder)
                EmphasisState.Emphasis -> matchEmphasis(stream, currentTokenBuilder)
                EmphasisState.Captured -> break
            }

        }
    }

    private fun isEmphasisToken(currentChar: Char): Boolean {
        return (currentChar == '[' || currentChar == ']' || currentChar == ')' || currentChar == '\n' || currentChar == '\r');
    }

    /**
     * Flush remaining characters and terminate emphasis parsing
     */
    private fun flush(ch: Int, currentToken: StringBuilder) {
        if (currentState == EmphasisState.Emphasis) {
            captureEmphasisToken(ch, currentToken)
            delimiterCnts = 0
        } else {
            captureCurrentCollectedStringAsRegularToken(currentToken)
        }
        currentToken.setLength(0)
    }

    /**
     * Check if character is a Markdown delimiter (* or _)
     */
    private fun isMarkDownDelimiter(ch: Int): Boolean {
        return ((ch == '*'.code || ch == '_'.code) && (lookBehind != DelimiterType.Escape))
    }

    /**
     * Capture current string as a regular token
     */
    private fun captureCurrentCollectedStringAsRegularToken(currentToken: StringBuilder) {
        if (currentToken.isEmpty()) return
        val codeGen = MarkDownStringHtmlGenerator(currentToken.toString())
        markDownBlockParsedResult.appendToTokens(codeGen)
        currentToken.setLength(0)
    }

    /**
     * Capture current string as a regular token
     */
    private fun captureCurrentCollectedStringAsRegularToken() {
        captureCurrentCollectedStringAsRegularToken(currentTokenBuilder)
    }

    /**
     * Update current emphasis run state
     */
    private fun updateCurrentEmphasisRunState(emphasisType: DelimiterType) {
        if (lookBehind != DelimiterType.WhiteSpace) {
            checkLookAhead = (lookBehind == DelimiterType.Punctuation)
            checkIntraWord = (lookBehind == DelimiterType.Alphanumeric && emphasisType == DelimiterType.Underscore)
        }
        delimiterCnts++
        currentDelimiterType = emphasisType
    }


    /**
     * Check if current delimiter is part of a run
     */
    private fun isEmphasisDelimiterRun(emphasisType: DelimiterType): Boolean {
        return currentDelimiterType == emphasisType
    }

    /**
     * Reset current emphasis state
     */
    private fun resetCurrentEmphasisState() {
        delimiterCnts = 0
    }

    /**
     * Check if character can be a left emphasis delimiter
     */
    private fun isLeftEmphasisDelimiter(ch: Int): Boolean {
        // Implementation based on Markdown rules for left emphasis
        if (delimiterCnts > 0 && ch != -1) { // assuming -1 represents EOF
            return (!isSpace(ch)) &&
                    !(lookBehind == DelimiterType.Alphanumeric && isPunct(ch)) &&
                    !(lookBehind == DelimiterType.Alphanumeric && currentDelimiterType == DelimiterType.Underscore)
        }
        return false
    }

    /**
     * Check if character can be a right emphasis delimiter
     */
    private fun isRightEmphasisDelimiter(ch: Int): Boolean {
        if ((ch == -1 || isSpace(ch)) &&
            lookBehind != DelimiterType.WhiteSpace &&
            (checkLookAhead || checkIntraWord || currentDelimiterType == DelimiterType.Asterisk)
        ) {
            return true
        }
        if (isAlnum(ch) &&
            lookBehind != DelimiterType.WhiteSpace &&
            lookBehind != DelimiterType.Init
        ) {
            if (!checkLookAhead && !checkIntraWord) {
                return true
            }
            if (checkLookAhead || checkIntraWord) {
                return false
            }
        }
        if (isPunct(ch) && lookBehind != DelimiterType.WhiteSpace) {
            return true
        }
        return false
    }

    /**
     * Try to capture left emphasis token
     */
    /**
     * Attempts to capture a left emphasis token.
     */
    private fun tryCapturingLeftEmphasisToken(ch: Int, currentToken: StringBuilder): Boolean {
        if (isLeftEmphasisDelimiter(ch)) {
            val codeGen = MarkDownLeftEmphasisHtmlGenerator(currentToken.toString(), delimiterCnts, currentDelimiterType)
            markDownBlockParsedResult.appendToLookUpTable(codeGen)
            markDownBlockParsedResult.appendToTokens(codeGen)
            currentToken.setLength(0)
            return true
        }
        return false
    }

    /**
     * Try to capture right emphasis token
     */
    private fun tryCapturingRightEmphasisToken(ch: Int, currentToken: StringBuilder): Boolean {
        if (isRightEmphasisDelimiter(ch)) {
            val codeGen = if (isLeftEmphasisDelimiter(ch)) {
                MarkDownLeftAndRightEmphasisHtmlGenerator(currentToken.toString(), delimiterCnts, currentDelimiterType)
            } else {
                MarkDownRightEmphasisHtmlGenerator(currentToken.toString(), delimiterCnts, currentDelimiterType)
            }
            markDownBlockParsedResult.appendToLookUpTable(codeGen)
            markDownBlockParsedResult.appendToTokens(codeGen)
            currentToken.setLength(0)
            return true
        }
        return false
    }
    /**
     * Capture emphasis token
     */
    /**
     * Attempts to capture the current emphasis token. If neither a right nor left emphasis token is valid,
     * and the token is not empty, then it is captured as a regular string token.
     */
    private fun captureEmphasisToken(ch: Int, currentToken: StringBuilder) {
        if (!tryCapturingRightEmphasisToken(ch, currentToken) &&
            !tryCapturingLeftEmphasisToken(ch, currentToken) &&
            currentToken.isNotEmpty()
        ) {
            captureCurrentCollectedStringAsRegularToken(currentToken)
        }
    }

    /**
     * Update look behind character
     */
    private fun updateLookBehind(ch: Int) {
        when {
            isAlnum(ch) -> lookBehind = DelimiterType.Alphanumeric
            isSpace(ch) -> lookBehind = DelimiterType.WhiteSpace
            isPunct(ch) -> lookBehind = if (ch == '\\'.code) DelimiterType.Escape else DelimiterType.Punctuation
        }
    }

    /**
     * Get delimiter type for character
     */
    private fun getDelimiterTypeForChar(ch: Int): DelimiterType {
        return if (ch == '*'.code) DelimiterType.Asterisk else DelimiterType.Underscore
    }

    /**
     * Matches a text segment for emphasis parsing.
     * Reads the current character from the stream and, depending on whether it is an emphasis token
     * or a markdown delimiter, either flushes the current token or updates the emphasis run state.
     */
    private fun matchText(stream: Stream, token: StringBuilder): EmphasisState {
        val currentChar = stream.peek()  // currentChar is an Int (or -1 for EOF)
        val isEmphasisToken = isEmphasisToken(currentChar.toChar())

        // If end-of-stream or if an emphasis token is encountered and not escaped,
        // flush the current token and return Captured state.
        if (stream.peek() == -1 || (lookBehind != DelimiterType.Escape && isEmphasisToken)) {
            flush(currentChar, token)
            return EmphasisState.Captured
        }

        if (isMarkDownDelimiter(currentChar)) {
            // Encountered the first emphasis delimiter.
            captureCurrentCollectedStringAsRegularToken()
            val emphasisType = getDelimiterTypeForChar(currentChar)
            // If we are not at the beginning, update look-behind by unreading and reading one character.
            if (stream.tell() != 0) {
                stream.putback(currentChar.toChar())
                updateLookBehind(stream.get().code)
            }
            updateCurrentEmphasisRunState(emphasisType)
            val streamChar = stream.get()
            token.append(streamChar.toChar())
            return EmphasisState.Emphasis
        } else {
            // If an emphasis token is seen but the previous char was an escape, remove the escape.
            if (isEmphasisToken && lookBehind == DelimiterType.Escape) {
                if (token.isNotEmpty()) token.deleteCharAt(token.length - 1)
            } else if ((currentChar == '*'.toInt() || currentChar == '_'.toInt())
                && lookBehind == DelimiterType.Escape
            ) {
                if (token.isNotEmpty()) token.deleteCharAt(token.length - 1)
            }
            updateLookBehind(currentChar)
            val streamChar = stream.get()
            token.append(streamChar.toChar())
            return EmphasisState.Text
        }
    }

    /**
     * Match emphasis state
     */
    private fun matchEmphasis(stream: Stream, token: StringBuilder): EmphasisState {
        val currentChar = stream.peek()

        // If we encounter certain Markdown keywords or end-of-stream, flush the current token.
        if (currentChar == '['.code ||
            currentChar == ']'.code ||
            currentChar == ')'.code ||
            currentChar == '\n'.code ||
            currentChar == '\r'.code ||
            stream.peek() == -1
        ) {
            flush(currentChar, token)
            return EmphasisState.Captured
        }

        // If another delimiter is encountered, update the emphasis run state.
        if (isMarkDownDelimiter(currentChar)) {
            val emphasisType = getDelimiterTypeForChar(currentChar)
            if (isEmphasisDelimiterRun(emphasisType)) {
                updateCurrentEmphasisRunState(emphasisType)
            }
            val streamChar = stream.get()
            token.append(streamChar.toChar())
        } else {
            // Delimiter run ended: capture the current accumulated token as emphasis.
            captureEmphasisToken(currentChar, token)
            if (currentChar == '\\'.toInt()) {
                // Skip escape character.
                stream.get()
            }
            resetCurrentEmphasisState()
            updateLookBehind(stream.peek())
            val streamChar = stream.get()
            token.append(streamChar.toChar())
            return EmphasisState.Text
        }
        return EmphasisState.Emphasis
    }

    fun getParsedResult(): MarkDownParsedResult {
        return markDownBlockParsedResult
    }
}

/**
 * Parser for Markdown links
 */
class LinkParser : MarkDownBlockParser() {
    val linkParsedResult = MarkDownParsedResult()
    private var leftParenthesisCounts = 0
    private val linkTextParsedResult = MarkDownParsedResult()
    private var linkDestination = ""
    private var positionOfLinkDestinationEndToken = 0

    /**
     * Match link syntax in the input stream
     */
    override fun match(stream: Stream) {
        val capturedLink = matchAtLinkInit(stream) &&
                matchAtLinkTextRun(stream) &&
                matchAtLinkTextEnd(stream)
        if (capturedLink && matchAtLinkDestinationStart(stream) && matchAtLinkDestinationRun(stream)) {
            // If all stages passed, capture the link.
            captureLinkToken()
        }
    }

    /**
     * Capture link token
     */
    private fun captureLinkToken() {
        val html = StringBuilder()
        html.append("<a href=\"")
        // Process the link destination.
        html.append(linkParsedResult.generateHtmlString())
        html.append("\">")

        // The syntax check has consumed the markers '[', ']', '('.
        // Remove them from the link text parsed result.
        linkTextParsedResult.popFront()
        linkTextParsedResult.popBack()
        linkTextParsedResult.popBack()

        // Process any emphasis within the link text.
        linkTextParsedResult.translate()
        html.append(linkTextParsedResult.generateHtmlString())
        html.append("</a>")

        val htmlString = html.toString()

        // Create the Markdown HTML generator for the link.
        val codeGen = MarkDownStringHtmlGenerator(htmlString)

        linkParsedResult.clear()
        linkParsedResult.foundHtmlTags()
        linkParsedResult.appendToTokens(codeGen)
        linkParsedResult.setIsCaptured(true)
    }


    /**
     * Match initial [ character
     */
    private fun matchAtLinkInit(lookahead: Stream): Boolean {
        if (lookahead.peek().toChar() == '[') {
            val streamChar = lookahead.get() // consumes the '['
            linkTextParsedResult.addNewTokenToParsedResult(streamChar.toChar())
            return true
        }
        // This case should not occur if used intentionally.
        return false
    }

    /**
     * Match link text content
     */
    private fun matchAtLinkTextRun(lookahead: Stream): Boolean {
        // Parse content between [ and ]
        if (lookahead.peek().toChar() == ']') {
            val streamChar = lookahead.get()  // consumes the ']'
            linkTextParsedResult.addNewTokenToParsedResult(streamChar.toChar())
            return true
        } else {
            // Parse recursively until we hit a closing bracket.
            while (lookahead.peek() != Stream.EOF && lookahead.peek().toChar() != ']') {
                parseBlock(lookahead)
                linkTextParsedResult.appendParseResult(linkParsedResult)
                if (linkTextParsedResult.getIsCaptured()) {
                    break
                }
            }
            if (lookahead.peek().toChar() == ']') {
                val streamChar = lookahead.get()  // consume the ']'
                linkTextParsedResult.addNewTokenToParsedResult(streamChar.toChar())
                return true
            }
            linkParsedResult.appendParseResult(linkTextParsedResult)
            return false
        }
    }

    /**
     * Match closing ] character
     */
    private fun matchAtLinkTextEnd(lookahead: Stream): Boolean {
        // If the next character is EOF (or a negative value), abort.
        if (lookahead.peek() < 0) {
            linkParsedResult.appendParseResult(linkTextParsedResult)
            return false
        }

        // Record the current stream position.
        val initialPosition = lookahead.tell()
        var currentPosition = initialPosition
        positionOfLinkDestinationEndToken = 0

        // Scan the stream while balancing '(' and ')'.
        while (lookahead.peek() != Stream.EOF && leftParenthesisCounts > 0) {
            val token = lookahead.get()
            when (token) {
                '(' -> leftParenthesisCounts++
                ')' -> leftParenthesisCounts--
            }
            if (leftParenthesisCounts == 0) {
                // When balanced, record the position.
                positionOfLinkDestinationEndToken = currentPosition
            }
            currentPosition++
        }

        lookahead.clear()
        // Reset the stream back to the initial position.
        lookahead.seek(initialPosition)

        // If no valid destination end was detected or if a control key is next, fail.
        if (positionOfLinkDestinationEndToken == 0 || isCntrl(lookahead.peek())) {
            linkParsedResult.appendParseResult(linkTextParsedResult)
            return false
        }
        return true
    }

    /**
     * Match opening ( character
     */
    private fun matchAtLinkDestinationStart(stream: Stream): Boolean {
        val ch = stream.get()
        if (ch == '(') {
            leftParenthesisCounts = 1
            return true
        }
        return false
    }

    /**
     * Match link destination content
     */
    private fun matchAtLinkDestinationRun(lookahead: Stream): Boolean {
        // (This check might be redundant if already validated in matchAtLinkDestinationStart.)
        if (lookahead.peek() > 0 &&
            (isSpace(lookahead.peek()) || isCntrl(lookahead.peek()))
        ) {
            linkParsedResult.appendParseResult(linkTextParsedResult)
            return false
        }

        var currentPos = lookahead.tell()
        while (currentPos < positionOfLinkDestinationEndToken && lookahead.peek() != Stream.EOF) {
            // To prevent nested links, if we see a '[' remove it.
            if (lookahead.peek().toChar() == '[') {
                val c = lookahead.get()
                linkParsedResult.addNewTokenToParsedResult(c)
            } else {
                parseBlock(lookahead)
            }
            currentPos = lookahead.tell()
        }

        // Finally, if the next character is ')', consume it.
        if (lookahead.peek().toChar() == ')') {
            lookahead.get()
        }

        return true
    }
}

/**
 * Parser for Markdown lists
 */
open class ListParser : MarkDownBlockParser() {

    // Function corresponding to ListParser::Match
    override fun match(stream: Stream) {
        // Get the next character without consuming it.
        val ch = stream.peek()
        // Check for a list marker (hyphen, plus, or asterisk)
        if (isHyphen(ch) || isPlus(ch) || isAsterisk(ch)) {
            // Consume the marker
            stream.get()
            if (completeListParsing(stream)) {
                captureListToken()
            } else {
                // If the marker was an asterisk, put it back and handle emphasis parsing.
                if (isAsterisk(ch)) {
                    stream.putback(ch.toChar())
                    parseTextAndEmphasis(stream)
                } else {
                    // Otherwise, capture the character as a new token.
                    markDownBlockParsedResult.addNewTokenToParsedResult(ch.toChar().toString())
                }
            }
        }
    }

    /**
     * Match a new list item
     */
    protected fun matchNewListItem(stream: Stream): Boolean {
        val ch = stream.peek()
        if (isHyphen(ch) || isPlus(ch) || isAsterisk(ch)) {
            // Consume the marker.
            stream.get()
            // Check if the next character is a space.
            if (stream.peek().toChar() == ' ') {
                stream.putback(ch.toChar())
                return true
            }
            stream.putback(ch.toChar())
        }
        return false
    }

    /**
     * Match a new block
     */
    protected fun matchNewBlock(stream: Stream): Boolean {
        if (isNewLine(stream.peek())) {
            do {
                stream.get() // Consume the newline character.
            } while (isNewLine(stream.peek()))
            return true
        }
        return false
    }


    /**
     * Match a new ordered list item
     */
    protected fun matchNewOrderedListItem(stream: Stream, number: StringBuilder): Boolean {

        do {
            val ch = stream.get().code
            number.append(ch.toChar())
        } while (isDigit(stream.peek()))

        if (isDot(stream.peek())) {
            stream.putback(number.get(number.length-1))
            return true
        }

        return false
    }

    /**
     * Parse sub-blocks within a list item
     */
    protected fun parseSubBlocks(stream: Stream) {
        while (!stream.isEOF()) {

            if (isNewLine(stream.peek())) {
                // Consume the newline character
                val newLineChar = stream.get()
                // Check if it's the start of a new block item
                if (isDigit(stream.peek())) {
                    val numberString = StringBuilder()
                    // Attempt to match a new ordered list item.
                    // Assume matchNewOrderedListItem returns a Pair:
                    //   first: Boolean indicating a match,
                    //   second: the collected number string.
                    val matched = matchNewOrderedListItem(stream, numberString)
                    if (matched) {
                        break
                    } else {
                        markDownBlockParsedResult.addNewTokenToParsedResult(numberString.toString())
                    }
                } else if (matchNewListItem(stream) || matchNewBlock(stream)) {
                    break
                }
                // Add the newline character as a token.
                markDownBlockParsedResult.addNewTokenToParsedResult(newLineChar.toString())
            }
            parseBlock(stream)
        }
    }
    /**
     * Complete list parsing
     */
    protected fun completeListParsing(stream: Stream): Boolean {
        if (stream.peek().toChar() == ' ') {
            // Consume all consecutive spaces
            do {
                stream.get()
            } while (stream.peek().toChar() == ' ')

            parseBlock(stream)
            parseSubBlocks(stream)
            return true
        }
        return false
    }
    /**
     * Capture list token
     */
    private fun captureListToken() {
        // Implementation for capturing list token
        val html = StringBuilder()
        markDownBlockParsedResult.translate()
        val htmlString = markDownBlockParsedResult.generateHtmlString()

        html.append("<li>")
        html.append(htmlString)
        html.append("</li>")

        val htmlFinal = html.toString()
        val codeGen = MarkDownListHtmlGenerator(htmlFinal)

        markDownBlockParsedResult.clear()
        markDownBlockParsedResult.foundHtmlTags()
        markDownBlockParsedResult.appendToTokens(codeGen)
    }

    companion object {
        /**
         * Check if character is a hyphen
         */
        fun isHyphen(ch: Int): Boolean {
            return ch == '-'.code
        }

        /**
         * Check if character is a plus
         */
        fun isPlus(ch: Int): Boolean {
            return ch == '+'.code
        }

        /**
         * Check if character is an asterisk
         */
        fun isAsterisk(ch: Int): Boolean {
            return ch == '*'.code
        }

        /**
         * Check if character is a dot
         */
        fun isDot(ch: Int): Boolean {
            return ch == '.'.code
        }

        /**
         * Check if character is a newline
         */
        fun isNewLine(ch: Int): Boolean {
            return ch == '\r'.code || ch == '\n'.code
        }
    }

    fun getParsedResult(): MarkDownParsedResult {
        return markDownBlockParsedResult
    }
}

/**
 * Parser for ordered lists
 */
class OrderedListParser : ListParser() {
    /**
     * Match ordered list syntax in the input stream
     */
    override fun match(stream: Stream) {
        val numberBuilder = StringBuilder()
        // Check if the next character is a digit
        if (isDigit(stream.peek())) {
            // Read and collect digit characters
            do {
                val streamChar = stream.get().toChar()
                numberBuilder.append(streamChar)
            } while (isDigit(stream.peek()))

            // Check if the next character is a dot
            if (isDot(stream.peek())) {
                stream.get() // Consume the dot

                if (completeListParsing(stream)) {
                    captureOrderedListToken(numberBuilder.toString())
                } else {
                    numberBuilder.append('.')
                    markDownBlockParsedResult.addNewTokenToParsedResult(numberBuilder.toString())
                }
            } else {
                markDownBlockParsedResult.addNewTokenToParsedResult(numberBuilder.toString())
            }
        }
    }

    /**
     * Capture ordered list token
     */
    private fun captureOrderedListToken(numberString: String) {
        val html = StringBuilder()
        markDownBlockParsedResult.translate()
        val htmlString = markDownBlockParsedResult.generateHtmlString()

        html.append("<li>")
        html.append(htmlString)
        html.append("</li>")

        val htmlFinal = html.toString()
        val codeGen = MarkDownOrderedListHtmlGenerator(htmlFinal, numberString)

        markDownBlockParsedResult.clear()
        markDownBlockParsedResult.foundHtmlTags()
        markDownBlockParsedResult.appendToTokens(codeGen)
    }
}