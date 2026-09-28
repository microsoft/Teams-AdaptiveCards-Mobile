// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.http;

import android.net.Uri;
import android.text.TextUtils;

import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.Locale;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;

/**
 * Central, fail-closed policy for URLs that originate from card payloads.
 *
 * <p>Card content is authored remotely and must be treated as untrusted. Any URL taken from a card
 * is only acted upon when its scheme appears on an allow list. Hosts that legitimately need to
 * handle additional schemes (for example an app specific deep link) must opt in explicitly by
 * calling {@link #allowNavigationScheme(String)} or {@link #allowResourceScheme(String)}.
 */
public final class UrlPolicy
{
    /** Schemes that may be handed to the platform for navigation (for example {@code Intent.ACTION_VIEW}). */
    private static final Set<String> DEFAULT_NAVIGATION_SCHEMES =
        Collections.unmodifiableSet(new HashSet<>(Arrays.asList("https")));

    /** Schemes that may be dereferenced to fetch a resource such as an image or a media stream. */
    private static final Set<String> DEFAULT_RESOURCE_SCHEMES =
        Collections.unmodifiableSet(new HashSet<>(Arrays.asList("https", "data")));

    private static final Set<String> s_additionalNavigationSchemes = new CopyOnWriteArraySet<>();
    private static final Set<String> s_additionalResourceSchemes = new CopyOnWriteArraySet<>();

    private UrlPolicy()
    {
    }

    /**
     * Opts in to an additional navigation scheme. Hosts should only register schemes they fully
     * control, because a remote card author decides both the scheme and the rest of the URL.
     */
    public static void allowNavigationScheme(String scheme)
    {
        if (!TextUtils.isEmpty(scheme))
        {
            s_additionalNavigationSchemes.add(normalize(scheme));
        }
    }

    /**
     * Opts in to an additional resource scheme. See {@link #allowNavigationScheme(String)} for the
     * caveats that apply.
     */
    public static void allowResourceScheme(String scheme)
    {
        if (!TextUtils.isEmpty(scheme))
        {
            s_additionalResourceSchemes.add(normalize(scheme));
        }
    }

    /** Removes every host registered scheme, restoring the built in defaults. */
    public static void clearAdditionalSchemes()
    {
        s_additionalNavigationSchemes.clear();
        s_additionalResourceSchemes.clear();
    }

    /** Returns true when {@code url} may be handed to the platform for navigation. */
    public static boolean isAllowedNavigationUrl(String url)
    {
        return isAllowed(url, DEFAULT_NAVIGATION_SCHEMES, s_additionalNavigationSchemes);
    }

    /** Returns true when {@code url} may be dereferenced to fetch a resource. */
    public static boolean isAllowedResourceUrl(String url)
    {
        return isAllowed(url, DEFAULT_RESOURCE_SCHEMES, s_additionalResourceSchemes);
    }

    private static boolean isAllowed(String url, Collection<String> defaults, Collection<String> additional)
    {
        String scheme = schemeOf(url);
        if (scheme == null)
        {
            // Either a relative reference or a URL we could not parse. Relative references must be
            // resolved against a trusted base URL and re-checked by the caller before being used.
            return false;
        }

        return defaults.contains(scheme) || additional.contains(scheme);
    }

    /**
     * Extracts the normalized scheme of {@code url}, or null when the value is empty, relative, or
     * cannot be parsed.
     */
    public static String schemeOf(String url)
    {
        if (TextUtils.isEmpty(url))
        {
            return null;
        }

        // Uri.parse is lenient, so guard against embedded control characters and leading whitespace
        // that could cause the platform to interpret a scheme differently than we do here.
        for (int i = 0; i < url.length(); ++i)
        {
            if (url.charAt(i) <= ' ' || url.charAt(i) == '\u007f')
            {
                return null;
            }
        }

        String scheme = Uri.parse(url).getScheme();
        return TextUtils.isEmpty(scheme) ? null : normalize(scheme);
    }

    private static String normalize(String scheme)
    {
        return scheme.trim().toLowerCase(Locale.ROOT);
    }
}
