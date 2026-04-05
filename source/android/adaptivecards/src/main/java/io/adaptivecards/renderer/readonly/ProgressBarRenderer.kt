package io.adaptivecards.renderer.readonly

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.ProgressBar as AndroidProgressBar
import android.widget.TextView
import androidx.core.view.ViewCompat
import androidx.core.view.accessibility.AccessibilityNodeInfoCompat
import androidx.core.view.AccessibilityDelegateCompat
import androidx.fragment.app.FragmentManager
import io.adaptivecards.objectmodel.BaseCardElement
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.ProgressBar
import io.adaptivecards.renderer.BaseCardElementRenderer
import io.adaptivecards.renderer.RenderArgs
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.TagContent
import io.adaptivecards.renderer.actionhandler.ICardActionHandler

/**
 * Renderer for ProgressBar Element
 */
object ProgressBarRenderer : BaseCardElementRenderer() {

    override fun render(
        renderedCard: RenderedAdaptiveCard, context: Context, fragmentManager: FragmentManager, viewGroup: ViewGroup,
        baseCardElement: BaseCardElement, cardActionHandler: ICardActionHandler?, hostConfig: HostConfig,
        renderArgs: RenderArgs): View? {

        val progressBar = ProgressBar.dynamic_cast(baseCardElement) ?: return null

        val max = progressBar.GetMax()
        val value = progressBar.GetValue()
        val isIndeterminate = (value == null)

        val progressView = AndroidProgressBar(context, null, android.R.attr.progressBarStyleHorizontal).apply {
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            this.max = max.toInt()
            if (!isIndeterminate) {
                progress = value!!.toInt()
                isIndeterminate = false
            } else {
                this.isIndeterminate = true
            }
        }

        // Fix: Set accessible role and value info for TalkBack (#451)
        val contentDesc = if (isIndeterminate) {
            "Progress bar, loading"
        } else {
            val percent = if (max > 0) ((value!! / max) * 100).toInt() else 0
            "Progress bar, $percent percent"
        }
        progressView.contentDescription = contentDesc

        ViewCompat.setAccessibilityDelegate(progressView, object : AccessibilityDelegateCompat() {
            override fun onInitializeAccessibilityNodeInfo(host: View, info: AccessibilityNodeInfoCompat) {
                super.onInitializeAccessibilityNodeInfo(host, info)
                info.roleDescription = "Progress Bar"
                if (!isIndeterminate) {
                    info.rangeInfo = AccessibilityNodeInfoCompat.RangeInfoCompat.obtain(
                        AccessibilityNodeInfoCompat.RangeInfoCompat.RANGE_TYPE_PERCENT,
                        0f,
                        max.toFloat(),
                        value!!.toFloat()
                    )
                }
            }
        })

        progressView.tag = TagContent(progressBar)
        viewGroup.addView(progressView)

        return progressView
    }
}
