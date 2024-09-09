// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer

/**
 * This interface exposes methods to fetch the feature flag values.
 **/
interface IFeatureFlagResolver {

    fun getEcsSettingAsBoolean(key: String): Boolean

    fun getEcsSettingAsString(key: String): String?
}
