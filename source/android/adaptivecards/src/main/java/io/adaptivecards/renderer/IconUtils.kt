package io.adaptivecards.renderer

import android.content.Context
import android.graphics.drawable.Drawable
import android.os.AsyncTask
import io.adaptivecards.objectmodel.HostConfig

object IconUtils {
    /**
     * Pass iconUrl and other params, it returns the icon drawable either from public url or fluent icon drawable
     * @param iconUrl The url of the icon, can be any public url or fluent icon
     * @param svgPath svgPath of Fluent icon
     * @param iconHexColor hexColor of Fluent icon
     * @param isRTL if layout is RTL or not
     * @param iconSize size of downloaded icon or fluent icon
     * @param callback if successful then called with drawable, else called with null
     */
    fun getIcon(
        context: Context,
        iconUrl: String,
        svgPath: String?,
        iconHexColor: String?,
        isRTL: Boolean,
        iconSize: Long,
        callback: (drawable: Drawable?) -> Void
    ) {
        if (!iconUrl.startsWith(Util.FLUENT_ICON_URL_PREFIX)) {
            val getImage = GetImageAsync(
                iconUrl,
                context,
                maxWidth = -1,
                iconSize,
                callback
            )
            getImage.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, iconUrl)
        } else {
            val isFilledStyle = iconUrl.contains("filled")
            val svgInfoURL = Util.getSvgInfoUrl(svgPath)
            AsyncTask.execute {
                FluentIconUtils.getFluentIcon(
                    context,
                    svgInfoURL,
                    iconHexColor ?: "#FFFFFF",
                    iconSize,
                    isFilledStyle,
                    isRTL
                ) { drawable: Drawable? ->
                    callback(drawable)
                }
            }
        }
    }
}
