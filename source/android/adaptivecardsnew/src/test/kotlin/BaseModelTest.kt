package com.example.ac_sdk

import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.json.Json

open class BaseModelTest {
    @OptIn(ExperimentalSerializationApi::class)
    protected val json = Json {
        classDiscriminator = "type"
        ignoreUnknownKeys = true
        encodeDefaults = true
        decodeEnumsCaseInsensitive = true
    }
}