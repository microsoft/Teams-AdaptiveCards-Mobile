// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.readonly

import android.content.Context
import android.os.AsyncTask
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.LinearLayout
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.constraintlayout.widget.ConstraintSet
import androidx.fragment.app.FragmentManager
import io.adaptivecards.R
import io.adaptivecards.objectmodel.BaseCardElement
import io.adaptivecards.objectmodel.ContainerStyle
import io.adaptivecards.objectmodel.HeightType
import io.adaptivecards.objectmodel.HorizontalAlignment
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.Icon
import io.adaptivecards.renderer.BaseCardElementRenderer
import io.adaptivecards.renderer.FluentIconImageLoaderAsync
import io.adaptivecards.renderer.RenderArgs
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.TagContent
import io.adaptivecards.renderer.Util
import io.adaptivecards.renderer.actionhandler.ICardActionHandler

/**
 * Renderer for fluent icon elements
 **/
object FluentIconsRenderer : BaseCardElementRenderer() {

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
        val icon = Util.castTo(baseCardElement, Icon::class.java)
        val view = ImageView(context)
        val svgURL = icon.GetSVGResourceURL()
        val foregroundColor = hostConfig.GetForegroundColor(ContainerStyle.Default, icon.forgroundColor, false)

        val fluentIconImageLoaderAsync = FluentIconImageLoaderAsync(
            renderedCard,
            icon.size,
            foregroundColor,
            view
        )

        fluentIconImageLoaderAsync.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, svgURL)
        val tagContent = TagContent(icon)
        val container = createContainer(context, icon)
        tagContent.SetStretchContainer(container)
        container.addView(view)
        createConstraints(context, icon, view, renderArgs).applyTo(container)
        viewGroup.addView(container)
        view.tag = tagContent

        ContainerRenderer.setSelectAction(renderedCard, icon.GetSelectAction(), view, cardActionHandler, renderArgs)
        setVisibility(baseCardElement.GetIsVisible(), view)
        return view
    }

    private fun createContainer(context: Context, icon: Icon): ConstraintLayout {
        val container: ConstraintLayout = LayoutInflater.from(context).inflate(R.layout.image_constraint_layout, null) as ConstraintLayout
        if (icon.GetHeight() == HeightType.Stretch) {
            container.layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.MATCH_PARENT,
                1f
            )
        } else {
            container.layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }
        return container
    }

    private fun createConstraints(context: Context, icon: Icon, imageView: ImageView, renderArgs: RenderArgs): ConstraintSet {
        val constraints = ConstraintSet()

        if (imageView.id == View.NO_ID) {
            imageView.id = View.generateViewId()
        }

        val id = imageView.id

        constraints.clone(context, R.layout.image_constraint_layout)

        constraints.constrainWidth(id, ConstraintSet.MATCH_CONSTRAINT)
        constraints.constrainDefaultWidth(id, ConstraintSet.MATCH_CONSTRAINT_WRAP)
        constraints.connect(id, ConstraintSet.START, R.id.leftBarrier, ConstraintSet.START)
        constraints.connect(id, ConstraintSet.END, R.id.rightBarrier, ConstraintSet.END)

        // By default, height scales with width to maintain aspect ratio
        imageView.adjustViewBounds = true
        imageView.scaleType = ImageView.ScaleType.FIT_START
        constraints.constrainHeight(id, ConstraintSet.WRAP_CONTENT)
        constraints.connect(id, ConstraintSet.TOP, ConstraintSet.PARENT_ID, ConstraintSet.TOP)

        applyHorizontalAlignment(constraints, id, renderArgs)
        applyHorizontalAlignment(constraints, R.id.widthPlaceholder, renderArgs)

        // Set placeholder width, which will adjust left/right barriers (defined in layout)
        constraints.constrainWidth(
            R.id.widthPlaceholder,
            Util.dpToPixels(context, icon.size.toFloat())
        )
        return constraints
    }

    private fun applyHorizontalAlignment(constraints: ConstraintSet, id: Int, renderArgs: RenderArgs) {
        var horizontalAlignment = HorizontalAlignment.Left

        if (renderArgs?.horizontalAlignment != null) {
            horizontalAlignment = renderArgs.horizontalAlignment
        }

        when (horizontalAlignment) {
            HorizontalAlignment.Center -> {
                constraints.setHorizontalBias(id, 0.5f)
            }
            HorizontalAlignment.Right -> {
                constraints.setHorizontalBias(id, 1f)
            }
            HorizontalAlignment.Left -> {
                constraints.setHorizontalBias(id, 0f)
            }
        }
    }
}
