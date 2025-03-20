// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer

import android.graphics.drawable.Drawable
import android.os.AsyncTask
import android.view.View
import android.widget.ImageView
import io.adaptivecards.renderer.http.HttpRequestHelper
import io.adaptivecards.renderer.http.HttpRequestResult
import java.lang.ref.WeakReference
import java.nio.charset.StandardCharsets

/**
 * Responsible for rendering the Fluent Icon element
 **/
open class FluentIconImageLoaderAsync(
    val renderedCard: RenderedAdaptiveCard,
    private val targetIconSize: Long,
    private val iconColor: String,
    private var isFilledStyle: Boolean,
    view: View
) : AsyncTask<String, Void, HttpRequestResult<String>>() {

    val viewReference: WeakReference<View> = WeakReference(view)
    override fun doInBackground(vararg args: String): HttpRequestResult<String>? {
        return if (args.isEmpty()) {
            null
        } else {
            val response: HttpRequestResult<String>? = FluentIconUtils.fetchIconInfo(args[0])
            response?.let {
                return response
            } ?: fetchUnavailableIconInfo()
        }
    }

    /**
     * fetches the info for the unavailable filled style "Square" icon used as a fallback
     */
    private fun fetchUnavailableIconInfo(): HttpRequestResult<String>? {
        isFilledStyle = true
        val unavailableIconURL = Util.getUnavailableIconSvgInfoUrl()
        return FluentIconUtils.fetchIconInfo(unavailableIconURL)
    }

    override fun onPostExecute(result: HttpRequestResult<String>?) {
        val context = viewReference.get()?.context
        val response = FluentIconUtils.processResponseAndGetIconDrawable(
                result,
                context,
                iconColor,
                targetIconSize,
                isFilledStyle
        )
        renderFluentIcon(response.drawable, response.flipInRtl)
    }

    /**
     * renders the fluent icon
     * drawable - the drawable object created from the svg string
     * flipInRtl - value received from the CDN to determine if the icon can be flipped in RTL
     **/
    open fun renderFluentIcon(drawable: Drawable?, flipInRtl: Boolean) {
        val view = viewReference.get()
        if (view != null && view is ImageView) {
            view.setImageDrawable(drawable)
            if (renderedCard.adaptiveCard.GetRtl() == flipInRtl) {
                view.scaleX = -1f
            }
        }
    }
}