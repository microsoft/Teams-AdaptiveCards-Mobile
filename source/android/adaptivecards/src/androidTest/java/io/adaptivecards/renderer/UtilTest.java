// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package io.adaptivecards.renderer;

import junit.framework.TestCase;

import org.junit.Test;

import java.util.Arrays;
import java.util.List;

/**
 * Tests against [Util.java]
 */
public class UtilTest extends TestCase {

    @Test
    public void testGetSizeClosestToGivenSize_1() {
        List<Long> availableSizes = Arrays.asList(16L, 32L);
        long targetSize = 24L;
        long closestSize = Util.getSizeClosestToGivenSize(availableSizes, targetSize);
        assertEquals(16L, closestSize);
    }

    @Test
    public void testGetSizeClosestToGivenSize_2() {
        List<Long> availableSizes = Arrays.asList(12L, 16L, 48L);
        long targetSize = 32L;
        long closestSize = Util.getSizeClosestToGivenSize(availableSizes, targetSize);
        assertEquals(16L, closestSize);
    }

    @Test
    public void testGetSizeClosestToGivenSize_3() {
        List<Long> availableSizes = Arrays.asList(20L, 24L, 32L, 48L);
        long targetSize = 16L;
        long closestSize = Util.getSizeClosestToGivenSize(availableSizes, targetSize);
        assertEquals(20L, closestSize);
    }

    @Test
    public void testGetSizeClosestToGivenSize_4() {
        List<Long> availableSizes = Arrays.asList(12L, 16L, 20L, 24L, 32L);
        long targetSize = 48L;
        long closestSize = Util.getSizeClosestToGivenSize(availableSizes, targetSize);
        assertEquals(32L, closestSize);
    }

    @Test
    public void testGetSizeClosestToGivenSize_5() {
        List<Long> availableSizes = Arrays.asList(12L, 16L, 20L, 24L, 28L, 32L, 48L);
        long targetSize = 24L;
        long closestSize = Util.getSizeClosestToGivenSize(availableSizes, targetSize);
        assertEquals(24L, closestSize);
    }
}
