package com.example.ac_sdk.objectmodel


data class TokenExchangeResource(
    var id: String = "",
    var uri: String = "",
    var providerId: String = ""
) {
    fun shouldSerialize(): Boolean {
        return id.isNotEmpty() || uri.isNotEmpty() || providerId.isNotEmpty()
    }
}