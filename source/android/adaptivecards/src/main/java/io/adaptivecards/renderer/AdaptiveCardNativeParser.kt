package io.adaptivecards.renderer

import android.util.Log
import com.example.ac_sdk.AdaptiveCardParser
import com.example.ac_sdk.objectmodel.parser.ParseContext
import io.adaptivecards.objectmodel.AdaptiveCard
import io.adaptivecards.objectmodel.AdaptiveCardParseWarning
import io.adaptivecards.objectmodel.ParseResult
import io.adaptivecards.objectmodel.WarningStatusCode
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
                val adaptiveCardDiffWarnings = deserializeAndCompareInBackground(
                    stringifiedAdaptiveCard,
                    legacyParseResult,
                    rendererVersion,
                    ParseContext()
                )
            }
        }

        return legacyParseResult
    }

    private suspend fun deserializeAndCompareInBackground(
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
            return@withContext compareJsonObjects(nativeJson, legacyJson)
        }
        return@withContext emptyList<AdaptiveCardParseWarning>()
    }

    private fun compareJsonObjects(
        nativeJson: JSONObject,
        legacyJson: JSONObject,
        path: String = ""
    ): List<AdaptiveCardParseWarning> {
        val diffs = mutableListOf<AdaptiveCardParseWarning>()
        val keys = (nativeJson.keys().asSequence().toSet() + legacyJson.keys().asSequence().toSet())
        for (key in keys) {
            val newPath = if (path.isEmpty()) key else "$path.$key"
            if (!nativeJson.has(key)) {
                diffs.add(AdaptiveCardParseWarning(WarningStatusCode.RequiredPropertyMissing,"Key missing in native : $newPath - Parent: $path"))
            } else if (!legacyJson.has(key)) {
                diffs.add(AdaptiveCardParseWarning(WarningStatusCode.RequiredPropertyMissing,"Key missing in legacy: $newPath - Parent: $path"))
            } else {
                val nativeValue = nativeJson.get(key)
                val legacyValue = legacyJson.get(key)
                when {
                    nativeValue is JSONObject && legacyValue is JSONObject ->
                        diffs.addAll(compareJsonObjects(nativeValue, legacyValue, newPath))

                    nativeValue is JSONArray && legacyValue is JSONArray ->
                        diffs.addAll(compareJsonArrays(nativeValue, legacyValue, newPath))
                }
            }
        }
        return diffs
    }

    private fun compareJsonArrays(
        nativeArr: JSONArray,
        legacyArr: JSONArray,
        path: String
    ): List<AdaptiveCardParseWarning> {
        val diffs = mutableListOf<AdaptiveCardParseWarning>()
        val maxLength = maxOf(nativeArr.length(), legacyArr.length())
        for (i in 0 until maxLength) {
            val newPath = "$path[$i]"
            if (i >= nativeArr.length()) {
                diffs.add(AdaptiveCardParseWarning(WarningStatusCode.RequiredPropertyMissing,"Index $i missing in nativeArr at $newPath"))
            } else if (i >= legacyArr.length()) {
                diffs.add(AdaptiveCardParseWarning(WarningStatusCode.RequiredPropertyMissing,"Index $i missing in legacyArr at $newPath"))
            } else {
                val value1 = nativeArr[i]
                val value2 = legacyArr[i]
                when {
                    value1 is JSONObject && value2 is JSONObject ->
                        diffs.addAll(compareJsonObjects(value1, value2, newPath))

                    value1 is JSONArray && value2 is JSONArray ->
                        diffs.addAll(compareJsonArrays(value1, value2, newPath))
                }
            }
        }
        return diffs
    }
}