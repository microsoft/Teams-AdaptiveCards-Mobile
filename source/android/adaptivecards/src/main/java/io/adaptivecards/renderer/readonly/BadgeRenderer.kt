package io.adaptivecards.renderer.readonly

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import androidx.fragment.app.FragmentManager
import com.google.android.flexbox.FlexboxLayout
import io.adaptivecards.objectmodel.Badge
import io.adaptivecards.objectmodel.BaseCardElement
import io.adaptivecards.objectmodel.CardElementType
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.RatingLabel
import io.adaptivecards.objectmodel.Shape
import io.adaptivecards.renderer.BaseCardElementRenderer
import io.adaptivecards.renderer.RenderArgs
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.TagContent
import io.adaptivecards.renderer.Util
import io.adaptivecards.renderer.ViewUtils.applyCircularBackground
import io.adaptivecards.renderer.ViewUtils.applyRoundedCorners
import io.adaptivecards.renderer.actionhandler.ICardActionHandler
import io.adaptivecards.renderer.layout.BadgeView
import io.adaptivecards.renderer.layout.RatingStarDisplayView

object BadgeRenderer: BaseCardElementRenderer() {
    override fun render(
        renderedCard: RenderedAdaptiveCard,
        context: Context,
        fragmentManager: FragmentManager,
        viewGroup: ViewGroup,
        baseCardElement: BaseCardElement,
        cardActionHandler: ICardActionHandler?,
        hostConfig: HostConfig,
        renderArgs: RenderArgs
    ): View {
        val badge = Util.castTo(baseCardElement, Badge::class.java)
        val badgeView = BadgeView(context, badge, renderedCard, hostConfig)
        badgeView.tag = TagContent(badge)
        badgeView.layoutParams = FlexboxLayout.LayoutParams(FlexboxLayout.LayoutParams.WRAP_CONTENT, FlexboxLayout.LayoutParams.WRAP_CONTENT)

        Log.e("PRPATWA",  "background ${badgeView.background is GradientDrawable}")
//        val drawable = GradientDrawable()
//        drawable.setColor(Color.parseColor(badge.))
//        badgeView.background =

//        when(badge.GetShape()){
//            Shape.Rounded->ContainerRenderer.applyRoundedCorners(badgeView
//                    ,hostConfig, CardElementType.Badge, true)
////            Shape.Circular->badgeView.applyCircularBackground(hostConfig, CardElementType.Badge)
//        }
        viewGroup.addView(badgeView)
        return badgeView
    }
}