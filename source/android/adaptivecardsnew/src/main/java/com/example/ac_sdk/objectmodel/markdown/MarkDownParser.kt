// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package com.example.ac_sdk.objectmodel.markdown

/**
 * Main class for parsing Markdown text and converting it to HTML
 */
class MarkDownParser(private val text: String) {
    private var hasHTMLTag = false
    private var isEscaped = false
    private val parsedResult = MarkDownParsedResult()

    /**
     * Transform Markdown text to HTML
     */
    fun transformToHtml(): String {
        if (text.isEmpty()) {
            return "<p></p>"
        }

        // Begin parsing HTML blocks
        parseBlock()

        // Process further what is parsed before outputting HTML string
        parsedResult.translate()

        // Add block tags such as <p> <ul>
        parsedResult.addBlockTags()

        hasHTMLTag = parsedResult.hasHtmlTags()
        return parsedResult.generateHtmlString()
    }

    /**
     * Check if the Markdown text contains HTML tags
     */
    fun hasHtmlTags(): Boolean {
        return hasHTMLTag
    }

    /**
     * Check if the text was escaped during parsing
     */
    fun isEscaped(): Boolean {
        return isEscaped
    }

    /**
     * Get the original raw text
     */
    fun getRawText(): String {
        return text
    }

    /**
     * Parse Markdown blocks
     */
    private fun parseBlock() {
        val escapedText = escapeText()
        // Create a PushbackReader with a reasonable buffer size
        val stream = Stream(escapedText)
        val parser = EmphasisParser()
        while (!stream.isEOF()) {
            parser.parseBlock(stream)
        }
        parsedResult.appendParseResult(parser.getParsedResult())
    }

    /**
     * Escape special HTML characters in the text
     */
    private fun escapeText(): String {
        val escaped = StringBuilder()
        var nonEscapedCounts = 0

        for (i in text.indices) {
            when (text[i]) {
                '<' -> escaped.append("&lt;")
                '>' -> escaped.append("&gt;")
                '"' -> escaped.append("&quot;")
                '&' -> escaped.append("&amp;")
                else -> {
                    escaped.append(text[i])
                    nonEscapedCounts++
                }
            }
        }

        isEscaped = (nonEscapedCounts != text.length)
        return escaped.toString()
    }
}