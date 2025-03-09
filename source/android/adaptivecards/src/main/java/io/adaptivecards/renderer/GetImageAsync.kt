package io.adaptivecards.renderer

import android.content.Context
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import io.adaptivecards.renderer.http.HttpRequestResult

class GetImageAsync (
    imageBaseUrl: String?,
    context: Context,
    maxWidth: Int = -1,
    callback: (drawable: Drawable?) -> Void
) : GenericImageLoaderAsync(null, imageBaseUrl, maxWidth) {
    protected var context: Context
    protected var callback: (drawable: Drawable?) -> Void

    init {
        this.context = context
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
}