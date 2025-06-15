// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer;

import android.app.Activity;
import android.content.Context;
import android.content.ContextWrapper;
import android.view.View;
import android.view.ViewGroup;
import android.widget.HorizontalScrollView;
import android.widget.LinearLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

import io.adaptivecards.objectmodel.ActionMode;
import io.adaptivecards.objectmodel.ActionType;
import io.adaptivecards.objectmodel.AssociatedInputs;
import io.adaptivecards.objectmodel.BaseActionElement;
import io.adaptivecards.objectmodel.ExecuteAction;
import io.adaptivecards.objectmodel.HostConfig;
import io.adaptivecards.objectmodel.IsVisible;
import io.adaptivecards.objectmodel.PopoverAction;
import io.adaptivecards.objectmodel.ShowCardAction;
import io.adaptivecards.objectmodel.SubmitAction;
import io.adaptivecards.objectmodel.ToggleVisibilityAction;
import io.adaptivecards.objectmodel.ToggleVisibilityTarget;
import io.adaptivecards.objectmodel.ToggleVisibilityTargetVector;
import io.adaptivecards.renderer.action.ActionElementUtils;
import io.adaptivecards.renderer.actionhandler.ICardActionHandler;

public abstract class BaseActionElementRenderer implements IBaseActionElementRenderer
{
    /**
     * This tag key is used in {@link io.adaptivecards.renderer.action.DropdownElementRenderer} to get the container view of the Overflow ("...") action, so dropdown view can behave like a primary action element.
     */
    public final static int PARENT_DROPDOWN_TAG = 0xffffffff;

    protected static int getColor(String colorCode)
    {
        return android.graphics.Color.parseColor(colorCode);
    }

    /**
     * Callback to be invoked when an select action for a card element is clicked
     */
    public static class SelectActionOnClickListener extends ActionOnClickListener
    {

        public SelectActionOnClickListener(RenderedAdaptiveCard renderedCard,
                                           BaseActionElement action,
                                           ICardActionHandler cardActionHandler,
                                           FragmentManager fragmentManager,
                                           HostConfig hostConfig,
                                           RenderArgs renderArgs)
        {
            super(renderedCard, action, cardActionHandler, fragmentManager, hostConfig, renderArgs, false);

            if (m_action.GetElementType() == ActionType.ShowCard)
            {
                renderedCard.addWarning(new AdaptiveWarning(AdaptiveWarning.SELECT_SHOW_CARD_ACTION, "ShowCard not supported for SelectAction"));
            }
        }

        @Override
        public void onClick(View v)
        {
            // As we don't support show card actions for select action, then avoid triggering the event
            if (m_action.GetElementType() != ActionType.ShowCard)
            {
                super.onClick(v);
            }
        }

    }

    /**
     * Callback to be invoked when an action is clicked
     */
    public static class ActionOnClickListener implements View.OnClickListener
    {

        public static ActionOnClickListener newInstance(
            RenderedAdaptiveCard renderedCard,
            BaseActionElement baseActionElement,
            ICardActionHandler cardActionHandler) {
            return new ActionOnClickListener(renderedCard,  baseActionElement, cardActionHandler, false);
        }

        public static ActionOnClickListener newInstance(
            RenderedAdaptiveCard renderedCard,
            Context context,
            FragmentManager fragmentManager,
            ViewGroup viewGroup,
            BaseActionElement baseActionElement,
            ICardActionHandler cardActionHandler,
            HostConfig hostConfig,
            RenderArgs renderArgs) {
            return newInstance(renderedCard, context, fragmentManager, viewGroup, baseActionElement, cardActionHandler, hostConfig, renderArgs, false);
        }

        public static ActionOnClickListener newInstance(
            RenderedAdaptiveCard renderedCard,
            Context context,
            FragmentManager fragmentManager,
            ViewGroup viewGroup,
            BaseActionElement baseActionElement,
            ICardActionHandler cardActionHandler,
            HostConfig hostConfig,
            RenderArgs renderArgs,
            boolean isMenuAction) {
            return new ActionOnClickListener(renderedCard, context, fragmentManager, viewGroup, baseActionElement, cardActionHandler, hostConfig, renderArgs, isMenuAction);
        }

        /**
         * Constructs an ActionOnClickListener. Use this constructor if you want to support any type of action
         * @param renderedCard
         * @param context
         * @param fragmentManager
         * @param viewGroup
         * @param baseActionElement
         * @param cardActionHandler
         * @param hostConfig
         * @param renderArgs
         * @param isMenuAction - true if menu action(action in menuActions within another action), false otherwise
         */
        protected ActionOnClickListener(RenderedAdaptiveCard renderedCard,
                                     Context context,
                                     FragmentManager fragmentManager,
                                     ViewGroup viewGroup,
                                     BaseActionElement baseActionElement,
                                     ICardActionHandler cardActionHandler,
                                     HostConfig hostConfig,
                                     RenderArgs renderArgs,
                                     boolean isMenuAction)
        {
            // comment added to avoid the warning
            this(renderedCard, baseActionElement, cardActionHandler, isMenuAction);
            m_isInlineShowCardAction = (baseActionElement.GetElementType() == ActionType.ShowCard) && (hostConfig.GetActions().getShowCard().getActionMode() == ActionMode.Inline);
            m_fragmentManager = fragmentManager;
            m_renderArgs = renderArgs;
            m_hostConfig = hostConfig;

            // As SelectAction doesn't support ShowCard actions, then this line won't be executed
            if (m_isInlineShowCardAction)
            {
                renderHiddenCard(context, fragmentManager, viewGroup, hostConfig, renderArgs);
            }
        }

        /**
         * Constructs an ActionOnClickListener. Use this constructor if you want to pass renderArgs also
         * @param renderedCard
         * @param baseActionElement
         * @param cardActionHandler
         * @param renderArgs
         * @param isMenuAction - true if menu action(action in menuActions within another action), false otherwise
         */
        protected ActionOnClickListener(RenderedAdaptiveCard renderedCard,
                                        BaseActionElement baseActionElement,
                                        ICardActionHandler cardActionHandler,
                                        FragmentManager fragmentManager,
                                        HostConfig hostConfig,
                                        RenderArgs renderArgs,
                                        boolean isMenuAction)
        {
            this(renderedCard, baseActionElement, cardActionHandler, isMenuAction);
            m_renderArgs = renderArgs;
            m_fragmentManager = fragmentManager;
            m_hostConfig = hostConfig;
        }

        /**
         * Constructs an ActionOnClickListener. Use this constructor if you want to support any type of action except ShowCardAction
         * @param renderedCard
         * @param baseActionElement
         * @param cardActionHandler
         * @param isMenuAction - true if menu action(action in menuActions within another action), false otherwise
         */
        private ActionOnClickListener(
            RenderedAdaptiveCard renderedCard,
            BaseActionElement baseActionElement,
            ICardActionHandler cardActionHandler,
            boolean isMenuAction)
        {
            m_action = baseActionElement;
            m_renderedAdaptiveCard = renderedCard;
            m_cardActionHandler = cardActionHandler;
            m_isMenuAction = isMenuAction;

            // In case of the action being a ToggleVisibility action, store the action as ToggleVisibility action so no recasting must be made
            if (m_action.GetElementType() == ActionType.ToggleVisibility)
            {
                m_toggleVisibilityAction = null;
                if (m_action instanceof ToggleVisibilityAction)
                {
                    m_toggleVisibilityAction = (ToggleVisibilityAction) m_action;
                }
                else if ((m_toggleVisibilityAction = ToggleVisibilityAction.dynamic_cast(m_action)) == null)
                {
                    throw new InternalError("Unable to convert BaseActionElement to ToggleVisibilityAction object model.");
                }
            }
        }

        /**
         * Resets the visibility of all separators in this viewGroup hiding, if it has, the separator for the first visible element and showing the separator for all other elements
         * @param viewGroup
         */
        private void resetSeparatorVisibilities(ViewGroup viewGroup)
        {
            boolean isFirstElement = true;
            for (int i = 0; i < viewGroup.getChildCount(); ++i)
            {
                View element = viewGroup.getChildAt(i);
                TagContent tagContent = BaseCardElementRenderer.getTagContent(element);

                if (tagContent != null)
                {
                    if (!tagContent.IsSeparator() && element.getVisibility() == View.VISIBLE)
                    {
                        View separator = tagContent.GetSeparator();

                        if (separator != null)
                        {
                            // Only the first element must hide its separator
                            if (isFirstElement)
                            {
                                separator.setVisibility(View.GONE);
                            }
                            else
                            {
                                separator.setVisibility(View.VISIBLE);
                            }
                        }

                        // Reset this so all the other elements can have their separators visible
                        isFirstElement = false;
                    }
                }

            }
        }

        private void renderHiddenCard(Context context, FragmentManager fragmentManager, ViewGroup viewGroup, HostConfig hostConfig, RenderArgs renderArgs)
        {
            ShowCardAction showCardAction = Util.castTo(m_action, ShowCardAction.class);

            m_invisibleCard = AdaptiveCardRenderer.getInstance().internalRender(m_renderedAdaptiveCard, context, fragmentManager, showCardAction.GetCard(),
                                                                                m_cardActionHandler, hostConfig, true, renderArgs.getContainerCardId());
            m_invisibleCard.setVisibility(View.GONE);
            LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
            layoutParams.setMargins(0, Util.dpToPixels(context, hostConfig.GetActions().getShowCard().getInlineTopMargin()), 0, 0);
            m_invisibleCard.setLayoutParams(layoutParams);

            ViewGroup parent = (ViewGroup) viewGroup.getParent();
            if (parent instanceof HorizontalScrollView) // Required when the actions are set in horizontal
            {
                parent = (ViewGroup) parent.getParent().getParent();
            }
            else
            {
                parent = (ViewGroup) parent.getParent();
            }

            m_hiddenCardsLayout = (ViewGroup) parent.getChildAt(1);
            m_hiddenCardsLayout.addView(m_invisibleCard);
        }

        private @Nullable Activity getActivity(Context context)
        {
            while (context instanceof ContextWrapper)
            {
                if (context instanceof Activity)
                {
                    return (Activity)context;
                }
                context = ((ContextWrapper)context).getBaseContext();
            }
            return null;
        }

        private void populateViewsDictionary()
        {
            m_viewDictionary = new HashMap<>();

            ToggleVisibilityTargetVector toggleVisibilityTargetVector = m_toggleVisibilityAction.GetTargetElements();
            View rootView = m_renderedAdaptiveCard.getView();

            for (int i = 0; i < toggleVisibilityTargetVector.size(); ++i)
            {
                ToggleVisibilityTarget target = toggleVisibilityTargetVector.get(i);
                String elementId = target.GetElementId();

                View foundView = rootView.findViewWithTag(new TagContent(elementId));
                if (foundView != null)
                {
                    m_viewDictionary.put(elementId, foundView);
                }
            }
        }

        private void handleInlineShowCardAction(View v)
        {
            Activity hostingActivity = getActivity(v.getContext());
            if (hostingActivity != null)
            {
                View currentFocusedView = hostingActivity.getCurrentFocus();
                if (currentFocusedView != null)
                {
                    currentFocusedView.clearFocus();
                }
            }

            v.setSelected(m_invisibleCard.getVisibility() != View.VISIBLE);
            // Reset all other buttons
            ViewGroup parentContainer;
            if (v.getTag(PARENT_DROPDOWN_TAG) != null)
            {
                parentContainer = (ViewGroup) v.getTag(PARENT_DROPDOWN_TAG);
            }
            else
            {
                parentContainer = (ViewGroup) v.getParent();
            }

            for (int i = 0; i < parentContainer.getChildCount(); ++i)
            {
                View actionInActionSet = parentContainer.getChildAt(i);
                if (v != actionInActionSet)
                {
                    actionInActionSet.setSelected(false);
                }
            }

            for (int i = 0; i < m_hiddenCardsLayout.getChildCount(); ++i)
            {
                View child = m_hiddenCardsLayout.getChildAt(i);
                if (child != m_invisibleCard)
                {
                    child.setVisibility(View.GONE);
                }
            }

            m_invisibleCard.setVisibility(m_invisibleCard.getVisibility() == View.VISIBLE ? View.GONE : View.VISIBLE);

            View mainCardView = ((ViewGroup) m_hiddenCardsLayout.getParent()).getChildAt(0);
            int padding = mainCardView.getPaddingTop();

            //remove bottom padding from top linear layout
            if (m_invisibleCard.getVisibility() == View.VISIBLE)
            {
                mainCardView.setPadding(padding, padding, padding, 0);
            }
            else
            {
                mainCardView.setPadding(padding, padding, padding, padding);
            }
        }

        private void handlePopoverAction(@NonNull PopoverAction action, @NonNull View v) {
            PopoverRenderer popoverRenderer = new PopoverRenderer(
                action,
                v,
                m_renderedAdaptiveCard,
                m_fragmentManager,
                m_cardActionHandler,
                m_hostConfig,
                m_renderArgs
            );
            popoverRenderer.showPopover();
        }

        private void handleToggleVisibilityAction(View v)
        {
            ToggleVisibilityTargetVector toggleVisibilityTargetVector = m_toggleVisibilityAction.GetTargetElements();

            // Populate the dictionary only once so multiple clicks don't perform the search operation every time
            if (m_viewDictionary == null)
            {
                populateViewsDictionary();
            }

            // Store the viewgroups to update to avoid updating the same one multiple times
            Set<ViewGroup> viewGroupsToUpdate = new HashSet<>();

            for (int i = 0; i < toggleVisibilityTargetVector.size(); ++i)
            {
                ToggleVisibilityTarget target = toggleVisibilityTargetVector.get(i);
                String elementId = target.GetElementId();

                if (m_viewDictionary.containsKey(elementId))
                {
                    View foundView = m_viewDictionary.get(elementId);
                    IsVisible isVisible = target.GetIsVisible();

                    boolean elementWillBeVisible = true;

                    // If the visibility changes to not visible or the visibility toggles and the element is currently visible then the element will not be visible
                    // Otherwise it will be visible (default value)
                    if ((isVisible == IsVisible.IsVisibleFalse) ||
                        (isVisible == IsVisible.IsVisibleToggle && foundView.getVisibility() == View.VISIBLE))
                    {
                        elementWillBeVisible = false;
                    }

                    String newVisibilityText = elementWillBeVisible ? " Expanded" : " Collapsed";

                    v.announceForAccessibility(elementId + newVisibilityText);

                    BaseCardElementRenderer.setVisibility(elementWillBeVisible, foundView, viewGroupsToUpdate);

                }
            }

            for (ViewGroup container : viewGroupsToUpdate)
            {
                resetSeparatorVisibilities(container);
            }
        }

        // Identifies if this action is primary action(not menu action) and contains menu actions in it
        private boolean areMenuActionsPresent(@NonNull BaseActionElement baseActionElement) {
            return !m_isMenuAction && ActionElementUtils.isSplitAction(baseActionElement);
        }

        /***
         * Handle menu actions scenario for the given action element.
         * By default this is a no-op. Subclasses can override this method
         * to define the required behavior.
         *
         * @return Boolean - true if scenario is handled, false if not.
         * Default return type is false.
         */
        protected boolean handleMenuActionsScenario(@NonNull View view, @NonNull BaseActionElement baseActionElement) {
            return false;
        }

        // Identifies if this action is show card action
        private boolean isShowCardAction(@NonNull BaseActionElement baseActionElement) {
            return baseActionElement.GetElementType() == ActionType.ShowCard;
        }

        /***
         * Handle show card scenario for the given action element.
         * By default this is a no-op. Subclasses can override this method
         * to define the required behavior.
         *
         * @return Boolean - true if scenario is handled, false if not.
         * Default return type is false.
         */
        protected boolean handleShowCardScenario(@NonNull View view, @NonNull BaseActionElement baseActionElement) {
            return false;
        }

        @Override
        public void onClick(View view)
        {
            /*
                1. menuActions not allowed inside popover
                2. if menu actions are present inside the action
                3. if hub is handling the menu actions, else go down
             */
            if (!m_renderArgs.isPopoverContent() && areMenuActionsPresent(m_action) && handleMenuActionsScenario(view, m_action)) {
                return;
            }

            if (isShowCardAction(m_action) && handleShowCardScenario(view, m_action)) {
                return;
            }

            m_renderedAdaptiveCard.clearValidatedInputs();

            if (m_isInlineShowCardAction)
            {
                handleInlineShowCardAction(view);
                view.requestFocus();
            }
            else if (m_action.GetElementType() == ActionType.ToggleVisibility)
            {
                handleToggleVisibilityAction(view);
            } else if (m_action.GetElementType() == ActionType.Popover) {
                PopoverAction action = Util.castTo(m_action, PopoverAction.class);
                handlePopoverAction(action, view);
            }
            else
            {
                if (m_action.GetElementType() == ActionType.Execute || m_action.GetElementType() == ActionType.Submit || m_renderedAdaptiveCard.isActionSubmitable(view))
                {

                    // dismiss popover on click of submit and execute
                    dismissPopoverIfNeeded();

                    // Don't gather inputs or perform validation when AssociatedInputs is None
                    boolean gatherInputs = true;
                    try
                    {
                        try
                        {
                            gatherInputs = Util.castTo(m_action, ExecuteAction.class).GetAssociatedInputs() != AssociatedInputs.None;
                        }
                        catch (ClassCastException e)
                        {
                            gatherInputs = Util.castTo(m_action, SubmitAction.class).GetAssociatedInputs() != AssociatedInputs.None;
                        }
                    }
                    catch (ClassCastException e)
                    {
                        // Custom action with Submit type will continue to gather inputs
                    }
                    if (gatherInputs && !m_renderedAdaptiveCard.areInputsValid(Util.getViewId(view), m_renderArgs))
                    {
                        return;
                    }
                }

                m_cardActionHandler.onAction(m_action, m_renderedAdaptiveCard);
            }
        }

        private void dismissPopoverIfNeeded() {
            if (m_renderArgs.isPopoverContent() && m_renderedAdaptiveCard.getPopoverDialog() != null) {
                m_renderedAdaptiveCard.getPopoverDialog().dismiss();
                m_renderedAdaptiveCard.setPopoverDialog(null);
            }
        }

        @Nullable
        protected FragmentManager m_fragmentManager;
        @Nullable
        protected HostConfig m_hostConfig;
        @Nullable
        protected RenderArgs m_renderArgs;

        protected BaseActionElement m_action;
        protected RenderedAdaptiveCard m_renderedAdaptiveCard;
        protected ICardActionHandler m_cardActionHandler;

        // Information for handling ShowCard actions
        private View m_invisibleCard = null;
        private ViewGroup m_hiddenCardsLayout = null;
        private boolean m_isInlineShowCardAction = false;

        // Information for handling ToggleVisibility actions
        private HashMap<String, View> m_viewDictionary = null;
        private ToggleVisibilityAction m_toggleVisibilityAction = null;

        // Information for handling SplitAction scenario for actions
        private final boolean m_isMenuAction;
    }
}
