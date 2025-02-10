package com.example.ac_sdk

import kotlinx.serialization.json.Json

open class BaseModelTest {
    protected val json = Json {
        classDiscriminator = "type"
        ignoreUnknownKeys = true
        encodeDefaults = true
    }
}