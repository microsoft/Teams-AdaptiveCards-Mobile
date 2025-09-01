package io.adaptivecards.adaptivecardsv2.objectmodel.markdown

class Stream(private var source: String) {
    private var position: Int = 0
    private val pushbackBuffer = mutableListOf<Char>()

    /**
     * Returns the next character (as an Int) without consuming it.
     * If there is a character in the pushback buffer, that is returned;
     * otherwise, returns the character from the source at the current position.
     * If no more characters exist, returns EOF.
     */
    fun peek(): Int {
        return if (pushbackBuffer.isNotEmpty()) {
            pushbackBuffer.last().code
        } else {
            if (position < source.length) source[position].code else EOF
        }
    }

    /**
     * Consumes and returns the next character.
     * It first checks the pushback buffer; if empty, it returns the character
     * from the source and advances the position.
     */
    fun get(): Char {
        return if (pushbackBuffer.isNotEmpty()) {
            pushbackBuffer.removeAt(pushbackBuffer.size - 1)
        } else {
            if (position < source.length) source[position++] else EOF.toChar()
        }
    }

    /**
     * Pushes back a character so that it will be returned on the next call to peek() or get().
     */
    fun putback(ch: Char) {
        pushbackBuffer.add(ch)
    }

    /**
     * Returns the current reading position in the stream.
     * This is the source position minus the number of characters in the pushback buffer.
     */
    fun tell(): Int {
        return position - pushbackBuffer.size
    }

    /**
     * Seeks to a specified position in the source.
     * This clears the pushback buffer and resets the reading position.
     */
    fun seek(newPosition: Int) {
        if (newPosition < 0 || newPosition > source.length) {
            throw IllegalArgumentException("Seek position out of bounds")
        }
        pushbackBuffer.clear()
        position = newPosition
    }

    /**
     * Clears the pushback buffer. In this implementation, it simulates clearing any error flags.
     */
    fun clear() {
        pushbackBuffer.clear()
    }

    /**
     * Checks if the stream has reached the end of the source.
     */
    fun isEOF(): Boolean {
        return position >= source.length && pushbackBuffer.isEmpty()
    }

    companion object {
        const val EOF: Int = -1
    }
}