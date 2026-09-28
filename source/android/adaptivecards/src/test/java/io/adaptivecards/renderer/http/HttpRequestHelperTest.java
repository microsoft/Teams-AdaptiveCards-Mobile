// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer.http;

import org.junit.Test;

import java.io.IOException;

import static org.junit.Assert.assertEquals;

public class HttpRequestHelperTest
{
    @Test
    public void acceptsPublicHttpsUrl() throws Exception
    {
        assertEquals("https", HttpRequestHelper.validateUrl("https://8.8.8.8/image.png").getProtocol());
    }

    @Test(expected = IOException.class)
    public void rejectsHttpUrl() throws Exception
    {
        HttpRequestHelper.validateUrl("http://example.com/image.png");
    }

    @Test(expected = IOException.class)
    public void rejectsLoopbackUrl() throws Exception
    {
        HttpRequestHelper.validateUrl("https://127.0.0.1/image.png");
    }

    @Test(expected = IOException.class)
    public void rejectsPrivateAddressUrl() throws Exception
    {
        HttpRequestHelper.validateUrl("https://10.0.0.1/image.png");
    }

    @Test(expected = IOException.class)
    public void rejectsIpv6UniqueLocalAddressUrl() throws Exception
    {
        HttpRequestHelper.validateUrl("https://[fd00::1]/image.png");
    }

    @Test(expected = IOException.class)
    public void rejectsNonDefaultPort() throws Exception
    {
        HttpRequestHelper.validateUrl("https://example.com:8443/image.png");
    }
}
