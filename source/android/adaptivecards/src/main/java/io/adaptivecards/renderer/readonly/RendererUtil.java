// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.readonly;

import android.os.Build;
import android.text.Editable;
import android.text.Html;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.style.URLSpan;

import org.xml.sax.Attributes;
import org.xml.sax.ContentHandler;
import org.xml.sax.Locator;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;

import java.util.ArrayDeque;
import java.util.Calendar;
import java.util.GregorianCalendar;

import io.adaptivecards.objectmodel.DateTimePreparser;
import io.adaptivecards.objectmodel.HorizontalAlignment;
import io.adaptivecards.objectmodel.MarkDownParser;
import io.adaptivecards.renderer.RenderArgs;
import io.adaptivecards.renderer.http.UrlPolicy;

public class RendererUtil
{

    public static boolean isValidDate(String s)
    {
        long[] year = {0}, month = {0}, day = {0};
        return DateTimePreparser.TryParseSimpleDate(s, year, month, day);
    }

    public static Calendar getDate(String s)
    {
        Calendar calendar = new GregorianCalendar();

        long[] year = {0}, month = {0}, day = {0};
        if (DateTimePreparser.TryParseSimpleDate(s, year, month, day))
        {
            // The month must be subtracted one as java.util.Calendar class starts indexing the months at 0
            calendar.set((int)year[0], (int)month[0] - 1, (int)day[0]);
        }

        return calendar;
    }

    public static boolean isValidTime(String s)
    {
        long[] hour = {0}, minutes = {0};
        return DateTimePreparser.TryParseSimpleTime(s, hour, minutes);
    }

    public static Calendar getTime(String s)
    {
        Calendar calendar = new GregorianCalendar();
        long[] hour = {0}, minutes = {0};

        if (DateTimePreparser.TryParseSimpleTime(s, hour, minutes))
        {
            calendar.set(Calendar.HOUR_OF_DAY, (int)hour[0]);
            calendar.set(Calendar.MINUTE, (int)minutes[0]);
            calendar.set(Calendar.SECOND, 0);
        }

        return calendar;
    }

    public static class SpecialTextHandleResult
    {
        private CharSequence m_htmlString;
        private boolean m_hasLinks;
        private boolean m_isALink;

        public SpecialTextHandleResult(CharSequence htmlString, boolean hasLinks, boolean isALink)
        {
            m_htmlString = htmlString;
            m_hasLinks = hasLinks;
            m_isALink = isALink;
        }

        public CharSequence getHtmlString()
        {
            return m_htmlString;
        }

        public boolean getHasLinks()
        {
            return m_hasLinks;
        }

        public boolean isALink()
        {
            return m_isALink;
        }
    }

    public static CharSequence handleSpecialText(String textWithFormattedDates)
    {
        Spanned spanned = getSpecialTextSpans(textWithFormattedDates);
        return trimHtmlString(spanned);
    }

    private static boolean FirstAndLastSpansAreTheSame(Spanned spanned)
    {
        URLSpan[] firstSpan = spanned.getSpans(0, 1, URLSpan.class);
        URLSpan[] lastSpan = spanned.getSpans(spanned.length() - 2, spanned.length(), URLSpan.class);

        // as there is only one span in the whole string then the first and last characters must have only one span
        return (firstSpan.length == 1 && lastSpan.length == 1);
    }

    public static SpecialTextHandleResult handleSpecialTextAndQueryLinks(String textWithFormattedDates)
    {
        Spanned spanned = getSpecialTextSpans(textWithFormattedDates);

        URLSpan[] spans = spanned.getSpans(0, spanned.length(), URLSpan.class);

        boolean isALink = false;

        // if there is only one span that uses the whole size of the string then the whole string is
        // just one link
        if (spans.length == 1)
        {
            isALink = FirstAndLastSpansAreTheSame(spanned);
        }

        return new SpecialTextHandleResult(trimHtmlString(spanned), (spans.length > 0), isALink);
    }

    public static Spanned getSpecialTextSpans(String textWithFormattedDates)
    {
        MarkDownParser markDownParser = new MarkDownParser(textWithFormattedDates);
        String textString = markDownParser.TransformToHtml();

        // preprocess string to change <li> to <listItem> so we get a chance to handle them
        textString = textString.replace("<li>", "<listItem>");
        textString = textString.replaceAll("(" + System.lineSeparator() + "|\r\n|\n\r|\r|\n)", "<br/>");

        Spanned htmlString;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N)
        {
            htmlString = Html.fromHtml(textString, Html.FROM_HTML_MODE_COMPACT, null, new UlTagHandler());
        }
        else
        {
            // Before Android N, html.fromHtml adds two newline characters to end of string
            htmlString = Html.fromHtml(textString, null, new UlTagHandler());
        }

        return removeDisallowedLinks(htmlString);
    }

    /**
     * Strips every {@link URLSpan} whose scheme is not permitted by {@link UrlPolicy}.
     *
     * <p>Link text comes from a remote card author and {@code URLSpan.onClick} launches an implicit
     * {@code ACTION_VIEW} intent for whatever URL it holds. Removing the span here covers every way
     * the platform can activate it (movement method, touch listener, key listener and accessibility
     * link traversal) rather than guarding each activation site individually.
     */
    private static Spanned removeDisallowedLinks(Spanned htmlString)
    {
        URLSpan[] spans = htmlString.getSpans(0, htmlString.length(), URLSpan.class);
        if (spans.length == 0)
        {
            return htmlString;
        }

        boolean hasDisallowedLink = false;
        for (URLSpan span : spans)
        {
            if (!UrlPolicy.isAllowedNavigationUrl(span.getURL()))
            {
                hasDisallowedLink = true;
                break;
            }
        }

        if (!hasDisallowedLink)
        {
            return htmlString;
        }

        // The span instances are copied by value into the builder, so look the replacements up from
        // the copy rather than reusing the instances obtained from the original Spanned.
        SpannableStringBuilder sanitized = new SpannableStringBuilder(htmlString);
        for (URLSpan span : sanitized.getSpans(0, sanitized.length(), URLSpan.class))
        {
            if (!UrlPolicy.isAllowedNavigationUrl(span.getURL()))
            {
                sanitized.removeSpan(span);
            }
        }

        return sanitized;
    }

    public static CharSequence trimHtmlString(Spanned htmlString)
    {
        int numToRemoveFromEnd = 0;
        int numToRemoveFromStart = 0;

        for (int i = htmlString.length()-1; i >= 0; --i)
        {
            if (htmlString.charAt(i) == '\n')
            {
                numToRemoveFromEnd++;
            }
            else
            {
                break;
            }
        }

        for (int i = 0; i <= htmlString.length()-1; ++i)
        {
            if (htmlString.charAt(i) == '\n')
            {
                numToRemoveFromStart++;
            }
            else
            {
                break;
            }
        }

        //Sanity check
        if (numToRemoveFromStart + numToRemoveFromEnd >= htmlString.length())
        {
            return htmlString;
        }

        return htmlString.subSequence(numToRemoveFromStart, htmlString.length() - numToRemoveFromEnd);
    }

    // Class to replace ul and li tags
    public static class UlTagHandler implements Html.TagHandler, ContentHandler
    {
        private int tagNumber = 0;
        private boolean orderedList = false;
        private ContentHandler defaultContentHandler = null;
        private Editable text = null;
        private ArrayDeque<Boolean> tagStatusQueue = new ArrayDeque<>();

        private String getAttribute(String attributeName, Attributes attributes)
        {
            return attributes.getValue(attributeName);
        }

        public boolean handleTag(boolean opening, String tag, Editable output, Attributes attributes)
        {
            boolean tagWasHandled = false;

            if ((tag.equals("ol") && !opening))
            {
                orderedList = false;
                tagWasHandled = true;
            }

            if (tag.equals("ul") && !opening)
            {
                output.append("\n");
                tagWasHandled = true;
            }

            if (tag.equals("listItem") && opening)
            {
                if (orderedList)
                {
                    output.append("\n");
                    output.append(String.valueOf(tagNumber));
                    output.append(". ");
                    tagNumber++;
                }
                else
                {
                    output.append("\n• ");
                }
                tagWasHandled = true;
            }

            if (tag.equals("ol") && opening)
            {
                orderedList = true;
                String tagNumberString = getAttribute("start", attributes);

                int retrievedTagNumber = 1;
                if (tagNumberString != null)
                {
                    retrievedTagNumber = Integer.parseInt(tagNumberString);
                }

                tagNumber = retrievedTagNumber;
                tagWasHandled = true;
            }

            return tagWasHandled;
        }

        @Override
        public void handleTag(boolean opening, String tag, Editable output, XMLReader xmlReader)
        {
            if (defaultContentHandler == null)
            {
                // save input text
                text = output;

                // store default XMLReader object
                defaultContentHandler = xmlReader.getContentHandler();

                // replace content handler with our own that forwards to calls to default when needed
                xmlReader.setContentHandler(this);

                // handle endElement() callback for <inject/> tag
                tagStatusQueue.addLast(Boolean.FALSE);
            }
        }

        // ContentHandler override methods
        @Override
        public void startElement(String uri, String localName, String qName, Attributes attributes) throws SAXException
        {
            boolean isHandled = handleTag(true, localName, text, attributes);
            tagStatusQueue.addLast(isHandled);

            if (!isHandled)
            {
                defaultContentHandler.startElement(uri, localName, qName, attributes);
            }
        }

        @Override
        public void endElement(String uri, String localName, String qName) throws SAXException
        {
            if (!tagStatusQueue.removeLast())
            {
                defaultContentHandler.endElement(uri, localName, qName);
            }

            handleTag(false, localName, text, (Attributes)null);
        }

        @Override
        public void setDocumentLocator(Locator locator)
        {
            defaultContentHandler.setDocumentLocator(locator);
        }

        @Override
        public void startDocument() throws SAXException
        {
            defaultContentHandler.startDocument();
        }

        @Override
        public void endDocument() throws SAXException
        {
            defaultContentHandler.endDocument();
        }

        @Override
        public void startPrefixMapping(String prefix, String uri) throws SAXException
        {
            defaultContentHandler.startPrefixMapping(prefix, uri);
        }

        @Override
        public void endPrefixMapping(String prefix) throws SAXException
        {
            defaultContentHandler.endPrefixMapping(prefix);
        }

        @Override
        public void characters(char[] chars, int start, int length) throws SAXException {
            defaultContentHandler.characters(chars, start, length);
        }

        @Override
        public void ignorableWhitespace(char[] chars, int start, int length) throws SAXException
        {
            defaultContentHandler.ignorableWhitespace(chars, start, length);
        }

        @Override
        public void processingInstruction(String target, String data) throws SAXException
        {
            defaultContentHandler.processingInstruction(target, data);
        }

        @Override
        public void skippedEntity(String name) throws SAXException
        {
            defaultContentHandler.skippedEntity(name);
        }
    }

    static HorizontalAlignment computeHorizontalAlignment(HorizontalAlignment declaredAlignment, RenderArgs renderArgs)
    {
        if (declaredAlignment != null)
        {
            return declaredAlignment;
        }
        if (renderArgs != null && renderArgs.getHorizontalAlignment() != null)
        {
            return renderArgs.getHorizontalAlignment();
        }
        return HorizontalAlignment.Left;
    }
}
