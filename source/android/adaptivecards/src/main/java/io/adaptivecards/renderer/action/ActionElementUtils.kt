package io.adaptivecards.renderer.action

import io.adaptivecards.objectmodel.BaseActionElement
import io.adaptivecards.renderer.registration.CardRendererRegistration

object ActionElementUtils {

    @JvmStatic
    fun BaseActionElement.isSplitAction() : Boolean {
        return CardRendererRegistration.getInstance().isIsSplitActionEnabled && GetIsSplitAction()
    }
}
