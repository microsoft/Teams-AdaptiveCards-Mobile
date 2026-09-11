package io.adaptivecards.renderer.readonly

import android.content.Context
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentManager
import com.google.android.material.progressindicator.CircularProgressIndicator
import io.adaptivecards.R
import io.adaptivecards.objectmodel.BaseCardElement
import io.adaptivecards.objectmodel.HorizontalAlignment
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.ProgressRing
import io.adaptivecards.objectmodel.ProgressSize
import io.adaptivecards.renderer.BaseCardElementRenderer
import io.adaptivecards.renderer.RenderArgs
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.TagContent
import io.adaptivecards.renderer.Util
import io.adaptivecards.renderer.actionhandler.ICardActionHandler
import io.adaptivecards.renderer.layout.BadgeView

/**
 * Renderer for ProgressRing Element
 */
object ProgressRingRenderer : BaseCardElementRenderer() {

    override fun render(
        renderedCard: RenderedAdaptiveCard, context: Context, fragmentManager: FragmentManager, viewGroup: ViewGroup,
        baseCardElement: BaseCardElement, cardActionHandler: ICardActionHandler?, hostConfig: HostConfig,
        renderArgs: RenderArgs): View? {

        val linearLayout = LinearLayout(context).apply {
            layoutParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT)
        }
        linearLayout.setBackgroundColor(ContextCompat.getColor(context, R.color.design_default_color_error))

        val progressRing = Util.castTo(baseCardElement, ProgressRing::class.java)
        val size = progressRing.GetSize()
        val label = progressRing.GetLabel()
        val position = progressRing.GetLabelPosition()
        val horizontalAlignment = progressRing.GetHorizontalAlignment()

        Log.d("ProgressRingRenderer", "Label: $label, Position: $position Size: $size horizontalAlignment: ${progressRing.GetHorizontalAlignment()}")

        val layoutParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT,  LinearLayout.LayoutParams.WRAP_CONTENT)
        layoutParams.gravity = when (horizontalAlignment) {
            HorizontalAlignment.Right -> Gravity.END
            HorizontalAlignment.Center -> Gravity.CENTER
            else -> Gravity.START
        }

        val indicator = CircularProgressIndicator(context).apply {
            tag = TagContent(progressRing)
            isIndeterminate = true
            indicatorSize = when(size) {
                ProgressSize.Tiny -> Util.dpToPixels(context, 16f).toInt()
                ProgressSize.Small -> Util.dpToPixels(context, 24f).toInt()
                ProgressSize.Medium -> Util.dpToPixels(context, 32f).toInt()
                ProgressSize.Large -> Util.dpToPixels(context, 40f).toInt()
            }
        }
        indicator.layoutParams = layoutParams
        linearLayout.addView(indicator)
        viewGroup.addView(linearLayout)
        return indicator
    }
}