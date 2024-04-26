package io.adaptivecards.renderer

import android.content.Context
import android.graphics.drawable.Drawable
import android.graphics.drawable.PictureDrawable
import android.os.AsyncTask
import android.util.Log
import android.view.View
import android.widget.ImageView
import com.caverock.androidsvg.SVG
import io.adaptivecards.renderer.http.HttpRequestHelper
import io.adaptivecards.renderer.http.HttpRequestResult
import org.json.JSONObject
import java.lang.ref.WeakReference
import java.nio.charset.StandardCharsets

open class FluentIconImageLoaderAsync(
    val renderedCard: RenderedAdaptiveCard,
    val iconSize: Long,
    val foregroundColor: String,
    view: View
) : AsyncTask<String, Void, HttpRequestResult<String>>() {

    val viewReference: WeakReference<View> = WeakReference(view)
    override fun doInBackground(vararg args: String): HttpRequestResult<String>? {
        return if (args.isEmpty()) {
            null
        } else {
            try {
                val responseBytes = HttpRequestHelper.get(args[0])
                HttpRequestResult<String>(String (responseBytes, StandardCharsets.UTF_8))
            } catch (e: Exception) {
                Log.e("Manpreet", "Error fetching icon svg path from url ${args[0]}")
                null
            }
        }
    }

    override fun onPostExecute(result: HttpRequestResult<String>?) {
        val view = viewReference.get()
        if (view != null) {
            if (result?.isSuccessful == true) {
                val jsonResponse = JSONObject(result.result)
                try {
                    val svgPath = jsonResponse.getJSONArray("svgPaths")
                    val svgStringBuilder = StringBuilder("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 $iconSize $iconSize\"> <path d=\"${svgPath[0]}\"/></svg>")
                    Log.d("Manpreet", svgStringBuilder.toString())
                    val drawable = loadSVGIntoImageView(svgStringBuilder.toString(), view.context)
                    renderFluentIcon(drawable)
                } catch (e: Exception) {
                    Log.e("Manpreet", "Json exception or error parsing svg string ${e.message}")
                    // Todo: render "Unavailable" fallback icon
                }
            } else {
                // Todo: render "Unavailable" fallback icon
            }
        }
    }

    open fun renderFluentIcon(drawable: Drawable?) {
        val view = viewReference.get()
        if (view != null && view is ImageView) {
            view.setImageDrawable(drawable)
        }
    }

    private fun loadSVGIntoImageView(svgString: String, context: Context): Drawable {
        val svg = SVG.getFromString(svgString)
        svg.documentWidth = Util.dpToPixels(context, iconSize.toFloat()).toFloat()
        svg.documentHeight = Util.dpToPixels(context, iconSize.toFloat()).toFloat()
        return PictureDrawable(svg.renderToPicture())
    }

}