// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.adaptivecardssample.CustomObjects;

import androidx.annotation.NonNull;

import io.adaptivecards.renderer.IFeatureFlagResolver;

public class FeatureFlagResolver implements IFeatureFlagResolver {

    @Override
    public boolean getEcsSettingAsBoolean(@NonNull String key) {
        // This is a sample implementation. The host app should implement this method to return the correct value of the feature flag.
        return key.equals("adaptiveCard/isFlowLayoutEnabled") || key.equals("adaptiveCard/isItemFitToFillEnabledForColumn");
    }
}
