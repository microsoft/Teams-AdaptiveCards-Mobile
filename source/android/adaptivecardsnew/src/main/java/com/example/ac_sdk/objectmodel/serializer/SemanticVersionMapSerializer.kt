// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
package com.example.ac_sdk.objectmodel.serializer

import com.example.ac_sdk.objectmodel.utils.SemanticVersion
import kotlinx.serialization.KSerializer
import kotlinx.serialization.builtins.MapSerializer
import kotlinx.serialization.builtins.serializer
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder

object SemanticVersionMapSerializer : KSerializer<Map<String, SemanticVersion>> {
    private val delegate = MapSerializer(String.serializer(), SemanticVersionSerializer)

    override val descriptor: SerialDescriptor = delegate.descriptor

    override fun serialize(encoder: Encoder, value: Map<String, SemanticVersion>) {
        delegate.serialize(encoder, value)
    }

    override fun deserialize(decoder: Decoder): Map<String, SemanticVersion> {
        return delegate.deserialize(decoder)
    }
}
