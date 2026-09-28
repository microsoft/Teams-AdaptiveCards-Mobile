// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.http;

import android.text.TextUtils;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.InetAddress;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.net.URLDecoder;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import static java.net.HttpURLConnection.HTTP_MOVED_PERM;
import static java.net.HttpURLConnection.HTTP_MOVED_TEMP;
import static java.net.HttpURLConnection.HTTP_SEE_OTHER;

public abstract class HttpRequestHelper
{
    private static final int CONNECT_TIMEOUT_MILLISECONDS = 10_000;
    private static final int READ_TIMEOUT_MILLISECONDS = 15_000;
    private static final int MAX_REDIRECTS = 5;
    private static final int MAX_RESPONSE_BYTES = 10 * 1024 * 1024;

    private static HttpURLConnection connect(String url, String method, Map<String, String> requestProperty, boolean doOutput /* for post/puts */, boolean useCaches)
            throws MalformedURLException, URISyntaxException, IOException
    {
        URL netURL = validateUrl(url);

        HttpURLConnection conn = (HttpURLConnection) netURL.openConnection();
        conn.setRequestMethod(method);
        conn.setInstanceFollowRedirects(false);
        conn.setDoOutput(doOutput);
        conn.setUseCaches(useCaches);
        conn.setConnectTimeout(CONNECT_TIMEOUT_MILLISECONDS);
        conn.setReadTimeout(READ_TIMEOUT_MILLISECONDS);

        if (requestProperty != null)
        {
            // Set HTTP header
            for (Map.Entry<String, String> entry : requestProperty.entrySet())
            {
                conn.setRequestProperty(entry.getKey(), entry.getValue());
            }
        }

        return conn;
    }

    static URL validateUrl(String url) throws IOException, URISyntaxException
    {
        URL netURL = new URL(URLDecoder.decode(url, "UTF-8"));
        URI uri = new URI(netURL.getProtocol(), netURL.getUserInfo(), netURL.getHost(), netURL.getPort(), netURL.getPath(), netURL.getQuery(), netURL.getRef());
        netURL = uri.toURL();

        if (!"https".equalsIgnoreCase(netURL.getProtocol()))
        {
            throw new IOException("Only HTTPS resource URLs are supported by the default loader");
        }

        if (netURL.getUserInfo() != null || netURL.getHost().isEmpty())
        {
            throw new IOException("Resource URL must not contain user information and must include a host");
        }

        int port = netURL.getPort();
        if (port != -1 && port != 443)
        {
            throw new IOException("Only the default HTTPS port is supported by the default loader");
        }

        for (InetAddress address : InetAddress.getAllByName(netURL.getHost()))
        {
            if (isNonPublicAddress(address))
            {
                throw new IOException("Resource URL resolves to a non-public address");
            }
        }

        return netURL;
    }

    private static boolean isNonPublicAddress(InetAddress address)
    {
        if (address.isAnyLocalAddress() ||
            address.isLoopbackAddress() ||
            address.isLinkLocalAddress() ||
            address.isSiteLocalAddress() ||
            address.isMulticastAddress())
        {
            return true;
        }

        byte[] addressBytes = address.getAddress();
        return addressBytes.length == 16 && (addressBytes[0] & 0xFE) == 0xFC;
    }

    private static byte[] copyInputStreamToByteArray(InputStream inputStream)
            throws IOException
    {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();

        final int bufferSize = 4096;
        byte[] buffer = new byte[bufferSize];
        int size;
        while ((size = inputStream.read(buffer)) != -1)
        {
            if (byteArrayOutputStream.size() + size > MAX_RESPONSE_BYTES)
            {
                throw new IOException("Resource response exceeds the maximum allowed size");
            }
            byteArrayOutputStream.write(buffer, 0, size);
        }

        return byteArrayOutputStream.toByteArray();
    }

    public static byte[] get(String url, Map<String, String> requestProperty)
            throws MalformedURLException, URISyntaxException, IOException
    {
        return get(url, requestProperty, 0);
    }

    private static byte[] get(String url, Map<String, String> requestProperty, int redirectCount)
            throws MalformedURLException, URISyntaxException, IOException
    {
        HttpURLConnection conn = connect(url, HTTP_METHOD_GET, requestProperty, false, true);
        try
        {
            conn.connect();
            int code = conn.getResponseCode();
            String location = conn.getHeaderField("Location");
            if (isRedirect(code) && !TextUtils.isEmpty(location))
            {
                URL redirectUrl = new URL(conn.getURL(), location);
                return getRedirect(redirectUrl, conn.getURL(), requestProperty, redirectCount);
            }

            try (BufferedInputStream inputStream = new BufferedInputStream(conn.getInputStream()))
            {
                return copyInputStreamToByteArray(inputStream);
            }
        }
        finally
        {
            conn.disconnect();
        }
    }

    public static byte[] get(String url)
            throws MalformedURLException, URISyntaxException, IOException
    {
        return get(url, null);
    }

    public static void query(String url, Map<String, String> requestProperty)
            throws MalformedURLException, URISyntaxException, IOException
    {
        query(url, requestProperty, 0);
    }

    private static void query(String url, Map<String, String> requestProperty, int redirectCount)
            throws MalformedURLException, URISyntaxException, IOException
    {
        HttpURLConnection conn = connect(url, HTTP_METHOD_GET, requestProperty, false, true);
        try
        {
            conn.connect();
            int code = conn.getResponseCode();
            String location = conn.getHeaderField("Location");
            if (isRedirect(code) && !TextUtils.isEmpty(location))
            {
                URL redirectUrl = new URL(conn.getURL(), location);
                queryRedirect(redirectUrl, conn.getURL(), requestProperty, redirectCount);
            }
        }
        finally
        {
            conn.disconnect();
        }
    }

    public static void query(String url)
            throws MalformedURLException, URISyntaxException, IOException
    {
        query(url, null);
    }

    private static  byte[] requestBody(String url, String method, Map<String, String> requestProperty, String body)
            throws MalformedURLException, URISyntaxException, IOException
    {
        byte[] bodyBytes = body.getBytes("UTF-8");
        requestProperty.put("Content-Length", String.valueOf(bodyBytes.length));
        HttpURLConnection conn = connect(url, method, requestProperty, true, false);

        OutputStream outputStream = conn.getOutputStream();
        outputStream.write(bodyBytes);

        BufferedInputStream inputStream = new BufferedInputStream(conn.getInputStream());
        byte[] bytes = copyInputStreamToByteArray(inputStream);

        outputStream.close();
        inputStream.close();

        return bytes;
    }

    public static byte[] post(String url, Map<String, String> requestProperty, String body)
            throws MalformedURLException, URISyntaxException, IOException
    {
        return requestBody(url, HTTP_METHOD_POST, requestProperty, body);
    }

    public static byte[] put(String url, Map<String, String> requestProperty, String body)
            throws MalformedURLException, URISyntaxException, IOException
    {
        return requestBody(url, HTTP_METHOD_PUT, requestProperty, body);
    }

    private static boolean isRedirect(int code)
    {
        return code == HTTP_MOVED_PERM || code == HTTP_MOVED_TEMP || code == HTTP_SEE_OTHER;
    }

    private static byte[] getRedirect(URL redirectUrl, URL sourceUrl, Map<String, String> requestProperty, int redirectCount)
            throws IOException, URISyntaxException
    {
        if (redirectCount >= MAX_REDIRECTS)
        {
            throw new IOException("Resource URL exceeded the maximum redirect count");
        }
        return get(redirectUrl.toString(), headersForRedirect(sourceUrl, redirectUrl, requestProperty), redirectCount + 1);
    }

    private static void queryRedirect(URL redirectUrl, URL sourceUrl, Map<String, String> requestProperty, int redirectCount)
            throws IOException, URISyntaxException
    {
        if (redirectCount >= MAX_REDIRECTS)
        {
            throw new IOException("Resource URL exceeded the maximum redirect count");
        }
        query(redirectUrl.toString(), headersForRedirect(sourceUrl, redirectUrl, requestProperty), redirectCount + 1);
    }

    private static Map<String, String> headersForRedirect(URL sourceUrl, URL redirectUrl, Map<String, String> requestProperty)
    {
        if (requestProperty == null || sameOrigin(sourceUrl, redirectUrl))
        {
            return requestProperty;
        }

        Map<String, String> headers = new HashMap<>(requestProperty);
        headers.entrySet().removeIf(entry ->
            "authorization".equalsIgnoreCase(entry.getKey()) ||
            "cookie".equalsIgnoreCase(entry.getKey()) ||
            "proxy-authorization".equalsIgnoreCase(entry.getKey()));
        return Collections.unmodifiableMap(headers);
    }

    private static boolean sameOrigin(URL first, URL second)
    {
        return first.getProtocol().equalsIgnoreCase(second.getProtocol()) &&
            first.getHost().equalsIgnoreCase(second.getHost()) &&
            effectivePort(first) == effectivePort(second);
    }

    private static int effectivePort(URL url)
    {
        return url.getPort() == -1 ? url.getDefaultPort() : url.getPort();
    }

    public static final String HTTP_METHOD_GET = "GET";
    public static final String HTTP_METHOD_POST = "POST";
    public static final String HTTP_METHOD_PUT = "PUT";
}
