// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer

import android.content.Context
import android.graphics.drawable.Drawable
import io.adaptivecards.objectmodel.ReferenceIcon

interface IDrawableResolver {

    fun getDrawableForReferenceIcon(context: Context, icon: ReferenceIcon) : Drawable?
}