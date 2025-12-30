package io.adaptivecards.adaptivecardsv2.objectmodel.utils

import kotlinx.serialization.Serializable

@Serializable
class InternalId private constructor(val internalId: UInt) {

    // Public no-arg constructor creates an "invalid" ID.
    constructor() : this(INVALID)

    // Returns the internal ID as a UInt.
    fun hash(): UInt = internalId

    // Helper function to compare against a UInt value.
    fun equalsUInt(other: UInt): Boolean = internalId == other

    override fun equals(other: Any?): Boolean {
        return when (other) {
            is InternalId -> internalId == other.internalId
            is UInt -> internalId == other
            else -> false
        }
    }

    override fun hashCode(): Int = internalId.toInt()

    companion object {
        // Static variable to hold the current internal ID.
        private var s_currentInternalId: UInt = 0u

        // Constant representing an invalid ID.
        const val INVALID: UInt = 0u

        // Generates and returns the next InternalId.
        fun next(): InternalId {
            s_currentInternalId++
            return InternalId(s_currentInternalId)
        }

        // Returns the current InternalId (without advancing).
        fun current(): InternalId = InternalId(s_currentInternalId)
    }
}

// Kotlin equivalent of InternalIdKeyHash functor.
object InternalIdKeyHash {
    operator fun invoke(internalId: InternalId): Int = internalId.hash().toInt()
}
