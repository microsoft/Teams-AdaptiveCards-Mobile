package io.adaptivecards.renderer.layout

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.util.Log
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.widget.TooltipCompat
import com.google.android.flexbox.AlignItems
import com.google.android.flexbox.FlexDirection
import com.google.android.flexbox.FlexWrap
import com.google.android.flexbox.FlexboxLayout
import com.google.android.flexbox.JustifyContent
import io.adaptivecards.R
import io.adaptivecards.objectmodel.Badge
import io.adaptivecards.objectmodel.BadgeAppearance
import io.adaptivecards.objectmodel.BadgeAppearanceDefinition
import io.adaptivecards.objectmodel.BadgeStyle
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.IconPosition
import io.adaptivecards.objectmodel.IconSize
import io.adaptivecards.objectmodel.IconStyle
import io.adaptivecards.objectmodel.Shape
import io.adaptivecards.renderer.FluentIconImageLoaderAsync
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.Util

class BadgeView: FlexboxLayout {
    constructor(
        context: Context,
        badge: Badge,
        renderedCard: RenderedAdaptiveCard,
        hostConfig: HostConfig
    ): super(context){
        val badgeConfig = getBadgeConfig(hostConfig, badge)
        flexDirection = FlexDirection.ROW
        flexWrap = FlexWrap.NOWRAP
        setPadding(context.resources.getDimensionPixelOffset(R.dimen.badge_padding_start_end),
            context.resources.getDimensionPixelOffset(R.dimen.badge_padding_top_bottom),
            context.resources.getDimensionPixelOffset(R.dimen.badge_padding_start_end),
            context.resources.getDimensionPixelOffset(R.dimen.badge_padding_top_bottom))
        justifyContent = JustifyContent.FLEX_START
        alignItems = AlignItems.CENTER
        val leftIconView = ImageView(context)
        val textView = TextView(context)
        val rightIconView = ImageView(context)

        val leftParams = LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT)
        if(badge.GetText().isNotBlank()){
            leftParams.setMargins(0, 0, context.resources.getDimensionPixelOffset(R.dimen.badge_margin), 0)
        }
        addView(leftIconView, leftParams)

        addView(textView)
        textView.apply {
            text = badge.GetText()
            setTextColor(Color.parseColor(badgeConfig.textColor))
        }

        val rightParams = LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT)
        if(badge.GetText().isNotBlank()){
            rightParams.setMargins(context.resources.getDimensionPixelOffset(R.dimen.badge_margin), 0, 0, 0)
        }
        addView(rightIconView, rightParams)

        Log.e("PRPATWA", "GetBadgeIcon ${badge.GetBadgeIcon()}")
        badge.GetBadgeIcon()?.takeIf { it.isNotBlank() }?.let { icon ->
            when(badge.GetIconPosition()){
                IconPosition.After -> {
                    leftIconView.visibility = GONE
                    setIconView(rightIconView, icon, badgeConfig, renderedCard);
                }
                else -> {
                    rightIconView.visibility = GONE
                    setIconView(leftIconView, icon, badgeConfig, renderedCard)
                }
            }
        }?:run {
            leftIconView.visibility = GONE
            rightIconView.visibility = GONE
        }
        badge.GetTooltip()?.takeIf { it.isNotBlank() }?.apply{
            TooltipCompat.setTooltipText(this@BadgeView, this)
        }
        background = getBackgroundDrawable(badge, badgeConfig)
    }

    private fun getBackgroundDrawable(badge: Badge, badgeConfig: BadgeAppearanceDefinition): GradientDrawable {
        val gradientDrawable = GradientDrawable()
        val backgroundColor = Color.parseColor(badgeConfig.backgroundColor);
        gradientDrawable.apply {
            colors = intArrayOf(backgroundColor, backgroundColor)
            cornerRadius = when(badge.GetShape()) {
                Shape.Circular -> Util.dpToPixels(context, 15f).toFloat()
                Shape.Rounded -> Util.dpToPixels(context, 4f).toFloat()
                else -> 0f
            }
        }
        if(badge.GetBadgeAppearance() == BadgeAppearance.Tint) {
            gradientDrawable.setStroke(
                Util.dpToPixels(context, 1f),
                Color.parseColor(badgeConfig.strokeColor))
        }
        return gradientDrawable
    }

    private fun getBadgeConfig(hostConfig: HostConfig, badge: Badge): BadgeAppearanceDefinition {
        val badgePalette = when(badge.GetBadgeStyle()){
            BadgeStyle.Accent -> hostConfig.GetBadgeStyles().accentPalette
            BadgeStyle.Attention -> hostConfig.GetBadgeStyles().attentionPalette
            BadgeStyle.Good -> hostConfig.GetBadgeStyles().goodPalette
            BadgeStyle.Informative -> hostConfig.GetBadgeStyles().informativePalette
            BadgeStyle.Subtle -> hostConfig.GetBadgeStyles().subtlePalette
            BadgeStyle.Warning -> hostConfig.GetBadgeStyles().warningPalette
            else -> hostConfig.GetBadgeStyles().defaultPalette
        }
        return when(badge.GetBadgeAppearance()){
            BadgeAppearance.Filled->badgePalette.filledStyle
            else->badgePalette.tintStyle
        }
    }

    private fun setIconView(imageView: ImageView, icon: String, badgeConfig: BadgeAppearanceDefinition, renderedCard: RenderedAdaptiveCard) {
        var iconName = icon
        var isFilled = true
        val iconInfo = icon.takeIf { it.contains(",") }?.split(",")
        if(iconInfo!=null && iconInfo.size>1){
            iconName = iconInfo[0]
            isFilled = iconInfo[1] == IconStyle.Filled.name
        }
        val svgInfoURL = Util.getSvgInfoUrl(iconName+"/"+iconName+".json")

        val foregroundColorIcon: String = badgeConfig.textColor
        Log.e("PRPATWA", "foregroundColorIcon : $foregroundColorIcon")
        val fluentIconImageLoaderAsync = FluentIconImageLoaderAsync(
            renderedCard,
            Util.getFluentIconSize(IconSize.xxSmall),
            foregroundColorIcon,
            isFilled,
            imageView
        )
        Log.e("PRPATWA", svgInfoURL)
        fluentIconImageLoaderAsync.execute(svgInfoURL)
    }
}