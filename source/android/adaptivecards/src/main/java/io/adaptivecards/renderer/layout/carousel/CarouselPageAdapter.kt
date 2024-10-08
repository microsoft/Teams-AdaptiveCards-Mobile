// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.layout.carousel

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.FragmentManager
import androidx.recyclerview.widget.RecyclerView
import androidx.viewpager2.widget.ViewPager2
import io.adaptivecards.R
import io.adaptivecards.objectmodel.CarouselPage
import io.adaptivecards.objectmodel.CarouselPageVector
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.renderer.RenderArgs
import io.adaptivecards.renderer.RenderedAdaptiveCard
import io.adaptivecards.renderer.actionhandler.ICardActionHandler
import io.adaptivecards.renderer.registration.CardRendererRegistration

/**
 * Implementation of [ViewPager2] adapter for Carousel
 */
class CarouselPageAdapter(
    val pages: CarouselPageVector,
    val renderedCard: RenderedAdaptiveCard,
    val cardActionHandler: ICardActionHandler?,
    val hostConfig: HostConfig,
    val renderArgs: RenderArgs,
    val fragmentManager: FragmentManager
) : RecyclerView.Adapter<CarouselPageAdapter.CarouselPageHolder>() {

    override fun getItemCount() = pages.size

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): CarouselPageHolder {

        val view = LayoutInflater.from(parent.context).inflate(R.layout.item_viewpager, parent, false)
        return CarouselPageHolder(view)
    }

    override fun onBindViewHolder(holder: CarouselPageHolder, position: Int) =
        holder.bind(pages[position], renderedCard, cardActionHandler, hostConfig, renderArgs, fragmentManager)

    class CarouselPageHolder(view: View) : RecyclerView.ViewHolder(view) {

        fun bind(
            page: CarouselPage,
            renderedCard: RenderedAdaptiveCard,
            cardActionHandler: ICardActionHandler?,
            hostConfig: HostConfig,
            renderArgs: RenderArgs,
            fragmentManager: FragmentManager
        ) {
            val featureRegistration = CardRendererRegistration.getInstance().featureRegistration
            val root = (itemView as ViewGroup)
            root.removeAllViews()

            CardRendererRegistration.getInstance().renderElementAndPerformFallback(
                    renderedCard,
                    root.context,
                    fragmentManager,
                    page,
                    root,
                    cardActionHandler,
                    hostConfig,
                    renderArgs,
                    featureRegistration)
        }
    }
}
