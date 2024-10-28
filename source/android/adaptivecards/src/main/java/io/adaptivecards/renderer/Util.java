// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer;

import static android.view.ViewGroup.LayoutParams.WRAP_CONTENT;
import static androidx.annotation.Dimension.DP;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Rect;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.util.DisplayMetrics;
import android.util.Pair;
import android.util.TypedValue;
import android.view.TouchDelegate;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;

import androidx.annotation.Dimension;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.Px;

import com.google.android.flexbox.FlexboxLayout;
import com.google.android.flexbox.JustifyContent;

import java.lang.reflect.Method;
import java.util.List;

import io.adaptivecards.R;
import io.adaptivecards.objectmodel.AreaGridLayout;
import io.adaptivecards.objectmodel.BaseActionElement;
import io.adaptivecards.objectmodel.BaseActionElementVector;
import io.adaptivecards.objectmodel.BaseCardElement;
import io.adaptivecards.objectmodel.BaseElement;
import io.adaptivecards.objectmodel.BaseInputElement;
import io.adaptivecards.objectmodel.CharVector;
import io.adaptivecards.objectmodel.Column;
import io.adaptivecards.objectmodel.FlowLayout;
import io.adaptivecards.objectmodel.HostConfig;
import io.adaptivecards.objectmodel.HostWidth;
import io.adaptivecards.objectmodel.HostWidthConfig;
import io.adaptivecards.objectmodel.IconPlacement;
import io.adaptivecards.objectmodel.IconSize;
import io.adaptivecards.objectmodel.JsonValue;
import io.adaptivecards.objectmodel.Layout;
import io.adaptivecards.objectmodel.LayoutContainerType;
import io.adaptivecards.objectmodel.LayoutVector;
import io.adaptivecards.objectmodel.Mode;
import io.adaptivecards.objectmodel.ParseContext;
import io.adaptivecards.objectmodel.TargetWidthType;
import io.adaptivecards.renderer.action.ActionElementRendererIconImageLoaderAsync;
import io.adaptivecards.renderer.layout.AreaGridLayoutView;
import io.adaptivecards.renderer.registration.CardRendererRegistration;
import io.adaptivecards.renderer.registration.FeatureFlagResolverUtility;

public final class Util {

    /**
     * Convert dp to px
     * @param context Application context
     * @param dp The number of Android dips (display-independent pixels)
     * @return The number of equivalent physical pixels
     */
    public static int dpToPixels(Context context, float dp)
    {
        DisplayMetrics metrics = context.getResources().getDisplayMetrics();
        int returnVal = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp, metrics);
        return returnVal;
    }


    public static void expandClickArea(@NonNull View viewToIncreaseClickArea, int adjustedMinSize) {
        // Get the hit rectangle for the button.
        Rect delegateArea = new Rect();
        viewToIncreaseClickArea.getHitRect(delegateArea);

        // Extend the touch area to include the above and below the button to the edges of the card
        int widthOffset = (int) ((adjustedMinSize - delegateArea.width()) / 2f);
        int heightOffset = (int) ((adjustedMinSize - delegateArea.height()) / 2f);
        delegateArea.left -= widthOffset;
        delegateArea.right += widthOffset;
        delegateArea.top -= heightOffset;
        delegateArea.bottom += heightOffset;

        // Sets the TouchDelegate on the parent view and touches within the new extended bounds are routed to button.
        TouchDelegate touchDelegate = new TouchDelegate(delegateArea, viewToIncreaseClickArea);
        if (viewToIncreaseClickArea.getParent() instanceof View) {
            ((View) viewToIncreaseClickArea.getParent()).setTouchDelegate(touchDelegate);
        }
    }

    public static byte[] getBytes(CharVector charVector)
    {
        long vectorSize = charVector.size();
        byte[] byteArray = new byte[(int)vectorSize];
        for(int i = 0; i < vectorSize; ++i)
        {
            byteArray[i] = (byte)charVector.get(i).charValue();
        }

        return byteArray;
    }

    /**
     * Force focus when requestFocus is not sufficient.
     * @param v The target View to focus
     */
    public static void forceFocus(View v)
    {
        boolean focusableInTouchMode = v.isFocusableInTouchMode();

        v.setFocusable(true);
        v.setFocusableInTouchMode(true);

        v.requestFocusFromTouch();

        v.setFocusableInTouchMode(focusableInTouchMode);
    }

    /**
     * Generate new Bitmap scaled to given height from given Bitmap, preserving aspect ratio.
     * Note: This is computationally expensive.
     * @param height Desired height, in pixels
     * @param bitmap Bitmap to scale
     */
    public static Bitmap scaleBitmapToHeight(float height, Bitmap bitmap)
    {
        Drawable d = new BitmapDrawable(null, bitmap);

        float scaleRatio = height / d.getIntrinsicHeight();
        float width = scaleRatio * d.getIntrinsicWidth();

        return Bitmap.createScaledBitmap(bitmap, (int)width, (int)height, false);
    }

    public static HostWidth convertHostCardContainerToHostWidth(int hostCardContainer, HostWidthConfig hostWidthConfig) {

        if (hostCardContainer <= 0 || hostWidthConfig == null
            || hostWidthConfig.getVeryNarrow() == 0 || hostWidthConfig.getNarrow() == 0
            || hostWidthConfig.getStandard() == 0) {
            return HostWidth.Default;
        }

        HostWidth hostWidth;

        if (hostCardContainer <= hostWidthConfig.getVeryNarrow()) {
            hostWidth = HostWidth.VeryNarrow;
        } else if (hostCardContainer > hostWidthConfig.getVeryNarrow() && hostCardContainer <= hostWidthConfig.getNarrow()) {
            hostWidth = HostWidth.Narrow;
        } else if (hostCardContainer > hostWidthConfig.getNarrow() && hostCardContainer <= hostWidthConfig.getStandard()) {
            hostWidth = HostWidth.Standard;
        } else {
            hostWidth = HostWidth.Wide;
        }

        return hostWidth;
    }

    public static void MoveChildrenViews(ViewGroup origin, ViewGroup destination, Layout layoutToApply, TagContent tagContent, HostConfig hostConfig)
    {
        final int childCount = origin.getChildCount();

        if(layoutToApply.GetLayoutContainerType() == LayoutContainerType.AreaGrid && destination instanceof AreaGridLayoutView) {
            moveChildrenViewsToAreaGridLayoutView(origin, (AreaGridLayoutView)destination, layoutToApply, tagContent, hostConfig);
            return;
        }

        for (int i = 0; i < childCount; ++i)
        {
            View v = origin.getChildAt(i);
            origin.removeView(v);

            if (layoutToApply.GetLayoutContainerType() == LayoutContainerType.Flow && destination instanceof FlexboxLayout) {
                v.setLayoutParams(generateLayoutParamsForFlowLayoutItems(destination.getContext(), layoutToApply, hostConfig));
            }
            destination.addView(v);

        }

    }

    private static void moveChildrenViewsToAreaGridLayoutView(ViewGroup origin, AreaGridLayoutView areaGridLayoutView, Layout layoutToApply, TagContent tagContent, HostConfig hostConfig) {

        AreaGridLayout areaGridLayout = Util.castTo(layoutToApply, AreaGridLayout.class);
        areaGridLayoutView.setUpAreaGrids(areaGridLayout);
        addChildrenToAreas(origin, areaGridLayoutView, areaGridLayout, tagContent, hostConfig);
    }

    private static void addChildrenToAreas(ViewGroup origin, AreaGridLayoutView areaGridLayoutView, AreaGridLayout areaGridLayout, TagContent tagContent, HostConfig hostConfig) {
        final int childCount = origin.getChildCount();

        int rowSpacing = Util.dpToPixels(origin.getContext(), BaseCardElementRenderer.getSpacingSize(areaGridLayout.GetRowSpacing(), hostConfig.GetSpacing()));
        int columnSpacing = Util.dpToPixels(origin.getContext(), BaseCardElementRenderer.getSpacingSize(areaGridLayout.GetColumnSpacing(), hostConfig.GetSpacing()));

        for (int i = 0; i < childCount; ++i) {
            View v = origin.getChildAt(i);
            origin.removeView(v);
            areaGridLayoutView.addAreaView(v, tagContent.GetBaseElement().GetNonOptionalAreaGridName(), rowSpacing, columnSpacing);
        }
    }

    public static void setHorizontalAlignmentForFlowLayout(FlexboxLayout flexboxLayout, Layout layout) {
        FlowLayout flowLayout = Util.castTo(layout, FlowLayout.class);
        switch (flowLayout.GetHorizontalAlignment()) {
            case Right:
                flexboxLayout.setJustifyContent(JustifyContent.FLEX_END);
                break;
            case Left:
                flexboxLayout.setJustifyContent(JustifyContent.FLEX_START);
                break;
            default:
                flexboxLayout.setJustifyContent(JustifyContent.CENTER);
                break;
        }
    }

    /**
     * This method generates the LayoutParams for the FlowLayout items after reading the properties from the FlowLayout object.
     **/
    public static FlexboxLayout.LayoutParams generateLayoutParamsForFlowLayoutItems(Context context, Layout layoutToApply, HostConfig hostConfig) {
        FlowLayout flowLayout = Util.castTo(layoutToApply, FlowLayout.class);
        int valueNotDefinedIndicator = 0;
        int itemWidth = isValueDefined(flowLayout.GetItemPixelWidth())? dpToPixels(context, flowLayout.GetItemPixelWidth()) :
            WRAP_CONTENT;

        int maxItemWidth = isValueDefined(flowLayout.GetMaxItemPixelWidth()) ? dpToPixels(context, flowLayout.GetMaxItemPixelWidth()) :
            valueNotDefinedIndicator;

        int minItemWidth = isValueDefined(flowLayout.GetMinItemPixelWidth()) ? dpToPixels(context, flowLayout.GetMinItemPixelWidth()) :
            valueNotDefinedIndicator;

        int widthToApply = itemWidth;
        if (maxItemWidth != valueNotDefinedIndicator && (itemWidth == WRAP_CONTENT || itemWidth >= maxItemWidth)) {
            widthToApply = maxItemWidth;
        }

        FlexboxLayout.LayoutParams params = new FlexboxLayout.LayoutParams(widthToApply, WRAP_CONTENT);
        int rowSpacing = Util.dpToPixels(context, BaseCardElementRenderer.getSpacingSize(flowLayout.GetRowSpacing(), hostConfig.GetSpacing()));
        int columnSpacing = Util.dpToPixels(context, BaseCardElementRenderer.getSpacingSize(flowLayout.GetColumnSpacing(), hostConfig.GetSpacing()));
        params.setMargins(rowSpacing, columnSpacing, rowSpacing, columnSpacing);

        if (minItemWidth != valueNotDefinedIndicator) {
            params.setMinWidth(minItemWidth);
        }
        if (maxItemWidth != valueNotDefinedIndicator) {
            params.setMaxWidth(maxItemWidth);
        }
        return params;
    }

    /**
     * returns the layout to apply to the container
     **/
    public static Layout getLayoutToApply(LayoutVector layouts, HostConfig hostConfig) {
        Layout layoutToApply = new Layout();
        layoutToApply.SetLayoutContainerType(LayoutContainerType.None);

        HostWidthConfig hostWidthConfig = hostConfig.getHostWidth();
        int hostCardContainer = CardRendererRegistration.getInstance().getHostCardContainer();
        HostWidth hostWidth = Util.convertHostCardContainerToHostWidth(hostCardContainer, hostWidthConfig);
        if (layouts != null) {
            for (int i = 0; i < layouts.size(); i++) {
                Layout currentLayout = layouts.get(i);
                if (currentLayout.GetLayoutContainerType() == LayoutContainerType.None) {
                    continue;
                }

                if (currentLayout.MeetsTargetWidthRequirement(hostWidth)) {
                    layoutToApply = currentLayout;
                    break;
                }
                else if (currentLayout.GetTargetWidth() == TargetWidthType.Default) {
                    layoutToApply = currentLayout;
                }
            }
        }
        LayoutContainerType layoutContainerType = layoutToApply.GetLayoutContainerType();
        if ((layoutContainerType == LayoutContainerType.Flow && FeatureFlagResolverUtility.INSTANCE.isFlowLayoutEnabled()) ||
            (layoutContainerType == LayoutContainerType.AreaGrid && FeatureFlagResolverUtility.INSTANCE.isGridLayoutEnabled())) {
            return layoutToApply;
        } else {
            Layout defaultStackLayout = new Layout();
            defaultStackLayout.SetLayoutContainerType(LayoutContainerType.Stack);
            defaultStackLayout.SetTargetWidth(TargetWidthType.Default);
            return defaultStackLayout;
        }
    }

    private static boolean isValueDefined(int inputValue) {
        int undefinedValueIndicator = -1;
        return inputValue != undefinedValueIndicator;
    }

    /**
     * Casts the baseElement into a BaseCardElement
     *
     * @param baseElement BaseElement to be casted into BaseCardElement
     * @return Casted BaseCardElement object if succeeded, null otherwise
     */
    public static @Nullable BaseCardElement tryCastToBaseCardElement(BaseElement baseElement)
    {
        try
        {
            return castToBaseCardElement(baseElement);
        }
        catch (ClassCastException ex)
        {
            return null;
        }
    }

    /**
     * Casts the baseElement into a BaseCardElement. Throws a ClassCastException if the element cannot be casted
     *
     * @param baseElement BaseElement to be casted into BaseCardElement
     * @return Casted BaseCardElement object
     * @throws ClassCastException
     */
    public static BaseCardElement castToBaseCardElement(BaseElement baseElement) throws ClassCastException
    {
        BaseCardElement baseCardElement;
        if (baseElement instanceof BaseCardElement)
        {
            baseCardElement = (BaseCardElement) baseElement;
        }
        else if ((baseCardElement = BaseCardElement.dynamic_cast(baseElement)) == null)
        {
            throw new ClassCastException("Unable to convert BaseElement to BaseCardElement object model.");
        }
        return baseCardElement;
    }

    /**
     * Checks if the provided cardElement is of the specified type
     *
     * @param cardElement BaseCardElement to be queried
     * @param cardElementType Type of card element to be queried
     * @param <T> Class of card element to be queried, extends from BaseCardElement
     * @return True if the card element is of the queried type
     */
    public static<T extends BaseCardElement> boolean isOfType(BaseCardElement cardElement, Class<T> cardElementType)
    {
        return (tryCastTo(cardElement, cardElementType) != null);
    }

    public static ViewGroup getMockLayout(Context context, BaseCardElement baseCardElement) {
        if (Util.isOfType(baseCardElement, Column.class))
        {
            return new FlexboxLayout(context);
        }
        else
        {
            return new LinearLayout(context);
        }
    }


    /**
     * Casts the provided cardElement into the specified type
     *
     * @param cardElement BaseCardElement to be casted
     * @param cardElementType Class for the cardElement to be casted into
     * @param <T> Class of card to be casted to, extends from BaseCardElement
     * @return The casted card element if cardElement is of type cardElementType, null otherwise
     */
    public static<T extends BaseCardElement> T tryCastTo(BaseCardElement cardElement, Class<T> cardElementType)
    {
        try
        {
            return castTo(cardElement, cardElementType);
        }
        catch (Exception e)
        {
            return null;
        }
    }

    /**
     * Casts the provided cardElement into the specified type. Throws an Exception if it doesn't
     * match the specified type
     *
     * @param cardElement BaseCardElement to be casted
     * @param cardElementType Class for the cardElement to be casted into
     * @param <T> Class of card to be casted to, extends from BaseCardElement
     * @return The casted card element if cardElement is of type cardElementType, otherwise throws ClassCastException
     * @throws ClassCastException
     */
    public static<T extends BaseCardElement> T castTo(BaseCardElement cardElement, Class<T> cardElementType) throws ClassCastException
    {
        try
        {
            T castedElement = null;
            // As T is a generic, we cannot use instanceOf, so we have to use the isAssignableFrom method which provides the same functionality
            if (cardElementType.isAssignableFrom(cardElement.getClass()))
            {
                castedElement = (T)cardElement;
            }
            else
            {
                // If the element could not be casted, we use reflection to retrieve and execute the dynamic_cast method, if the method is not found it throws
                Method dynamicCastMethod = cardElementType.getMethod("dynamic_cast", BaseCardElement.class);
                if ((castedElement = (T)dynamicCastMethod.invoke(null, cardElement)) == null)
                {
                     // If after both tries, the element could not be casted, we throw a conversion exception
                    throw new InternalError("Unable to convert " + cardElement.getClass().getName() + " to " + cardElementType.getName() + " object model.");
                }
            }
            return castedElement;
        }
        catch (Exception e)
        {
            throw new ClassCastException("Unable to find dynamic_cast method in " + cardElementType.getName() + ".");
        }
    }

    /**
     * Casts the provided layout into the specified type. Throws an Exception if it doesn't
     * match the specified type
     *
     * @param layout Layout to be casted
     * @param layoutType Class for the layout to be casted into
     * @param <T> Class of layout to be casted to, extends from Layout
     * @return The casted layout if layout is of type layoutType, otherwise throws ClassCastException
     * @throws ClassCastException
     */
    public static<T extends Layout> T castTo(Layout layout, Class<T> layoutType) throws ClassCastException
    {
        try
        {
            T castedElement = null;
            // As T is a generic, we cannot use instanceOf, so we have to use the isAssignableFrom method which provides the same functionality
            if (layoutType.isAssignableFrom(layout.getClass()))
            {
                castedElement = (T)layout;
            }
            else
            {
                // If the element could not be casted, we use reflection to retrieve and execute the dynamic_cast method, if the method is not found it throws
                Method dynamicCastMethod = layoutType.getMethod("dynamic_cast", Layout.class);
                if ((castedElement = (T)dynamicCastMethod.invoke(null, layout)) == null)
                {
                    // If after both tries, the element could not be casted, we throw a conversion exception
                    throw new InternalError("Unable to convert " + layout.getClass().getName() + " to " + layoutType.getName() + " object model.");
                }
            }
            return castedElement;
        }
        catch (Exception e)
        {
            throw new ClassCastException("Unable to find dynamic_cast method in " + layoutType.getName() + ".");
        }
    }

    /**
     * Casts the baseElement into a BaseActionElement
     *
     * @param baseElement BaseElement to be casted into BaseActionElement
     * @return Casted BaseActionElement object if succeeded, null otherwise
     */
    public static @Nullable BaseActionElement tryCastToBaseActionElement(BaseElement baseElement)
    {
        try
        {
            return castToBaseActionElement(baseElement);
        }
        catch (ClassCastException ex)
        {
            return null;
        }
    }

    /**
     * Casts the baseElement into a BaseActionElement. Throws a ClassCastException if the element cannot be casted
     *
     * @param baseElement BaseElement to be casted into BaseActionElement
     * @return Casted BaseActionElement object
     * @throws ClassCastException
     */
    public static BaseActionElement castToBaseActionElement(BaseElement baseElement) throws ClassCastException
    {
        BaseActionElement baseActionElement;
        if (baseElement instanceof BaseActionElement)
        {
            baseActionElement = (BaseActionElement) baseElement;
        }
        else if ((baseActionElement = BaseActionElement.dynamic_cast(baseElement)) == null)
        {
            throw new ClassCastException("Unable to convert BaseElement to BaseCardElement object model.");
        }
        return baseActionElement;
    }

    /**
     * Checks if the provided actionElement is of the specified type
     *
     * @param actionElement BaseActionElement to be queried
     * @param actionElementType Type of action to be queried
     * @param <T> Class of action to be queried, extends from BaseActionElement
     * @return True if the action is of the queried type
     */
    public static<T extends BaseActionElement> boolean isOfType(BaseActionElement actionElement, Class<T> actionElementType)
    {
        return (tryCastTo(actionElement, actionElementType) != null);
    }

    /**
     * Casts the provided actionElement into the specified type
     *
     * @param actionElement BaseActionElement to be casted
     * @param actionElementType Class for the actionElement to be casted into
     * @param <T> Class of action to be casted to, extends from BaseActionElement
     * @return The casted action element if actionElement is of type actionElementType, null otherwise
     */
    public static<T extends BaseActionElement> T tryCastTo(BaseActionElement actionElement, Class<T> actionElementType)
    {
        try
        {
            return castTo(actionElement, actionElementType);
        }
        catch (Exception e)
        {
            return null;
        }
    }


    /**
     * Converts pixels to dps.
     *
     * @param context the Context for getting the resources
     * @param px      dimension in pixels
     * @return dimension in dps
     */
    public static @Dimension(unit = DP) int pixelToDp(@NonNull Context context, @Px int px) {
        DisplayMetrics displayMetrics = context.getResources()
            .getDisplayMetrics();
        return Math.round(px / displayMetrics.density);
    }

    /**
     * Casts the provided actionElement into the specified type. Throws an Exception if it doesn't
     * match the specified type
     *
     * @param actionElement BaseActionElement to be casted
     * @param actionElementType Class for the actionElement to be casted into
     * @param <T> Class of action to be casted to, extends from BaseActionElement
     * @return The casted action element if actionElement is of type actionElementType, otherwise throws ClassCastException
     * @throws ClassCastException
     */
    public static<T extends BaseActionElement> T castTo(BaseActionElement actionElement, Class<T> actionElementType) throws ClassCastException
    {
        try
        {
            T castedElement = null;
            // As T is a generic, we cannot use instanceOf, so we have to use the isAssignableFrom method which provides the same functionality
            if (actionElementType.isAssignableFrom(actionElement.getClass()))
            {
                castedElement = (T)actionElement;
            }
            else
            {
                // If the element could not be casted, we use reflection to retrieve and execute the dynamic_cast method, if the method is not found it throws
                Method dynamicCastMethod = actionElementType.getMethod("dynamic_cast", BaseActionElement.class);
                if ((castedElement = (T)dynamicCastMethod.invoke(null, actionElement)) == null)
                {
                    // If after both tries, the element could not be casted, we throw a conversion exception
                    throw new InternalError("Unable to convert " + actionElement.getClass().getName() + " to " + actionElementType.getName() + " object model.");
                }
            }
            return castedElement;
        }
        catch (Exception e)
        {
            throw new ClassCastException("Unable to find dynamic_cast method in " + actionElementType.getName() + ".");
        }
    }

    private static void CopyActionProperties(BaseActionElement origin, BaseActionElement dest)
    {
        dest.SetId(origin.GetId());
        dest.SetIconUrl(origin.GetIconUrl());
        dest.SetStyle(origin.GetStyle());
        dest.SetTitle(origin.GetTitle());
        dest.SetFallbackContent(origin.GetFallbackContent());
        dest.SetFallbackType(origin.GetFallbackType());
        dest.SetTooltip(origin.GetTooltip());
    }

    /**
     * Deserializes the properties in all base action elements (id, iconUrl, style, title, fallback)
     *
     * @param context ParseContext object passed down as a parameter in the Deserialize method
     * @param value JsonValue object passed down as a parameter in the Deserialize method
     * @param actionElement BaseActionElement to be populated
     */
    public static void deserializeBaseActionProperties(ParseContext context, JsonValue value, BaseActionElement actionElement)
    {
        BaseActionElement baseActionElement = BaseActionElement.DeserializeBaseProperties(context, value);
        CopyActionProperties(baseActionElement, actionElement);
    }

    /**
     * Deserializes the properties in all base action elements (id, iconUrl, style, title, fallback)
     *
     * @param context ParseContext object passed down as a parameter in the Deserialize method
     * @param jsonString Json string to be deserialized (passed down as a parameter in the DeserializeFromString method)
     * @param actionElement BaseActionElement to be populated
     */
    public static void deserializeBaseActionPropertiesFromString(ParseContext context, String jsonString, BaseActionElement actionElement)
    {
        BaseActionElement baseActionElement = BaseActionElement.DeserializeBasePropertiesFromString(context, jsonString);
        CopyActionProperties(baseActionElement, actionElement);
    }

    private static void CopyCardElementProperties(BaseCardElement origin, BaseCardElement dest)
    {
        dest.SetId(origin.GetId());
        dest.SetHeight(origin.GetHeight());
        dest.SetIsVisible(origin.GetIsVisible());
        dest.SetSeparator(origin.GetSeparator());
        dest.SetSpacing(origin.GetSpacing());
        dest.SetFallbackContent(origin.GetFallbackContent());
        dest.SetFallbackType(origin.GetFallbackType());
    }

    /**
     * Deserializes the properties in all base card elements (id, height, isVisible, separator, spacing, fallback)
     *
     * @param context ParseContext object passed down as a parameter in the Deserialize method
     * @param value JsonValue object passed down as a parameter in the Deserialize method
     * @param cardElement BaseCardElement to be populated
     */
    public static void deserializeBaseCardElementProperties(ParseContext context, JsonValue value, BaseCardElement cardElement)
    {
        BaseCardElement baseCardElement = BaseCardElement.DeserializeBaseProperties(context, value);
        CopyCardElementProperties(baseCardElement, cardElement);
    }

    /**
     * Deserializes the properties in all base card elements (id, height, isVisible, separator, spacing, fallback)
     *
     * @param context ParseContext object passed down as a parameter in the DeserializeFromString method
     * @param jsonString Json string to be deserialized (passed down as a parameter in the DeserializeFromString method)
     * @param cardElement BaseCardElement to be populated
     */
    public static void deserializeBaseCardElementPropertiesFromString(ParseContext context, String jsonString, BaseCardElement cardElement)
    {
        BaseCardElement baseCardElement = BaseCardElement.DeserializeBasePropertiesFromString(context, jsonString);
        CopyCardElementProperties(baseCardElement, cardElement);
    }

    private static void CopyInputProperties(BaseInputElement origin, BaseInputElement dest)
    {
        CopyCardElementProperties(origin, dest);
        dest.SetIsRequired(origin.GetIsRequired());
        dest.SetErrorMessage(origin.GetErrorMessage());
        dest.SetLabel(origin.GetLabel());
    }

    /**
     * Deserializes the properties in all input elements (isRequired, errorMessage, label)
     * and the properties found in all base card elements (id, height, isVisible, separator, spacing, fallback)
     *
     * @param context ParseContext object passed down as a parameter in the Deserialize method
     * @param value JsonValue object passed down as a parameter in the Deserialize method
     * @param inputElement BaseInputElement to be populated
     */
    public static void deserializeBaseInputProperties(ParseContext context, JsonValue value, BaseInputElement inputElement)
    {
        BaseInputElement baseInputElement = BaseInputElement.DeserializeBaseProperties(context, value);
        CopyInputProperties(baseInputElement, inputElement);
    }

    /**
     * Deserializes the properties in all input elements (isRequired, errorMessage, label)
     * and the properties found in all base card elements (id, height, isVisible, separator, spacing, fallback)
     *
     * @param context ParseContext object passed down as a parameter in the DeserializeFromString method
     * @param jsonString Json string to be deserialized (passed down as a parameter in the DeserializeFromString method)
     * @param inputElement BaseInputElement to be populated
     */
    public static void deserializeBaseInputPropertiesFromString(ParseContext context, String jsonString, BaseInputElement inputElement)
    {
        BaseInputElement baseInputElement = BaseInputElement.DeserializeBasePropertiesFromString(context, jsonString);
        CopyInputProperties(baseInputElement, inputElement);
    }

    public static long getViewId(View view)
    {
        if(view.getId() == View.NO_ID)
        {
            view.setId(View.generateViewId());
        }
        return view.getId();
    }

    public static Pair<BaseActionElementVector,BaseActionElementVector> splitActionsByMode(@NonNull BaseActionElementVector actionElements, @NonNull HostConfig hostConfig, @NonNull RenderedAdaptiveCard renderedCard)
    {
        //Splits "Primary" and "Secondary" actions.
        long maxActions = hostConfig.GetActions().getMaxActions();
        BaseActionElementVector primaryActionElementVector = new BaseActionElementVector();
        BaseActionElementVector secondaryActionElementVector = new BaseActionElementVector();

        for (BaseActionElement actionElement : actionElements)
        {
            if (actionElement.GetMode() == Mode.Secondary)
            {
                secondaryActionElementVector.add(actionElement);
            }
            else
            {
                primaryActionElementVector.add(actionElement);
            }
        }

        int primaryElementsSize = primaryActionElementVector.size();
        if (primaryElementsSize > maxActions)
        {
            List<BaseActionElement> excessElements = primaryActionElementVector.subList((int) maxActions, primaryElementsSize);
            IOverflowActionRenderer overflowActionRenderer = CardRendererRegistration.getInstance().getOverflowActionRenderer();
            //Add excess elements to the secondary list if flag is enabled.
            if (overflowActionRenderer != null && overflowActionRenderer.shouldAllowMoreThanMaxActionsInOverflowMenu())
            {
                secondaryActionElementVector.addAll(excessElements);
            }
            else
            {
                renderedCard.addWarning(new AdaptiveWarning(AdaptiveWarning.MAX_ACTIONS_EXCEEDED, "A maximum of " + maxActions + " actions are allowed"));
            }
            excessElements.clear();
        }

        return new Pair<>(primaryActionElementVector,secondaryActionElementVector);
    }

    public static void loadIcon(Context context, View view, String iconUrl, String svgInfoURL, HostConfig hostConfig, RenderedAdaptiveCard renderedCard, IconPlacement iconPlacement)
    {
        if (!iconUrl.startsWith(FLUENT_ICON_URL_PREFIX)) {
            ActionElementRendererIconImageLoaderAsync imageLoader = new ActionElementRendererIconImageLoaderAsync(
                renderedCard,
                view,
                hostConfig.GetImageBaseUrl(),
                iconPlacement,
                hostConfig.GetActions().getIconSize(),
                hostConfig.GetSpacing().getDefaultSpacing(),
                context
            );
            imageLoader.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, iconUrl);
        }
        else {
            // intentionally kept this 24 so that it always loads
            // irrespective of size given in host config.
            // it is possible that host config has some size which is not available in CDN.
            long fluentIconSize = 24;
            int color = ((Button) view).getCurrentTextColor();
            String hexColor = String.format("#%06X", (0xFFFFFF & color));
            boolean isFilledStyle = iconUrl.contains("filled");
            ActionElementRendererFluentIconImageLoaderAsync fluentIconLoaderAsync = new ActionElementRendererFluentIconImageLoaderAsync(
                renderedCard,
                fluentIconSize,
                isFilledStyle,
                view,
                hexColor,
                iconPlacement,
                hostConfig.GetSpacing().getDefaultSpacing(),
                hostConfig.GetActions().getIconSize()
            );
            fluentIconLoaderAsync.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, svgInfoURL);
        }
    }

    /**
     * Get the size of the Fluent Icon based on the IconSize enum
     * @param iconSize IconSize enum
     * @return size of the Fluent Icon
     */
    public static long getFluentIconSize(IconSize iconSize) {
        long _size = 24;
        switch (iconSize)
        {
            case xxSmall:
                _size = 16;
                break;
            case xSmall:
                _size = 20;
                break;
            case Small:
                _size = 24;
                break;
            case Standard:
                _size = 32;
                break;
            case Medium:
                _size = 48;
                break;
            case Large:
                _size = 56;
                break;
            case xLarge:
                _size = 72;
                break;
            case xxLarge:
                _size = 96;
                break;
        }
        return _size;
    }

    /**
     * returns the icon size closest to the target icon size from the list of available sizes
     */
    static long getSizeClosestToGivenSize(List<Long> availableSizes, Long targetIconSize) {
        long minDiff = Long.MAX_VALUE;
        long closestSize = targetIconSize;
        for (Long availableSize : availableSizes) {
            long diff = Math.abs(availableSize - targetIconSize);
            if (diff < minDiff) {
                minDiff = diff;
                closestSize = availableSize;
            }
        }
        return closestSize;
    }

    /**
     * format: "<fluentIconCdnRoot><fluentIconCdnPath><Icon Name>/<IconName>.json"
     * https://res-1.cdn.office.net/assets/fluentui-react-icons/2.0.226/Rss/Rss.json
     **/
    public static String getSvgInfoUrl(String svgPath) {
        String fluentIconCdnRoot = FeatureFlagResolverUtility.INSTANCE.fetchFluentIconCdnRoot();
        String fluentIconCdnPath = FeatureFlagResolverUtility.INSTANCE.fetchFluentIconCdnPath();
        return String.format("%s/%s/%s", fluentIconCdnRoot, fluentIconCdnPath, svgPath);
    }

    public static String getUnavailableIconSvgInfoUrl() {
        String unavailableIconName = "Square";
        String fluentIconCdnRoot = FeatureFlagResolverUtility.INSTANCE.fetchFluentIconCdnRoot();
        String fluentIconCdnPath = FeatureFlagResolverUtility.INSTANCE.fetchFluentIconCdnPath();
        return String.format("%s/%s/%s/%s.json", fluentIconCdnRoot, fluentIconCdnPath, unavailableIconName, unavailableIconName);
    }

    private static final String FLUENT_ICON_URL_PREFIX = "icon:";

    public static String getOpenUrlAnnouncement(Context context, String urlTitle) {
        return context.getResources().getString(R.string.open_url_announcement, urlTitle);
    }
}
