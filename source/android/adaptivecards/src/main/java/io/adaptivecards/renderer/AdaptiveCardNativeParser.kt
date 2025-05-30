package io.adaptivecards.renderer

import android.util.Log
import com.example.ac_sdk.AdaptiveCardParser
import com.example.ac_sdk.objectmodel.parser.ParseContext
import io.adaptivecards.objectmodel.AdaptiveCard
import io.adaptivecards.objectmodel.ParseResult
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject

object AdaptiveCardNativeParser {

    fun deserializeFromString(
        stringifiedAdaptiveCard: String,
        rendererVersion: String,
        optimizeParsing: Boolean,
        context: io.adaptivecards.objectmodel.ParseContext,
        coroutineScope: CoroutineScope?
    ): ParseResult {
        val legacyParseResult = AdaptiveCard.DeserializeFromString(
            stringifiedAdaptiveCard,
            AdaptiveCardRenderer.VERSION,
            context
        );

        if (optimizeParsing) {
            coroutineScope?.launch {
                deserializeAndCompareInBackground(
                    stringifiedAdaptiveCard,
                    legacyParseResult,
                    rendererVersion,
                    ParseContext()
                )
            }
        }

        return legacyParseResult

    }

    suspend fun deserializeAndCompareInBackground(
        stringifiedAdaptiveCard: String,
        legacyParseResult: ParseResult,
        rendererVersion: String,
        context: ParseContext,
    ) = withContext(Dispatchers.Default) {
        val nativeParseResult = AdaptiveCardParser.deserializeFromString(
            stringifiedAdaptiveCard,
            rendererVersion,
            context
        )
        val r = nativeParseResult.adaptiveCard.serialize()
        Log.d("AdaptiveCardNativeParser", "nativeParseResult: $r")

        if (nativeParseResult.toString() != legacyParseResult.toString()) {
            val nativeJson = JSONObject(nativeParseResult.adaptiveCard.serialize())
            val legacyJson = JSONObject(legacyParseResult.GetAdaptiveCard().Serialize())
            compareJsonObjects(nativeJson, legacyJson)
        }

    }

    private fun compareJsonObjects(
        json1: JSONObject,
        json2: JSONObject,
        path: String = ""
    ): List<String> {
        val diffs = mutableListOf<String>()
        val keys = (json1.keys().asSequence().toSet() + json2.keys().asSequence().toSet())
        for (key in keys) {
            val newPath = if (path.isEmpty()) key else "$path.$key"
            if (!json1.has(key)) {
                diffs.add("Key missing in json1: $newPath")
            } else if (!json2.has(key)) {
                diffs.add("Key missing in json2: $newPath")
            } else {
                val value1 = json1.get(key)
                val value2 = json2.get(key)
                when {
                    value1 is JSONObject && value2 is JSONObject ->
                        diffs.addAll(compareJsonObjects(value1, value2, newPath))

                    value1 is JSONArray && value2 is JSONArray ->
                        diffs.addAll(compareJsonArrays(value1, value2, newPath))

                    value1 != value2 ->
                        diffs.add("Value mismatch at $newPath: '$value1' vs '$value2'")
                }
            }
        }
        return diffs
    }

    private fun compareJsonArrays(
        array1: JSONArray,
        array2: JSONArray,
        path: String
    ): List<String> {
        val diffs = mutableListOf<String>()
        val maxLength = maxOf(array1.length(), array2.length())
        for (i in 0 until maxLength) {
            val newPath = "$path[$i]"
            if (i >= array1.length()) {
                diffs.add("Index $i missing in array1 at $newPath")
            } else if (i >= array2.length()) {
                diffs.add("Index $i missing in array2 at $newPath")
            } else {
                val value1 = array1[i]
                val value2 = array2[i]
                when {
                    value1 is JSONObject && value2 is JSONObject ->
                        diffs.addAll(compareJsonObjects(value1, value2, newPath))

                    value1 is JSONArray && value2 is JSONArray ->
                        diffs.addAll(compareJsonArrays(value1, value2, newPath))

                    value1 != value2 ->
                        diffs.add("Value mismatch at $newPath: '$value1' vs '$value2'")
                }
            }
        }
        return diffs
    }
}