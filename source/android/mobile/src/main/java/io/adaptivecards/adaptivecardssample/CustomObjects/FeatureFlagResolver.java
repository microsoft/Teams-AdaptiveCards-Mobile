// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.adaptivecardssample.CustomObjects;

import androidx.annotation.NonNull;

import io.adaptivecards.renderer.IFeatureFlagResolver;
import io.adaptivecards.renderer.Util;

public class FeatureFlagResolver implements IFeatureFlagResolver {

    @Override
    public boolean getEcsSettingAsBoolean(@NonNull String key) {
        // This is a sample implementation. The host app should implement this method to return the correct value of the feature flag.
        return key.equals(Util.IS_FLOW_LAYOUT_ENABLED) || key.equals(Util.IS_ITEM_FIT_TO_FILL_ENABLED_FOR_COLUMN);
    }
}
