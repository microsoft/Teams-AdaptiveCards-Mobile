package io.adaptivecards.renderer.layout

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
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
import io.adaptivecards.objectmodel.HorizontalAlignment
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.IconPosition
import io.adaptivecards.objectmodel.IconStyle
import io.adaptivecards.objectmodel.Shape
import io.adaptivecards.renderer.FluentIconImageLoaderAsync
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.Util

/**
 * View that create badge in this format
 * icon-text-icon
 * from @Badge. At one time only one icon can be visible based on the value of IconPosition
 */
class BadgeView(
    context: Context,
    badge: Badge,
    renderedCard: RenderedAdaptiveCard,
    hostConfig: HostConfig
) : FlexboxLayout(context) {
    init {
        val badgeConfig = badge.getBadgeConfig(hostConfig)
        flexDirection = FlexDirection.ROW
        flexWrap = FlexWrap.NOWRAP
        setPadding(
            badge.getLeftPadding(),
            context.resources.getDimensionPixelOffset(R.dimen.badge_padding_top_bottom),
            badge.getRightPadding(),
            context.resources.getDimensionPixelOffset(R.dimen.badge_padding_top_bottom)
        )
        alignItems = AlignItems.CENTER
        badge.takeIf {
            it.GetBadgeIcon().isNotBlank() && it.GetIconPosition() == IconPosition.Before
        }?.let {
            addIconView(it, badgeConfig, renderedCard)
        }

        //Add TextView if badge has text or
        //if badge has neither text nor icon, add an empty TextView.
        badge.takeIf { it.GetText().isNotBlank() || it.GetBadgeIcon().isBlank() }?.let {
            addTextView(badge.GetText(), badge.GetBadgeSize(), badgeConfig)
        }

        badge.takeIf {
            it.GetBadgeIcon().isNotBlank() && it.GetIconPosition() == IconPosition.After
        }?.let {
            addIconView(it, badgeConfig, renderedCard)
        }

        badge.GetTooltip()?.takeIf { it.isNotBlank() }?.let {
            TooltipCompat.setTooltipText(this@BadgeView, it)
        }

        background = badge.getBackgroundDrawable(badgeConfig)
    }

    private fun addTextView(
        badgeText: String,
        badgeSize: BadgeSize,
        badgeConfig: BadgeAppearanceDefinition
    ) {
        val textView = TextView(context)
        addView(textView)
        textView.apply {
            text = badgeText
            setTextSize(TypedValue.COMPLEX_UNIT_SP, badgeSize.getTextSize())
            setTextColor(Color.parseColor(badgeConfig.textColor))
        }
        textView.setPadding(
            Util.dpToPixels(context, TEXT_PADDING),
            0,
            Util.dpToPixels(context, TEXT_PADDING),
            0
        )
    }

    private fun addIconView(
        badge: Badge,
        badgeConfig: BadgeAppearanceDefinition,
        renderedCard: RenderedAdaptiveCard
    ) {
        val iconView = ImageView(context)
        addView(iconView)
        iconView.loadIcon(badge.GetBadgeIcon(), badge.GetBadgeSize(), badgeConfig, renderedCard)
    }

    private fun ImageView.loadIcon(
        icon: String,
        badgeSize: BadgeSize,
        badgeConfig: BadgeAppearanceDefinition,
        renderedCard: RenderedAdaptiveCard
    ) {
        var iconName = icon
        var isFilled = true
        val iconInfo = icon.takeIf { it.contains(",") }?.split(",")
        if (iconInfo != null && iconInfo.size > 1) {
            iconName = iconInfo[0]
            isFilled = iconInfo[1] == IconStyle.Filled.name
        }
        val svgInfoURL = Util.getSvgInfoUrl(iconName + "/" + iconName + ".json")

        val foregroundColor: String = badgeConfig.textColor

        val iconSize = badgeSize.getIconSize()

        val fluentIconImageLoaderAsync = FluentIconImageLoaderAsync(
            renderedCard,
            iconSize,
            foregroundColor,
            iconSize,
            isFilled,
            this
        )
        fluentIconImageLoaderAsync.execute(svgInfoURL)
    }

    /*
    padding looks like --8dp--[left_icon][--6dp--text--6dp--][right_icon]--8dp--
    left and right padding needs to be 8dp including 6dp of textview padding if icon is not there.
     */
    private fun Badge.getLeftPadding(): Int = this.GetBadgeIcon()?.takeIf { it.isNotBlank() }?.let {
        //If there is left icon Or if there is no text Left padding will be 8dp
        if (this.GetIconPosition() == IconPosition.Before || this.GetText().isNullOrEmpty()) {
            return Util.dpToPixels(context, ICON_PADDING)
        }
        return Util.dpToPixels(context, ICON_PADDING - TEXT_PADDING)
    } ?: Util.dpToPixels(context, ICON_PADDING - TEXT_PADDING)

    private fun Badge.getRightPadding(): Int =
        this.GetBadgeIcon()?.takeIf { it.isNotBlank() }?.let {
            //If there is right icon Or if there is no text Right padding will be 8dp
            if (this.GetIconPosition() == IconPosition.After || this.GetText().isNullOrEmpty()) {
                return Util.dpToPixels(context, ICON_PADDING)
            }
            return Util.dpToPixels(context, ICON_PADDING - TEXT_PADDING)
        } ?: Util.dpToPixels(context, ICON_PADDING - TEXT_PADDING)

    private fun BadgeSize.getTextSize() = when (this) {
        BadgeSize.ExtraLarge -> TEXT_XLARGE
        BadgeSize.Large -> TEXT_LARGE
        else -> TEXT_MEDIUM
    }

    private fun Badge.getBackgroundDrawable(badgeConfig: BadgeAppearanceDefinition): GradientDrawable {
        val gradientDrawable = GradientDrawable()
        val backgroundColor = Color.parseColor(badgeConfig.backgroundColor)
        gradientDrawable.apply {
            colors = intArrayOf(backgroundColor, backgroundColor)
            cornerRadius = Util.dpToPixels(context, getBackgroundCornerRadius()).toFloat()
        }
        if (this.GetBadgeAppearance() == BadgeAppearance.Tint) {
            gradientDrawable.setStroke(
                Util.dpToPixels(context, 1f),
                Color.parseColor(badgeConfig.strokeColor)
            )
        }
        return gradientDrawable
    }

    private fun Badge.getBackgroundCornerRadius() = when (this.GetShape()) {
        Shape.Square -> 0f
        Shape.Rounded -> ROUNDED_RADIUS
        else -> CIRCULAR_RADIUS
    }

    private fun Badge.getBadgeConfig(hostConfig: HostConfig): BadgeAppearanceDefinition {
        val badgePalette = when (this.GetBadgeStyle()) {
            BadgeStyle.Accent -> hostConfig.GetBadgeStyles().accentPalette
            BadgeStyle.Attention -> hostConfig.GetBadgeStyles().attentionPalette
            BadgeStyle.Good -> hostConfig.GetBadgeStyles().goodPalette
            BadgeStyle.Informative -> hostConfig.GetBadgeStyles().informativePalette
            BadgeStyle.Subtle -> hostConfig.GetBadgeStyles().subtlePalette
            BadgeStyle.Warning -> hostConfig.GetBadgeStyles().warningPalette
            else -> hostConfig.GetBadgeStyles().defaultPalette
        }
        return when (this.GetBadgeAppearance()) {
            BadgeAppearance.Filled -> badgePalette.filledStyle
            else -> badgePalette.tintStyle
        }
    }

    fun BadgeSize.getIconSize() = when (this) {
        BadgeSize.Medium, BadgeSize.Large -> ICON_SIZE_M
        else -> ICON_SIZE_XL
    }

    companion object {
        const val ICON_PADDING = 8f
        const val TEXT_PADDING = 6f
        const val TEXT_MEDIUM = 12f
        const val TEXT_LARGE = 14f
        const val TEXT_XLARGE = 16f
        const val CIRCULAR_RADIUS = 15f
        const val ROUNDED_RADIUS = 4f
        const val ICON_SIZE_M = 12L
        const val ICON_SIZE_XL = 16L
    }
}
