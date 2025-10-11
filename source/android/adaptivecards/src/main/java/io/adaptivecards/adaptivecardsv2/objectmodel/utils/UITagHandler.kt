package io.adaptivecards.adaptivecardsv2.objectmodel.utils

import android.text.Editable
import android.text.Html
import org.xml.sax.Attributes
import org.xml.sax.ContentHandler
import org.xml.sax.Locator
import org.xml.sax.XMLReader
import java.util.ArrayDeque
import java.util.Deque

class UlTagHandler : Html.TagHandler, ContentHandler {
    private var tagNumber = 0
    private var orderedList = false
    private var defaultContentHandler: ContentHandler? = null
    private var text: Editable? = null
    private val tagStatusQueue: Deque<Boolean> = ArrayDeque()

    private fun getAttribute(attributeName: String, attributes: Attributes): String? {
        return attributes.getValue(attributeName)
    }

    fun handleTag(
        opening: Boolean,
        tag: String,
        output: Editable,
        attributes: Attributes?
    ): Boolean {
        var tagWasHandled = false

        if (tag == "ol" && !opening) {
            orderedList = false
            tagWasHandled = true
        }

        if (tag == "ul" && !opening) {
            output.append("\n")
            tagWasHandled = true
        }

        if (tag == "listItem" && opening) {
            if (orderedList) {
                output.append("\n")
                output.append(tagNumber.toString())
                output.append(". ")
                tagNumber++
            } else {
                output.append("\n• ")
            }
            tagWasHandled = true
        }

        if (tag == "ol" && opening) {
            orderedList = true
            val tagNumberString = attributes?.let { getAttribute("start", it) }

            val retrievedTagNumber = tagNumberString?.toInt() ?: 1
            tagNumber = retrievedTagNumber
            tagWasHandled = true
        }

        return tagWasHandled
    }

    override fun handleTag(opening: Boolean, tag: String, output: Editable, xmlReader: XMLReader) {
        if (defaultContentHandler == null) {
            // Save input text
            text = output

            // Store default XMLReader content handler
            defaultContentHandler = xmlReader.contentHandler

            // Replace content handler with this instance
            xmlReader.contentHandler = this

            // Initialize tag status queue
            tagStatusQueue.addLast(false)
        }
    }

    // ContentHandler override methods
    override fun startElement(
        uri: String,
        localName: String,
        qName: String,
        attributes: Attributes
    ) {
        val isHandled = handleTag(true, localName, text!!, attributes)
        tagStatusQueue.addLast(isHandled)

        if (!isHandled) {
            defaultContentHandler?.startElement(uri, localName, qName, attributes)
        }
    }

    override fun endElement(uri: String, localName: String, qName: String) {
        if (!tagStatusQueue.removeLast()) {
            defaultContentHandler?.endElement(uri, localName, qName)
        }
        handleTag(false, localName, text!!, null)
    }

    override fun setDocumentLocator(locator: Locator) {
        defaultContentHandler?.setDocumentLocator(locator)
    }

    override fun startDocument() {
        defaultContentHandler?.startDocument()
    }

    override fun endDocument() {
        defaultContentHandler?.endDocument()
    }

    override fun startPrefixMapping(prefix: String, uri: String) {
        defaultContentHandler?.startPrefixMapping(prefix, uri)
    }

    override fun endPrefixMapping(prefix: String) {
        defaultContentHandler?.endPrefixMapping(prefix)
    }

    override fun characters(ch: CharArray, start: Int, length: Int) {
        defaultContentHandler?.characters(ch, start, length)
    }

    override fun ignorableWhitespace(ch: CharArray, start: Int, length: Int) {
        defaultContentHandler?.ignorableWhitespace(ch, start, length)
    }

    override fun processingInstruction(target: String, data: String) {
        defaultContentHandler?.processingInstruction(target, data)
    }

    override fun skippedEntity(name: String) {
        defaultContentHandler?.skippedEntity(name)
    }
}
