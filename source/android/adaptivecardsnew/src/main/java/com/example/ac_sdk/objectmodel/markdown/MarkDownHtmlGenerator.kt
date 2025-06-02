// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package com.example.ac_sdk.objectmodel.markdown

/**
 * Base class for HTML generation from Markdown elements
 */
abstract class MarkDownHtmlGenerator(protected var token: String = "") {

    enum class MarkDownBlockType {
        ContainerBlock,
        UnorderedList,
        OrderedList
    }

    protected var isHead = false
    protected var isTail = false
    protected val html = StringBuilder()

    /**
     * Mark this generator as the head of a sequence
     */
    fun makeItHead() {
        isHead = true
    }

    /**
     * Mark this generator as the tail of a sequence
     */
    fun makeItTail() {
        isTail = true
    }

    /**
     * Check if this generator represents a new line
     */
    open fun isNewLine(): Boolean {
        return false
    }

    /**
     * Generate HTML string from this element
     */
    abstract fun generateHtmlString(): String

    /**
     * Get the block type of this element
     */
    open fun getBlockType(): MarkDownBlockType {
        return MarkDownBlockType.ContainerBlock
    }
}

/**
 * HTML generator for simple text strings
 */
open class MarkDownStringHtmlGenerator(token: String) : MarkDownHtmlGenerator(token) {
    override fun generateHtmlString(): String {
        if (isHead) {
            token = "<p>$token"
        }

        if (isTail) {
            return "$token</p>"
        }

        return token
    }
}

/**
 * HTML generator for new line characters
 */
class MarkDownNewLineHtmlGenerator(token: String) : MarkDownStringHtmlGenerator(token) {
    override fun isNewLine(): Boolean {
        return true
    }
}

/**
 * HTML generator for emphasis elements (bold/italic)
 */
abstract class MarkDownEmphasisHtmlGenerator(
    token: String,
    var numberOfUnusedDelimiters: Int,
    val type: DelimiterType,
    protected val tags: MutableList<String> = mutableListOf()
) : MarkDownHtmlGenerator(token) {
    
    companion object {
        const val LEFT = 0
        const val RIGHT = 1
    }
    
    var directionType = RIGHT

    /**
     * Check if this is a right emphasis
     */
    open fun isRightEmphasis(): Boolean {
        return false
    }

    /**
     * Check if this is a left emphasis
     */
    open fun isLeftEmphasis(): Boolean {
        return false
    }

    /**
     * Check if this can be both left and right emphasis
     */
    open fun isLeftAndRightEmphasis(): Boolean {
        return false
    }

    /**
     * Add italic tag to tags list
     */
    open fun pushItalicTag() {
        tags.add("<em>")
    }

    /**
     * Add bold tag to tags list
     */
    open fun pushBoldTag() {
        tags.add("<strong>")
    }

    /**
     * Check if this emphasis matches another
     */
    fun isMatch(other: MarkDownEmphasisHtmlGenerator): Boolean {
        if (this.type == other.type) {
            // Rule #9 & #10, sum of delimiter count can't be multiple of 3
            return !(
                (this.isLeftAndRightEmphasis() || other.isLeftAndRightEmphasis()) &&
                ((this.numberOfUnusedDelimiters + other.numberOfUnusedDelimiters) % 3 == 0)
            )
        }
        return false
    }

    /**
     * Check if this emphasis is the same type as another
     */
    fun isSameType(other: MarkDownEmphasisHtmlGenerator): Boolean {
        return type == other.type
    }

    /**
     * Check if all delimiters have been used
     */
    fun isDone(): Boolean {
        return numberOfUnusedDelimiters == 0
    }

    /**
     * Generate tags based on matching with another token
     */
    fun generateTags(token: MarkDownEmphasisHtmlGenerator): Boolean {
        var delimiterCount = 0
        val leftOver = this.numberOfUnusedDelimiters - token.numberOfUnusedDelimiters
        
        delimiterCount = adjustEmphasisCounts(leftOver, token)
        val hasHtmlTags = delimiterCount > 0

        // Emphasis found
        if (delimiterCount % 2 != 0) {
            this.pushItalicTag()
            token.pushItalicTag()
        }

        // Strong emphasis found
        for (i in 0 until delimiterCount / 2) {
            this.pushBoldTag()
            token.pushBoldTag()
        }
        
        return hasHtmlTags
    }

    /**
     * Change direction to left
     */
    fun changeDirectionToLeft() {
        directionType = LEFT
    }

    /**
     * Adjust emphasis counts between left and right tokens
     */
    protected fun adjustEmphasisCounts(leftOver: Int, rightToken: MarkDownEmphasisHtmlGenerator): Int {
        var delimiterCount = 0
        if (leftOver >= 0) {
            delimiterCount = this.numberOfUnusedDelimiters - leftOver
            this.numberOfUnusedDelimiters = leftOver
            rightToken.numberOfUnusedDelimiters = 0
        } else {
            delimiterCount = this.numberOfUnusedDelimiters
            rightToken.numberOfUnusedDelimiters = -leftOver
            this.numberOfUnusedDelimiters = 0
        }
        return delimiterCount
    }
}

/**
 * HTML generator for left (opening) emphasis
 */
class MarkDownLeftEmphasisHtmlGenerator(
    token: String,
    sizeOfEmphasisDelimiterRun: Int,
    type: DelimiterType,
    tags: MutableList<String> = mutableListOf()
) : MarkDownEmphasisHtmlGenerator(token, sizeOfEmphasisDelimiterRun, type, tags) {
    
    override fun isLeftEmphasis(): Boolean {
        return true
    }
    
    override fun generateHtmlString(): String {
        if (isHead) {
            html.append("<p>")
        }

        if (numberOfUnusedDelimiters > 0) {
            val startIdx = token.length - numberOfUnusedDelimiters
            html.append(token.substring(startIdx))
        }

        // Append tags; since left delims, append it in the reverse order
        for (tag in tags.reversed()) {
            html.append(tag)
        }

        if (isTail) {
            return html.append("</p>").toString()
        }

        return html.toString()
    }
}

/**
 * HTML generator for right (closing) emphasis
 */
open class MarkDownRightEmphasisHtmlGenerator(
    token: String,
    sizeOfEmphasisDelimiterRun: Int,
    type: DelimiterType
) : MarkDownEmphasisHtmlGenerator(token, sizeOfEmphasisDelimiterRun, type) {
    
    override fun isRightEmphasis(): Boolean {
        return directionType == RIGHT
    }
    
    override fun isLeftEmphasis(): Boolean {
        return directionType == LEFT
    }
    
    override fun generateHtmlString(): String {
        if (isHead) {
            html.append("<p>")
        }

        // Append tags
        for (tag in tags) {
            html.append(tag)
        }

        // If there are unused emphasis, append them
        if (numberOfUnusedDelimiters > 0) {
            val startIdx = token.length - numberOfUnusedDelimiters
            html.append(token.substring(startIdx))
        }

        if (isTail) {
            return html.toString() + "</p>"
        }

        return html.toString()
    }
    
    override fun pushItalicTag() {
        tags.add("</em>")
    }
    
    override fun pushBoldTag() {
        tags.add("</strong>")
    }
}

/**
 * HTML generator for emphasis that can be both left and right
 */
class MarkDownLeftAndRightEmphasisHtmlGenerator(
    token: String,
    sizeOfEmphasisDelimiterRun: Int,
    type: DelimiterType
) : MarkDownRightEmphasisHtmlGenerator(token, sizeOfEmphasisDelimiterRun, type) {
    
    override fun isLeftAndRightEmphasis(): Boolean {
        return true
    }
    
    override fun pushItalicTag() {
        if (directionType == LEFT) {
            tags.add("<em>")
        } else {
            tags.add("</em>")
        }
    }
    
    override fun pushBoldTag() {
        if (directionType == LEFT) {
            tags.add("<strong>")
        } else {
            tags.add("</strong>")
        }
    }
}

/**
 * HTML generator for unordered lists
 */
class MarkDownListHtmlGenerator(token: String) : MarkDownHtmlGenerator(token) {
    override fun generateHtmlString(): String {
        if (isHead) {
            token = "<ul>$token"
        }

        if (isTail) {
            return "$token</ul>"
        }

        return token
    }
    
    override fun getBlockType(): MarkDownBlockType {
        return MarkDownBlockType.UnorderedList
    }
}

/**
 * HTML generator for ordered lists
 */
class MarkDownOrderedListHtmlGenerator(
    token: String,
    private val numberString: String
) : MarkDownHtmlGenerator(token) {
    override fun generateHtmlString(): String {
        if (isHead) {
            token = "<ol start=\"$numberString\">$token"
        }

        if (isTail) {
            return "$token</ol>"
        }

        return token
    }
    
    override fun getBlockType(): MarkDownBlockType {
        return MarkDownBlockType.OrderedList
    }
}