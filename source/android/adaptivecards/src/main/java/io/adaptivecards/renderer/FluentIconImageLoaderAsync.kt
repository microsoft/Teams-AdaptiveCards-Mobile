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
    val iconSize: Long,
    private val iconColor: String,
    view: View
) : AsyncTask<String, Void, HttpRequestResult<String>>() {

    val viewReference: WeakReference<View> = WeakReference(view)
    override fun doInBackground(vararg args: String): HttpRequestResult<String>? {
        return if (args.isEmpty()) {
            null
        } else {
            fetchIcon(args[0])
        }
    }

    override fun onPostExecute(result: HttpRequestResult<String>?) {
        val view = viewReference.get()
        if (view != null) {
            if (result?.isSuccessful == true) {
                val jsonResponse = JSONObject(result.result)
                try {
                    val svgPath = jsonResponse.getJSONArray("svgPaths")
                    val flipInRtl = jsonResponse.optBoolean("flipInRtl", false)
                    val svgString = getSvgString(svgPath[0] as String)
                    val drawable = getDrawableFromSVG(svgString, view.context)
                    renderFluentIcon(drawable, flipInRtl)
                } catch (e: Exception) {
                    renderFluentIcon(null, false)
                }
            }
        }
    }

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
     * If the provided icon url is invalid, fetch fallback unavailable icon
     **/
    private fun fetchIcon(svgURL: String): HttpRequestResult<String>? {
        return try {
            val responseBytes = HttpRequestHelper.get(svgURL)
            HttpRequestResult<String>(String (responseBytes, StandardCharsets.UTF_8))
        } catch (e: Exception) {
            val unavailableIconURL = "${AdaptiveCardObjectModel.getBaseIconCDNUrl()}/Square/Square${iconSize}Filled.json"
            try {
                val responseBytes = HttpRequestHelper.get(unavailableIconURL)
                HttpRequestResult(String (responseBytes, StandardCharsets.UTF_8))
            } catch (e: Exception) {
                null
            }
        }
    }

    private fun getSvgString(svgPath: String): String {
        return "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"$iconSize\" height=\"$iconSize\" viewBox=\"0 0 $iconSize $iconSize\"> <path d=\"$svgPath\"/></svg>"
    }

    /**
     * creates the svg document from the svg string with the desired icon size
     * for Icon in Action Element, the document width and height are set to the icon size from the host config
     **/
    open fun parseSvgString(context: Context, svgString: String): SVG {
        val svg = SVG.getFromString(svgString)
        svg.documentWidth = Util.dpToPixels(context, iconSize.toFloat()).toFloat()
        svg.documentHeight = Util.dpToPixels(context, iconSize.toFloat()).toFloat()
        return svg
    }

    private fun getDrawableFromSVG(svgString: String, context: Context): BitmapDrawable {
        val svg = parseSvgString(context, svgString)
        val picture = svg.renderToPicture()
        var bitmap = Bitmap.createBitmap(picture.width, picture.height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        picture.draw(canvas)
        var drawable = BitmapDrawable(context.resources, bitmap)
        val color = Color.parseColor(iconColor)
        drawable.setColorFilter(color, android.graphics.PorterDuff.Mode.SRC_IN)
        return drawable
    }

}