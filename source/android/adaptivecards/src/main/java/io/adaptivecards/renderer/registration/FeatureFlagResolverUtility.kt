// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.registration

/**
 * This utility class manages the feature flags used in the application.
 * It provides methods to fetch the values of the feature flags.
 */
object FeatureFlagResolverUtility {

    private const val IS_FLOW_LAYOUT_ENABLED = "adaptiveCard/isFlowLayoutEnabled"
    private const val IS_GRID_LAYOUT_ENABLED = "adaptiveCard/isGridLayoutEnabled"
    private const val IS_ITEM_FIT_TO_FILL_ENABLED_FOR_COLUMN = "adaptiveCard/isItemFitToFillEnabledForColumn"
    private const val FLUENT_ICON_CDN_ROOT_ECS_KEY = "adaptiveCard/fluentIconCdnRoot"
    private const val FLUENT_ICON_CDN_PATH_ECS_KEY = "adaptiveCard/fluentIconCdnPath"

    fun isFlowLayoutEnabled(): Boolean {
        val featureFlagResolver = CardRendererRegistration.getInstance().featureFlagResolver
        return featureFlagResolver?.getEcsSettingAsBoolean(IS_FLOW_LAYOUT_ENABLED)
            ?: false
    }

    fun isGridLayoutEnabled(): Boolean {
        val featureFlagResolver = CardRendererRegistration.getInstance().featureFlagResolver
        return featureFlagResolver?.getEcsSettingAsBoolean(IS_GRID_LAYOUT_ENABLED)
            ?: false
    }

    fun isItemFitToFillEnabledForColumn(): Boolean {
        val featureFlagResolver = CardRendererRegistration.getInstance().featureFlagResolver
        return featureFlagResolver?.getEcsSettingAsBoolean(IS_ITEM_FIT_TO_FILL_ENABLED_FOR_COLUMN)
            ?: false
    }

    fun fetchFluentIconCdnRoot(): String {
        val featureFlagResolver = CardRendererRegistration.getInstance().featureFlagResolver
        return featureFlagResolver?.getEcsSettingAsString(FLUENT_ICON_CDN_ROOT_ECS_KEY)
            ?: "https://res-1.cdn.office.net"
    }

    fun fetchFluentIconCdnPath(): String {
        val featureFlagResolver = CardRendererRegistration.getInstance().featureFlagResolver
        return featureFlagResolver?.getEcsSettingAsString(FLUENT_ICON_CDN_PATH_ECS_KEY)
            ?: "assets/fluentui-react-icons/2.0.226"
    }
}
