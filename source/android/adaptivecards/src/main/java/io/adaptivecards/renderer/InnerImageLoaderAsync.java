// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer;

import android.graphics.Bitmap;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.adaptivecards.renderer.http.HttpRequestResult;

public abstract class InnerImageLoaderAsync extends GenericImageLoaderAsync
{
    protected View m_view; // button and imageview inherit from this

    public InnerImageLoaderAsync(@NonNull RenderedAdaptiveCard renderedCard, View containerView, String imageBaseUrl, int maxWidth)
    {
        super(renderedCard, imageBaseUrl, maxWidth);

        m_view = containerView;
    }

    @Override
    protected @Nullable HttpRequestResult<Bitmap> doInBackground(String... args)
    {
        if (args.length == 0)
        {
            return null;
        }
        return loadImage(args[0], m_view.getContext());
    }

    void onSuccessfulPostExecute(Bitmap bitmap)
    {
        renderBitmap(bitmap);
    }

    protected abstract void renderBitmap(Bitmap bitmap);
}
