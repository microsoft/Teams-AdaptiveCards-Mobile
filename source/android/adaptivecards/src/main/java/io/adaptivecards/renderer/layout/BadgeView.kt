package io.adaptivecards.renderer.layout

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.util.Log
import android.util.TypedValue
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
import io.adaptivecards.objectmodel.BadgeSize
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
        setPadding(getBadgeLeftPadding(badge),
            context.resources.getDimensionPixelOffset(R.dimen.badge_padding_top_bottom),
            getBadgeRightPadding(badge),
            context.resources.getDimensionPixelOffset(R.dimen.badge_padding_top_bottom))
        justifyContent = JustifyContent.FLEX_START
        alignItems = AlignItems.CENTER
        val leftIconView = ImageView(context)
        addView(leftIconView)

        badge.GetText()?.takeIf { it.isNotBlank() }?.apply {
            val textView = TextView(context)
            addView(textView)
            textView.apply {
                text = badge.GetText()
                setTextSize(TypedValue.COMPLEX_UNIT_SP, getBadgeTextSize(badge.GetBadgeSize()))
                setTextColor(Color.parseColor(badgeConfig.textColor))
            }
            textView.setPadding(Util.dpToPixels(context, 6f), 0, Util.dpToPixels(context, 6f), 0)
        }

        val rightIconView = ImageView(context)
        addView(rightIconView)

        Log.e("PRPATWA", "GetBadgeIcon ${badge.GetBadgeIcon()}")
        badge.GetBadgeIcon()?.takeIf { it.isNotBlank() }?.let { icon ->
            when(badge.GetIconPosition()){
                IconPosition.After -> {
                    leftIconView.visibility = GONE
                    setIconView(rightIconView, icon, badge.GetBadgeSize(), badgeConfig, renderedCard);
                }
                else -> {
                    rightIconView.visibility = GONE
                    setIconView(leftIconView, icon, badge.GetBadgeSize(), badgeConfig, renderedCard)
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

    private fun getBadgeLeftPadding(badge: Badge): Int =  badge.GetBadgeIcon()?.takeIf { it.isNotBlank() }?.let {
            if(badge.GetIconPosition() == IconPosition.Before || badge.GetText().isNullOrEmpty()) {
                return Util.dpToPixels(context, 8f)
            }
            return Util.dpToPixels(context, 2f)
        }?:Util.dpToPixels(context, 2f)

    private fun getBadgeRightPadding(badge: Badge): Int = badge.GetBadgeIcon()?.takeIf { it.isNotBlank() }?.let {
        if(badge.GetIconPosition() == IconPosition.After || badge.GetText().isNullOrEmpty()) {
            return Util.dpToPixels(context, 8f)
        }
        return Util.dpToPixels(context, 2f)
        }?:Util.dpToPixels(context, 2f)

    private fun getBadgeTextSize(badgeSize: BadgeSize) = when(badgeSize){
        BadgeSize.Medium -> 12f
        BadgeSize.Large -> 14f
        else -> 16f
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

    private fun setIconView(imageView: ImageView, icon: String, badgeSize: BadgeSize, badgeConfig: BadgeAppearanceDefinition, renderedCard: RenderedAdaptiveCard) {
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
        val iconSize = when(badgeSize){
            BadgeSize.Medium, BadgeSize.Large -> 12
            else -> Util.getFluentIconSize(IconSize.xxSmall)
        }
        val fluentIconImageLoaderAsync = FluentIconImageLoaderAsync(
            renderedCard,
            iconSize,
            foregroundColorIcon,
            isFilled,
            imageView
        )
        Log.e("PRPATWA", svgInfoURL)
        fluentIconImageLoaderAsync.execute(svgInfoURL)
    }
}