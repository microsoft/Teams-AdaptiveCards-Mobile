package com.example.ac_sdk.objectmodel.utils

import kotlinx.serialization.Serializable

@Serializable
data class SemanticVersion(
    val major: Int = 0,
    val minor: Int = 0,
    val patch: Int = 0,
    val revision: Int = 0
) {

    override fun toString(): String {
        return "$major.$minor.$patch.$revision"
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is SemanticVersion) return false

        return major == other.major &&
                minor == other.minor &&
                patch == other.patch &&
                revision == other.revision
    }

    override fun hashCode(): Int {
        var result = major
        result = 31 * result + minor
        result = 31 * result + patch
        result = 31 * result + revision
        return result
    }

    operator fun compareTo(other: SemanticVersion): Int {
        return when {
            major != other.major -> major.compareTo(other.major)
            minor != other.minor -> minor.compareTo(other.minor)
            patch != other.patch -> patch.compareTo(other.patch)
            else -> revision.compareTo(other.revision)
        }
    }
}