package io.adaptivecards.renderer

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.Drawable
import android.os.AsyncTask
import android.widget.Button
import io.adaptivecards.objectmodel.BaseActionElement

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
        callback: (drawable: Drawable?) -> Unit
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
            svgPath?.let {
                val isFilledStyle = iconUrl.contains("filled")
                val svgInfoURL = Util.getSvgInfoUrl(it)
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
            } ?: run {
                callback(null)
            }
        }
    }

    @JvmStatic
    fun Button.applyIconColor(iconColor : Int? = null) {
        val color = iconColor ?: currentTextColor
        getHexColor(color).apply {
            compoundDrawables[0]?.applyIconColor(this)
            compoundDrawables[1]?.applyIconColor(this)
            compoundDrawables[2]?.applyIconColor(this)
            compoundDrawables[3]?.applyIconColor(this)
        }
    }

    @JvmStatic
    fun Drawable.applyIconColor(hexIconColor: String, defaultHexIconColor : Int = Color.BLACK) {
        val color = try {
            Color.parseColor(hexIconColor)
        } catch (e: IllegalArgumentException) {
            defaultHexIconColor
        }
        this.setColorFilter(color, android.graphics.PorterDuff.Mode.SRC_IN)
    }

    @JvmStatic
    fun getHexColor(currentTextColor: Int) : String {
        return String.format("#%06X", 0xFFFFFF and currentTextColor)
    }

    @JvmStatic
    fun getSvgPathForIconUrl(iconUrl: String) : String {
        return BaseActionElement.GetSVGPathForIconUrl(iconUrl)
    }
}
