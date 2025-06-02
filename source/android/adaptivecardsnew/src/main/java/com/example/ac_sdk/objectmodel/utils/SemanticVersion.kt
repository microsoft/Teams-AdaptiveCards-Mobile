package com.example.ac_sdk.objectmodel.utils

import kotlinx.serialization.Serializable

@Serializable
data class SemanticVersion(
    val major: Int = 0,
    val minor: Int = 0,
    val build: Int = 0,
    val revision: Int = 0
) {

    override fun toString(): String {
        return "$major.$minor.$build.$revision"
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is SemanticVersion) return false

        return major == other.major &&
                minor == other.minor &&
                build == other.build &&
                revision == other.revision
    }

    override fun hashCode(): Int {
        var result = major
        result = 31 * result + minor
        result = 31 * result + build
        result = 31 * result + revision
        return result
    }

    operator fun compareTo(other: SemanticVersion): Int {
        return when {
            major != other.major -> major.compareTo(other.major)
            minor != other.minor -> minor.compareTo(other.minor)
            build != other.build -> build.compareTo(other.build)
            else -> revision.compareTo(other.revision)
        }
    }
}