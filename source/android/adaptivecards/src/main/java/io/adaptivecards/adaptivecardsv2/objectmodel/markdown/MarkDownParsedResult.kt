// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.adaptivecardsv2.objectmodel.markdown

/**
 * Base class for parsed Markdown results
 */
class MarkDownParsedResult {
    private val codeGenTokens = mutableListOf<MarkDownHtmlGenerator>()
    private val emphasisLookUpTable = mutableListOf<MarkDownEmphasisHtmlGenerator>()
    private var isHTMLTagsAdded = false
    private var isCaptured = false

    /**
     * Translate intermediate parsing result to a form that can be written to HTML string
     */
    fun translate() {
        matchLeftAndRightEmphases()
    }

    /**
     * Add block tags to the parsed result
     */
    fun addBlockTags() {
        // Parsing is done, let code gen token know who is the head of the list
        if (codeGenTokens.isNotEmpty()) {
            codeGenTokens.first().makeItHead()
            
            // Parsing is done, let code gen token know who is the tail of the list
            codeGenTokens.last().makeItTail()
        }
    }

    /**
     * Mark tags in HTML generator
     */
    private fun markTags(htmlGenerator: MarkDownHtmlGenerator) {
        if (codeGenTokens.isNotEmpty() && codeGenTokens.last().getBlockType() != htmlGenerator.getBlockType()) {
            if (codeGenTokens.last().isNewLine()) {
                codeGenTokens.removeAt(codeGenTokens.size - 1)
            }

            if (codeGenTokens.isNotEmpty()) {
                codeGenTokens.last().makeItTail()
            }
            htmlGenerator.makeItHead()
        }
    }

    /**
     * Generate HTML string from parsed result
     */
    fun generateHtmlString(): String {
        val htmlString = StringBuilder()
        
        // Generate HTML from all tokens
        for (token in codeGenTokens) {
            htmlString.append(token.generateHtmlString())
        }
        
        return htmlString.toString()
    }

    /**
     * Append contents of another parsing result
     */
    fun appendParseResult(parseResult: MarkDownParsedResult) {
        if (codeGenTokens.isNotEmpty() && parseResult.codeGenTokens.isNotEmpty()) {
            // Check if two different block types, then add closing tag followed by the opening tag of new type
            markTags(parseResult.codeGenTokens.first())
        }
        
        codeGenTokens.addAll(parseResult.codeGenTokens)
        emphasisLookUpTable.addAll(parseResult.emphasisLookUpTable)
        isHTMLTagsAdded = isHTMLTagsAdded || parseResult.hasHtmlTags()
        setIsCaptured(parseResult.getIsCaptured())
    }

    /**
     * Append HTML code generator to tokens
     */
    fun appendToTokens(htmlGenerator: MarkDownHtmlGenerator) {
        if (codeGenTokens.isNotEmpty()) {
            // Check if two different block types, then add closing tag followed by the opening tag of new type
            markTags(htmlGenerator)
        }
        codeGenTokens.add(htmlGenerator)
    }

    /**
     * Append emphasis HTML code generator to lookup table
     */
    fun appendToLookUpTable(emphasisHtmlGenerator: MarkDownEmphasisHtmlGenerator) {
        emphasisLookUpTable.add(emphasisHtmlGenerator)
    }

    /**
     * Add a character as a new token
     */
    fun addNewTokenToParsedResult(ch: Char) {
        val token = ch.toString()
        addNewTokenToParsedResult(token)
    }

    /**
     * Add a string as a new token
     */
    fun addNewTokenToParsedResult(word: String) {
        if (word.isNotEmpty()) {
            val htmlToken = MarkDownStringHtmlGenerator(word)
            appendToTokens(htmlToken)
        }
    }

    /**
     * Add a new line character as a token
     */
    fun addNewLineTokenToParsedResult(ch: Char) {
        val token = ch.toString()
        val htmlToken = MarkDownNewLineHtmlGenerator(token)
        appendToTokens(htmlToken)
    }

    /**
     * Remove the first token
     */
    fun popFront() {
        if (codeGenTokens.isNotEmpty()) {
            codeGenTokens.removeAt(0)
        }
    }

    /**
     * Remove the last token
     */
    fun popBack() {
        if (codeGenTokens.isNotEmpty()) {
            codeGenTokens.removeAt(codeGenTokens.size - 1)
        }
    }

    /**
     * Clear all tokens
     */
    fun clear() {
        codeGenTokens.clear()
        emphasisLookUpTable.clear()
    }

    /**
     * Check if result has HTML tags
     */
    fun hasHtmlTags(): Boolean {
        return isHTMLTagsAdded
    }

    /**
     * Mark that HTML tags were found
     */
    fun foundHtmlTags() {
        isHTMLTagsAdded = true
    }

    /**
     * Get captured state
     */
    fun getIsCaptured(): Boolean {
        return isCaptured
    }

    /**
     * Set captured state
     */
    fun setIsCaptured(value: Boolean) {
        isCaptured = value
    }

    /**
     * Match left and right emphases
     * Following the rules specified in CommonMark (http://spec.commonmark.org/0.27/)
     */
    private fun matchLeftAndRightEmphases() {
        val leftEmphasisToExplore = mutableListOf<MarkDownEmphasisHtmlGenerator>()
        var currentIndex = 0
        
        while (currentIndex < emphasisLookUpTable.size) {
            val currentEmphasis = emphasisLookUpTable[currentIndex]
            
            // Keep exploring left until right token is found
            if (currentEmphasis.isLeftEmphasis() || 
                (currentEmphasis.isLeftAndRightEmphasis() && leftEmphasisToExplore.isEmpty())) {
                
                if (currentEmphasis.isLeftAndRightEmphasis() && currentEmphasis.isRightEmphasis()) {
                    // Reverse Direction Type; right emphasis to left emphasis
                    currentEmphasis.changeDirectionToLeft()
                }
                
                leftEmphasisToExplore.add(currentEmphasis)
                currentIndex++
            } else if (leftEmphasisToExplore.isNotEmpty()) {
                var currentLeftEmphasis = leftEmphasisToExplore.last()
                
                // Check if matches are found
                if (!currentLeftEmphasis.isMatch(currentEmphasis)) {
                    val store = mutableListOf<MarkDownEmphasisHtmlGenerator>()
                    var isFound = false
                    
                    // Search first if matching left emphasis can be found with the right delim
                    while (leftEmphasisToExplore.isNotEmpty() && !isFound) {
                        val leftToken = leftEmphasisToExplore.last()
                        if (leftToken.isMatch(currentEmphasis)) {
                            currentLeftEmphasis = leftToken
                            isFound = true
                        } else {
                            leftEmphasisToExplore.removeAt(leftEmphasisToExplore.size - 1)
                            store.add(leftToken)
                        }
                    }
                    
                    // If no match found
                    if (!isFound) {
                        // Restore state
                        while (!isFound && store.isNotEmpty()) {
                            leftEmphasisToExplore.add(store.last())
                            store.removeAt(store.size - 1)
                        }
                        
                        // Check for the reason why we had to backtrack
                        if (leftEmphasisToExplore.last().isSameType(currentEmphasis)) {
                            // Right emphasis becomes left emphasis
                            currentEmphasis.changeDirectionToLeft()
                        } else {
                            // Move to next token for right delim tokens
                            currentIndex++
                        }
                        // No matching found begin from the start
                        continue
                    }
                }
                
                // Check which one has leftover delims
                isHTMLTagsAdded = currentLeftEmphasis.generateTags(currentEmphasis) || isHTMLTagsAdded
                
                // All right delims used, move to next
                if (currentEmphasis.isDone()) {
                    currentIndex++
                }
                
                // All left or right delims used, pop
                if (currentLeftEmphasis.isDone()) {
                    leftEmphasisToExplore.removeAt(leftEmphasisToExplore.size - 1)
                }
            } else {
                currentIndex++
            }
        }
    }
} 