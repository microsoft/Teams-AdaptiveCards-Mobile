package io.adaptivecards.renderer

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import com.caverock.androidsvg.SVG
import io.adaptivecards.renderer.http.HttpRequestHelper
import io.adaptivecards.renderer.http.HttpRequestResult
import org.json.JSONObject
import java.nio.charset.StandardCharsets

object IconUtils {
    private const val FILLED_STYLE = "filled"
    private const val REGULAR_STYLE = "regular"
    private const val FLIP_IN_RTL_PROPERTY = "flipInRtl"

    fun loadIcon(
        context: Context,
        svgURL: String,
        iconColor: String,
        targetIconSize: Long,
        isFilledStyle: Boolean,
        iconSize: Long
    ) : IconResponse {
        val requestResult = fetchIconInfo(svgURL)
        return processResponseAndRenderFluentIcon(requestResult, context, iconColor, targetIconSize, isFilledStyle, iconSize)
    }

    /**
     * fetches the icon info from the CDN
     * if the request fails or response is null, fetches the info for the unavailable "Square" icon as a fallback
     * sample url: https://res-1.cdn.office.net/assets/fluentui-react-icons/2.0.226/AlbumAdd/AlbumAdd.json
     **/
    internal fun fetchIconInfo(svgURL: String): HttpRequestResult<String>? {
        return try {
            val responseBytes = HttpRequestHelper.get(svgURL) ?: throw Exception("Failed to fetch icon info")
            HttpRequestResult<String>(String (responseBytes, StandardCharsets.UTF_8))
        } catch (e: Exception) {
            fetchUnavailableIconInfo()
        }
    }

    /**
     * fetches the info for the unavailable filled style "Square" icon used as a fallback
     */
    private fun fetchUnavailableIconInfo(): HttpRequestResult<String>? {
        // Todo
        // isFilledStyle = true
        val unavailableIconURL = Util.getUnavailableIconSvgInfoUrl()
        return try {
            val responseBytes = HttpRequestHelper.get(unavailableIconURL)
            HttpRequestResult(String (responseBytes, StandardCharsets.UTF_8))
        } catch (e: Exception) {
            null
        }
    }

    /**
     * processes the response from the CDN and renders the fluent icon
     **/
    internal fun processResponseAndRenderFluentIcon(
        result: HttpRequestResult<String>?,
        context: Context?,
        iconColor: String,
        targetIconSize: Long,
        isFilledStyle: Boolean,
        iconSize: Long
    ) :IconResponse {
        if (context != null && result?.isSuccessful == true && result.result.isNotEmpty()) {
            val response = result.result
            try {
                val responseJsonObject = JSONObject(response)
                val style = if (isFilledStyle) FILLED_STYLE else REGULAR_STYLE
                val flipInRtl = responseJsonObject.optBoolean(FLIP_IN_RTL_PROPERTY, false)
                val styleJsonObject = responseJsonObject.getJSONObject(style)
                val availableFluentIconSizes = styleJsonObject.keys().asSequence().map { it.toLong() }.toList()
                val availableIconSizeClosestToGivenSize = Util.getSizeClosestToGivenSize(availableFluentIconSizes, targetIconSize)
                val svgPath = styleJsonObject.getJSONArray(availableIconSizeClosestToGivenSize.toString())[0] as String
                val svgPathString = getSvgString(svgPath, availableIconSizeClosestToGivenSize, targetIconSize)
                val drawable = getDrawableFromSVG(context, svgPathString, iconColor, iconSize)
                return IconResponse(drawable, flipInRtl)
            } catch (_: Exception) {
            }
        }
        return IconResponse(null, false)
    }

    private fun getSvgString(svgPath: String, size: Long, targetIconSize: Long): String {
        return "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"$targetIconSize\" height=\"$targetIconSize\" viewBox=\"0 0 $size $size\"> <path d=\"$svgPath\"/></svg>"
    }

    private fun getDrawableFromSVG(context: Context, svgString: String, iconColor: String, iconSize: Long): BitmapDrawable {
        val svg = parseSvgString(context, svgString, iconSize)
        val picture = svg.renderToPicture()
        val bitmap = Bitmap.createBitmap(picture.width, picture.height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        picture.draw(canvas)
        val drawable = BitmapDrawable(context.resources, bitmap)
        val color = try {
            Color.parseColor(iconColor)
        } catch (e: IllegalArgumentException) {
            Color.BLACK
        }
        drawable.setColorFilter(color, android.graphics.PorterDuff.Mode.SRC_IN)
        return drawable
    }

    /**
     * creates the svg document from the svg string with the desired icon size
     * for Icon in Action Element, the document width and height are set to the icon size from the host config
     **/
    private fun parseSvgString(context: Context, svgString: String, iconSize: Long): SVG {
        val svg = SVG.getFromString(svgString)
        svg.documentWidth = Util.dpToPixels(context, iconSize.toFloat()).toFloat()
        svg.documentHeight = Util.dpToPixels(context, iconSize.toFloat()).toFloat()
        return svg
    }

    data class IconResponse(val drawable: Drawable?, val flipInRtl: Boolean)
}
