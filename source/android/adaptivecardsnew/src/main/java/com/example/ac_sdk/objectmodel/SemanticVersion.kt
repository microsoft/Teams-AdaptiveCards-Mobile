package com.example.ac_sdk.objectmodel

import java.util.regex.Pattern

class SemanticVersion(version: String) {

    val major: Int
    val minor: Int
    val build: Int
    val revision: Int

    init {
        val versionPattern = Pattern.compile("^([\\d]+)(?:\\.([\\d]+))?(?:\\.([\\d]+))?(?:\\.([\\d]+))?$")
        val matcher = versionPattern.matcher(version)

        if (!matcher.matches()) {
            throw IllegalArgumentException("Semantic version invalid: $version")
        }

        major = matcher.group(1)?.toIntOrNull() ?: 0
        minor = matcher.group(2)?.toIntOrNull() ?: 0
        build = matcher.group(3)?.toIntOrNull() ?: 0
        revision = matcher.group(4)?.toIntOrNull() ?: 0
    }

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

    operator fun component1() = major
    operator fun component2() = minor
    operator fun component3() = build
    operator fun component4() = revision
}