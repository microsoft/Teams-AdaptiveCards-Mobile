package io.adaptivecards.renderer

import android.util.Log
import com.example.ac_sdk.AdaptiveCardParser
import com.example.ac_sdk.objectmodel.parser.ParseContext
import io.adaptivecards.objectmodel.AdaptiveCard
import io.adaptivecards.objectmodel.ParseResult
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject

object AdaptiveCardNativeParser {

    /**
     * Suspend function to evaluate native parsing diff task.
     * @param stringifiedAdaptiveCard The stringified Adaptive Card.
     * @param rendererVersion The renderer version.
     * @param legacyParseResult The legacy parse result.
     * @throws Exception if parsing fails
     * @return A set of strings representing the differences between the native and legacy parsing results.
     */
    suspend fun evaluateNativeParsingDiffTask(
        stringifiedAdaptiveCard: String, rendererVersion: String, legacyParseResult: ParseResult
    ): Set<String> = withContext(Dispatchers.Default) {
        compareWithNativeParsing(
            stringifiedAdaptiveCard, legacyParseResult, rendererVersion, ParseContext()
        )
    }

    /**
     * Suspend function to evaluate native parsing diff task.
     * @param stringifiedAdaptiveCard The stringified Adaptive Card.
     * @param rendererVersion The renderer version.
     * @param legacyParseResult The legacy parse result.
     * @return A set of strings representing the differences between the native and legacy parsing results.
     */
    fun evaluateNativeParsingDiff(
        stringifiedAdaptiveCard: String, rendererVersion: String, legacyParseResult: ParseResult
    ): Set<String> {

        return compareWithNativeParsing(
            stringifiedAdaptiveCard, legacyParseResult, rendererVersion, ParseContext()
        )
    }

    /**
     * Deserializes a stringified Adaptive Card into an AdaptiveCard object.
     * @param stringifiedAdaptiveCard The stringified Adaptive Card.
     * @param rendererVersion The renderer version.
     * @param context The parse context.
     */
    fun deserializeFromString(
        stringifiedAdaptiveCard: String,
        rendererVersion: String,
        context: io.adaptivecards.objectmodel.ParseContext
    ) = run {
        AdaptiveCard.DeserializeFromString(
            stringifiedAdaptiveCard, rendererVersion, context
        )
    }

    private fun compareWithNativeParsing(
        stringifiedAdaptiveCard: String,
        legacyParseResult: ParseResult,
        rendererVersion: String,
        context: ParseContext,
    ): Set<String> {
        val nativeParseResult = AdaptiveCardParser.deserializeFromString(
            stringifiedAdaptiveCard, rendererVersion, context
        )

        val native = nativeParseResult.serlizedJson
        val legacy = legacyParseResult.GetAdaptiveCard().Serialize()

        if (native?.isNotBlank() == true && legacy.isNotBlank() && native != legacy) {
            val nativeJson = JSONObject(native)
            val legacyJson = JSONObject(legacy)
            return compareJsonObjects(nativeJson, legacyJson)
        }
        return emptySet()
    }

    private fun compareJsonObjects(
        nativeJson: JSONObject, legacyJson: JSONObject, path: String = ""
    ): Set<String> {
        val diffs = mutableSetOf<String>()
        val allKeys = nativeJson.keys().asSequence().toSet() + legacyJson.keys().asSequence().toSet()

        val type = takeIf { legacyJson.has("type") }?.let {
            legacyJson.getString("type")
        } ?: ""
        for (key in allKeys) {
            if (key == "type" || key == "grid.area" || key == "\$schema" || key == "version") continue

            val newPath = if (path.isEmpty()) key else "$path.$key"

            val nativeHasKey = nativeJson.has(key)
            val legacyHasKey = legacyJson.has(key)

            when {
                !nativeHasKey && legacyHasKey -> {
                    val legacyValue = legacyJson.get(key)

                    // Skip if legacyValue is an empty JSONArray
                    if (legacyValue !is JSONArray || legacyValue.length() != 0) {
                        diffs.add("Key missing in native: $newPath, Value: $legacyValue, type: $type")
                    }
                }

                nativeHasKey && !legacyHasKey -> {
                    diffs.add("Key missing in legacy: $newPath")
                }

                nativeHasKey && legacyHasKey -> {
                    val nativeValue = nativeJson.get(key)
                    val legacyValue = legacyJson.get(key)

                    when {
                        nativeValue is JSONObject && legacyValue is JSONObject ->
                            diffs.addAll(compareJsonObjects(nativeValue, legacyValue, newPath))

                        nativeValue is JSONArray && legacyValue is JSONArray ->
                            diffs.addAll(compareJsonArrays(nativeValue, legacyValue, newPath))

                        isJsonPrimitive(nativeValue) && isJsonPrimitive(legacyValue) && !primitiveValuesAreEqual(nativeValue, legacyValue)  -> {
                            diffs.add("Value mismatch at $newPath - Native: $nativeValue, Legacy: $legacyValue")
                        }
                    }
                }
            }
        }

        return diffs
    }

    private fun isJsonPrimitive(value: Any?): Boolean {
        return value == null || value is String || value is Number || value is Boolean
    }

    private fun primitiveValuesAreEqual(a: Any?, b: Any?): Boolean {
        if (a == null && b == null) return true
        if (a == null || b == null) return false

        val aStr = a.toString().trim()
        val bStr = b.toString().trim()

        // Try to compare as numbers if both look like numbers
        val aNum = aStr.toDoubleOrNull()
        val bNum = bStr.toDoubleOrNull()
        return if (aNum != null && bNum != null) {
            aNum == bNum
        } else {
            aStr == bStr
        }
    }

    private fun compareJsonArrays(
        nativeArr: JSONArray, legacyArr: JSONArray, path: String
    ): Set<String> {
        val diffs = mutableSetOf<String>()
        val maxLength = maxOf(nativeArr.length(), legacyArr.length())

        for (i in 0 until maxLength) {
            val newPath = "$path[$i]"

            if (i >= nativeArr.length()) {
                diffs.add("Index $i missing in nativeArr at $newPath")
            } else if (i >= legacyArr.length()) {
                diffs.add("Index $i missing in legacyArr at $newPath")
            } else {
                val value1 = nativeArr[i]
                val value2 = legacyArr[i]

                val nestedDiffs = when {
                    value1 is JSONObject && value2 is JSONObject ->
                        compareJsonObjects(value1, value2, newPath)

                    value1 is JSONArray && value2 is JSONArray ->
                        compareJsonArrays(value1, value2, newPath)

                    else -> emptySet()
                }

                diffs.addAll(nestedDiffs)
            }
        }
        return diffs
    }
}
