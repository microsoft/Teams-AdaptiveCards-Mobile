// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.adaptivecardssample.CustomObjects;


import android.content.Context;
import android.graphics.drawable.Drawable;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;

import io.adaptivecards.adaptivecardssample.R;
import io.adaptivecards.objectmodel.ReferenceIcon;
import io.adaptivecards.renderer.IDrawableResolver;

public class DrawableResolver implements IDrawableResolver {

    @Nullable
    @Override
    public Drawable getDrawableForReferenceIcon(@NonNull Context context, @NonNull ReferenceIcon icon) {
        @DrawableRes Integer drawableRes = switch (icon) {
            case AdobeIllustrator -> R.drawable.ic_icon_adobe_illustrator;
            case AdobePhotoshop -> R.drawable.ic_icon_adobe_photoshop;
            case AdobeInDesign -> R.drawable.ic_icon_adobe_indesign;
            case AdobeFlash -> R.drawable.ic_icon_invalid;

            case MsExcel -> R.drawable.ic_icon_ms_excel;
            case MsLoop -> R.drawable.ic_icon_ms_loop;
            case MsVisio -> R.drawable.ic_icon_ms_visio;
            case MsOneNote -> R.drawable.ic_icon_ms_onenote;
            case MsPowerPoint -> R.drawable.ic_icon_ms_powerpoint;
            case MsSharePoint -> R.drawable.ic_icon_ms_sharepoint;
            case MsWhiteboard -> R.drawable.ic_icon_ms_whiteboard;
            case MsWord -> R.drawable.ic_icon_ms_word;

            case Sketch -> R.drawable.ic_icon_sketch;

            case Code -> R.drawable.ic_icon_code;
            case Gif -> R.drawable.ic_icon_gif;
            case Image -> R.drawable.ic_icon_image;
            case Pdf -> R.drawable.ic_icon_pdf;
            case Sound -> R.drawable.ic_icon_sound;
            case Text -> R.drawable.ic_icon_text;
            case Video -> R.drawable.ic_icon_video;
            case Zip -> R.drawable.ic_icon_zip;
        };

        return ContextCompat.getDrawable(context, drawableRes);
    }
}
