package io.adaptivecards.renderer

import android.content.Context
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import io.adaptivecards.renderer.http.HttpRequestResult
import java.lang.ref.WeakReference

class GetImageAsync (
    imageBaseUrl: String?,
    context: Context,
    maxWidth: Int = -1,
    iconSize: Long,
    callback: (drawable: Drawable?) -> Unit
) : GenericImageLoaderAsync(null, imageBaseUrl, maxWidth) {
    private val context: WeakReference<Context>
    private val iconSize: Long
    private val callback: (drawable: Drawable?) -> Unit

    init {
        this.context = WeakReference(context)
        this.iconSize = iconSize
        this.callback = callback
    }

    override fun doInBackground(vararg args: String): HttpRequestResult<Bitmap>? {
        val context = context.get()
        if (args.isEmpty() || context == null) {
            return null
        }
        return loadImage(args[0], context)
    }

    public override fun onSuccessfulPostExecute(bitmap: Bitmap) {
        val drawableIcon: Drawable = BitmapDrawable(null, bitmap)
        callback(drawableIcon)
    }

    override fun styleBitmap(bitmap: Bitmap?): Bitmap? {
        val context = context.get()
        if (context != null) {
            val imageSizeInPixel = Util.dpToPixels(context, iconSize.toFloat()).toFloat()
            return Util.scaleBitmapToSize(imageSizeInPixel, bitmap)
        }
        return bitmap
    }
}
