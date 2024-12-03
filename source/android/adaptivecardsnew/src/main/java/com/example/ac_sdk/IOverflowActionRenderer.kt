package com.example.ac_sdk

import android.view.View
import android.view.ViewGroup
import androidx.annotation.NonNull

/**
 * Responsible for customizing the overflow action rendering behavior.
 */
interface IOverflowActionRenderer {

    /**
     * This implementation renders an Overflow action view.
     *
     * @param viewGroup          container view for the rendered view to be attached.
     * @param menuItemList       list of view of rendered secondary action elements.
     * @param isRootLevelActions indicates action is part of root level actions or action set elements in body.
     * @return custom rendered view or null to render the default Overflow "..." action view.
     */
    fun onRenderOverflowAction(
        @NonNull viewGroup: ViewGroup,
        @NonNull menuItemList: List<View>,
        isRootLevelActions: Boolean
    ): View? {
        return null
    }

    /**
     * This implementation is invoked when Overflow action view ("...") is pressed and rendered secondary view elements will be shown.
     *
     * @param menuItemList       list of view of rendered secondary action elements.
     * @param view               Overflow action view.
     * @param isRootLevelActions indicates action is part of root level actions or action set elements in body.
     * @return false will show the elements in default {@link android.widget.PopupWindow}, while true indicates client can customize the display behaviour.
     */
    fun onDisplayOverflowActionMenu(
        @NonNull menuItemList: List<View>,
        @NonNull view: View,
        isRootLevelActions: Boolean
    ): Boolean {
        return false
    }

    /**
     * This implementation indicates whether to add the excess elements (i.e id primary elements exceeds the MaxActions) to the secondary elements or not.
     *
     * @return false not to add the excess elements to the secondary elements, otherwise true.
     */
    fun shouldAllowMoreThanMaxActionsInOverflowMenu(): Boolean {
        return false
    }
}