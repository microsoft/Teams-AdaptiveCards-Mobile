package io.adaptivecards.renderer

import android.content.Context
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.widget.Button
import io.adaptivecards.renderer.http.HttpRequestResult

class GetImageAsync (
    imageBaseUrl: String?,
    context: Context,
    maxWidth: Int = -1,
    iconSize: Long,
    callback: (drawable: Drawable?) -> Unit
) : GenericImageLoaderAsync(null, imageBaseUrl, maxWidth) {
    protected var context: Context
    protected var iconSize: Long
    protected var callback: (drawable: Drawable?) -> Unit

    init {
        this.context = context
        this.iconSize = iconSize
        this.callback = callback
    }

    override fun doInBackground(vararg args: String): HttpRequestResult<Bitmap>? {
        if (args.size == 0) {
            return null
        }
        return loadImage(args[0], context)
    }

    public override fun onSuccessfulPostExecute(bitmap: Bitmap) {
        val drawableIcon: Drawable = BitmapDrawable(null, bitmap)
        callback(drawableIcon)
    }

    override fun styleBitmap(bitmap: Bitmap?): Bitmap {
        val imageHeight = Util.dpToPixels(context, iconSize.toFloat()).toFloat()
        return Util.scaleBitmapToHeight(imageHeight, bitmap)
    }
}