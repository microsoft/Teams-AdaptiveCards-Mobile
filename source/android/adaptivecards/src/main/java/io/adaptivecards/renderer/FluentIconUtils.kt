package io.adaptivecards.renderer

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Matrix
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import androidx.annotation.WorkerThread
import com.caverock.androidsvg.SVG
import io.adaptivecards.renderer.http.HttpRequestHelper
import io.adaptivecards.renderer.http.HttpRequestResult
import org.json.JSONObject
import java.nio.charset.StandardCharsets

object FluentIconUtils {
    private const val FILLED_STYLE = "filled"
    private const val REGULAR_STYLE = "regular"
    private const val FLIP_IN_RTL_PROPERTY = "flipInRtl"

    @WorkerThread
    fun getFluentIcon(
        context: Context,
        svgURL: String,
        iconColor: String,
        targetIconSize: Long,
        isFilledStyle: Boolean,
        isRTL: Boolean,
        callback: (drawable: Drawable?) -> Unit
    ) {
        val requestResult = fetchIconInfo(svgURL)
        val iconResponse = processResponseAndGetIconDrawable(requestResult, context, iconColor, targetIconSize, isFilledStyle)
        iconResponse.drawable?.let {
            callback(if (isRTL && iconResponse.flipInRtl) flipDrawableHorizontally(it, context) else it)
        }
    }

    /**
     * fetches the icon info from the CDN
     * if the request fails or response is null, returns null
     * sample url: https://res-1.cdn.office.net/assets/fluentui-react-icons/2.0.226/AlbumAdd/AlbumAdd.json
     **/
    internal fun fetchIconInfo(svgURL: String): HttpRequestResult<String>? {
        return try {
            val responseBytes = HttpRequestHelper.get(svgURL) ?: throw Exception("Failed to fetch icon info")
            HttpRequestResult<String>(String (responseBytes, StandardCharsets.UTF_8))
        } catch (e: Exception) {
            null
        }
    }

    /**
     * processes the response from the CDN and returns icon drawable
     **/
    internal fun processResponseAndGetIconDrawable(
        result: HttpRequestResult<String>?,
        context: Context?,
        iconColor: String,
        targetIconSize: Long,
        isFilledStyle: Boolean
    ) :IconResponse {
        if (context != null && result?.isSuccessful == true && result.result.isNotEmpty()) {
            val response = result.result
            try {
                val responseJsonObject = JSONObject(response)
                val style = if (isFilledStyle) FILLED_STYLE else REGULAR_STYLE
                val flipInRtl = responseJsonObject.optBoolean(FLIP_IN_RTL_PROPERTY, true)
                val styleJsonObject = responseJsonObject.getJSONObject(style)
                val availableFluentIconSizes = styleJsonObject.keys().asSequence().map { it.toLong() }.toList()
                val availableIconSizeClosestToGivenSize = Util.getSizeClosestToGivenSize(availableFluentIconSizes, targetIconSize)
                val svgPath = styleJsonObject.getJSONArray(availableIconSizeClosestToGivenSize.toString())[0] as String
                val svgPathString = getSvgString(svgPath, availableIconSizeClosestToGivenSize, targetIconSize)
                val drawable = getDrawableFromSVG(context, svgPathString, iconColor, targetIconSize)
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

    /**
     * flips the drawable horizontally if the card is RTL and the flipInRtl property is true for the rendered svg
     **/
    @JvmStatic
    fun flipDrawableHorizontally(drawable: Drawable, context: Context): Drawable {
        val bitmap = Bitmap.createBitmap(drawable.intrinsicWidth, drawable.intrinsicHeight, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)

        val matrix = Matrix()
        matrix.preScale(-1f, 1f)
        val flippedBitmap = Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)

        return BitmapDrawable(context.resources, flippedBitmap)
    }

    data class IconResponse(val drawable: Drawable?, val flipInRtl: Boolean)
}
