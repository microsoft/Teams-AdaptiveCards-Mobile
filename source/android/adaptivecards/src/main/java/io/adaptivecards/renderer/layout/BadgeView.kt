package io.adaptivecards.renderer.layout

import android.content.Context
import android.graphics.Color
import android.util.Log
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import io.adaptivecards.R
import io.adaptivecards.objectmodel.Badge
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.IconPosition

class BadgeView: LinearLayout {
    constructor(
        context: Context,
        badge: Badge,
        hostConfig: HostConfig
    ): super(context){
        val leftIconView = ImageView(context)
        val textView = TextView(context)
        val rightIconView = ImageView(context)
        orientation = HORIZONTAL
        addView(leftIconView)
        addView(textView)
        addView(rightIconView)
        textView.text = badge.GetText()
        Log.e("PRPATWA", "text ${badge.GetText()}")
        badge.GetBadgeIcon()?.takeIf { it.isNotBlank() }.let {
            when(badge.GetIconPosition()){
                IconPosition.After -> {
                    leftIconView.visibility = GONE
                    setIconView(rightIconView, badge.GetBadgeIcon());
                }
                else -> {
                    rightIconView.visibility = GONE
                    setIconView(leftIconView, badge.GetBadgeIcon())
                }
            }
        }
        Log.e("PRPATWA", "icon ${badge.GetBadgeIcon()}")
        Log.e("PRPATWA", "icon ${badge.GetBadgeStyle()}")
        setBackgroundColor(Color.RED)
    }

    private fun setIconView(imageView: ImageView, icon: String) {
        imageView.setImageResource(R.drawable.ic_fluent_star_24_filled)
    }

}