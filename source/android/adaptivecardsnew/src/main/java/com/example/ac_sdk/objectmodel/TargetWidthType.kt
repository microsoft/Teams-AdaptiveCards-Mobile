package com.example.ac_sdk.objectmodel

enum class TargetWidthType(val key: String) {
    Default("Default"),
    VeryNarrow("veryNarrow"),
    Narrow("narrow"),
    Standard("standard"),
    Wide("wide"),
    AtMostVeryNarrow("atMost:veryNarrow"),
    AtMostNarrow("atMost:narrow"),
    AtMostStandard("atMost:standard"),
    AtMostWide("atMost:wide"),
    AtLeastVeryNarrow("atLeast:veryNarrow"),
    AtLeastNarrow("atLeast:narrow"),
    AtLeastStandard("atLeast:standard"),
    AtLeastWide("atLeast:wide")
}