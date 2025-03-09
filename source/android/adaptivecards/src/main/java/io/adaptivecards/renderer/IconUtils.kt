package io.adaptivecards.renderer

import android.content.Context
import android.graphics.drawable.Drawable
import android.os.AsyncTask
import io.adaptivecards.objectmodel.HostConfig

object IconUtils {
    private const val FILLED_STYLE = "filled"
    private const val REGULAR_STYLE = "regular"
    private const val FLIP_IN_RTL_PROPERTY = "flipInRtl"
    private const val FLUENT_ICON_URL_PREFIX: String = "icon:"

    fun getIcon(
        context: Context,
        iconUrl: String,
        svgPath: String?,
        isRTL: Boolean,
        hostConfig: HostConfig,
        callback: (drawable: Drawable?) -> Void
    ) {
        if (!iconUrl.startsWith(FLUENT_ICON_URL_PREFIX)) {
            val getImage = GetImageAsync(
                iconUrl,
                context,
                hostConfig.GetActions().getIconSize().toInt(),
                callback
            )
            getImage.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, iconUrl)
        } else {
            // intentionally kept this 24 so that it always loads
            // irrespective of size given in host config.
            // it is possible that host config has some size which is not available in CDN.
//            val fluentIconSize: Long = 24
            val hexColor = "3498F3"
            val isFilledStyle = iconUrl.contains("filled")
            val svgInfoURL = Util.getSvgInfoUrl(svgPath)
            AsyncTask.execute {
                FluentIconUtils.getFluentIcon(
                    context,
                    svgInfoURL,
                    hexColor,
                    hostConfig.GetActions().getIconSize(),
                    isFilledStyle,
                    hostConfig.GetActions().getIconSize(),
                    isRTL
                ) { drawable: Drawable? ->
                    callback(drawable)
                }
            }
        }
    }
}
