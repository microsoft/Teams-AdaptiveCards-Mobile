// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.AsyncTask
import android.view.View
import android.widget.ImageView
import com.caverock.androidsvg.SVG
import io.adaptivecards.objectmodel.AdaptiveCardObjectModel
import io.adaptivecards.renderer.http.HttpRequestHelper
import io.adaptivecards.renderer.http.HttpRequestResult
import org.json.JSONObject
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
            fetchIconInfo(args[0])
        }
    }

    override fun onPostExecute(result: HttpRequestResult<String>?) {
        if (result?.isSuccessful == true && result.result.isNotEmpty()) {
            processResponseAndRenderFluentIcon(JSONObject(result.result))
        } else {
            renderFluentIcon(null, false)
        }
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

    /**
     * fetches the icon info from the CDN
     * if the request fails or response is null, fetches the info for the unavailable "Square" icon as a fallback
     * sample url: https://res-1.cdn.office.net/assets/fluentui-react-icons/2.0.226/AlbumAdd/AlbumAdd.json
     **/
    private fun fetchIconInfo(svgURL: String): HttpRequestResult<String>? {
        return try {
            val responseBytes = HttpRequestHelper.get(svgURL) ?: throw Exception("Failed to fetch icon info")
            HttpRequestResult<String>(String (responseBytes, StandardCharsets.UTF_8))
        } catch (e: Exception) {
            fetchUnavailableIconInfo()
        }
    }

    /**
     * processes the response from the CDN and renders the fluent icon
     **/
    private fun processResponseAndRenderFluentIcon(jsonResponse: JSONObject) {
        try {
            val style = if (isFilledStyle) FILLED_STYLE else REGULAR_STYLE
            val flipInRtl = jsonResponse.optBoolean(FLIP_IN_RTL_PROPERTY, false)
            val styleJsonObject = jsonResponse.getJSONObject(style)
            val availableFluentIconSizes = styleJsonObject.keys().asSequence().map { it.toLong() }.toList()
            val availableIconSizeClosestToGivenSize = Util.getSizeClosestToGivenSize(availableFluentIconSizes, targetIconSize)
            val svgPath = styleJsonObject.getJSONArray(availableIconSizeClosestToGivenSize.toString())[0] as String
            val svgPathString = getSvgString(svgPath, availableIconSizeClosestToGivenSize)
            val drawable = getDrawableFromSVG(svgPathString)
            renderFluentIcon(drawable, flipInRtl)
        } catch (e: Exception) {
            renderFluentIcon(null, false)
        }
    }

    /**
     * fetches the info for the unavailable filled style "Square" icon used as a fallback
     */
    private fun fetchUnavailableIconInfo(): HttpRequestResult<String>? {
        isFilledStyle = true
        val unavailableIconURL = "${AdaptiveCardObjectModel.getBaseIconCDNUrl()}/$SQUARE_ICON/$SQUARE_ICON.json"
        return try {
            val responseBytes = HttpRequestHelper.get(unavailableIconURL)
            HttpRequestResult(String (responseBytes, StandardCharsets.UTF_8))
        } catch (e: Exception) {
            null
        }
    }

    private fun getSvgString(svgPath: String, size: Long): String {
        return "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"$targetIconSize\" height=\"$targetIconSize\" viewBox=\"0 0 $size $size\"> <path d=\"$svgPath\"/></svg>"
    }

    /**
     * creates the svg document from the svg string with the desired icon size
     * for Icon in Action Element, the document width and height are set to the icon size from the host config
     **/
    open fun parseSvgString(context: Context, svgString: String): SVG {
        val svg = SVG.getFromString(svgString)
        svg.documentWidth = Util.dpToPixels(context, targetIconSize.toFloat()).toFloat()
        svg.documentHeight = Util.dpToPixels(context, targetIconSize.toFloat()).toFloat()
        return svg
    }

    private fun getDrawableFromSVG(svgString: String): BitmapDrawable? {
        viewReference.get()?.let {
            val svg = parseSvgString(it.context, svgString)
            val picture = svg.renderToPicture()
            val bitmap = Bitmap.createBitmap(picture.width, picture.height, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            picture.draw(canvas)
            val drawable = BitmapDrawable(it.context.resources, bitmap)
            val color = try {
                Color.parseColor(iconColor)
            } catch (e: IllegalArgumentException) {
                Color.BLACK
            }
            drawable.setColorFilter(color, android.graphics.PorterDuff.Mode.SRC_IN)
            return drawable
        }
        return null
    }

    companion object {
        const val FILLED_STYLE = "filled"
        const val REGULAR_STYLE = "regular"
        const val SQUARE_ICON = "Square"
        const val FLIP_IN_RTL_PROPERTY = "flipInRtl"
    }

}