package com.example.ac_sdk

import android.content.Context
import android.text.Layout
import android.view.ViewGroup
import androidx.fragment.app.FragmentManager


class CardRendererRegistration {


    //@Throws(AdaptiveFallbackException::class, Exception::class)
    fun renderElements(
        renderedCard: RenderedAdaptiveCard,
        context: Context,
        fragmentManager: FragmentManager,
        viewGroup: ViewGroup,
        baseCardElementList: BaseCardElementVector?,
        cardActionHandler: ICardActionHandler,
        hostConfig: HostConfig,
        renderArgs: RenderArgs,
        layoutToApply: Layout
    ): ViewGroup? {
        return null
    }

    companion object {
        private var s_instance: CardRendererRegistration? = null

        @JvmStatic
        fun getInstance(): CardRendererRegistration {
            if (s_instance == null) {
                s_instance = CardRendererRegistration()
            }
            return s_instance!!
        }
    }

}