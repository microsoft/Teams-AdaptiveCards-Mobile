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

    @Override
    public String getEcsSettingAsString(@NonNull String key) {
        // This is a sample implementation. The host app should implement this method to return the correct value of the feature flag.
        if (key.equals("adaptiveCard/fluentIconCdnRoot")) {
            return "https://res-1.cdn.office.net";
        } else if (key.equals("adaptiveCard/fluentIconCdnPath")) {
            return "assets/fluentui-react-icons/2.0.226";
        }
        return "";
    }
}
