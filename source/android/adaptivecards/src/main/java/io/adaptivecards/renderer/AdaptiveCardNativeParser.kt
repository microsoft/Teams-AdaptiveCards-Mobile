package io.adaptivecards.renderer

import EvaluationContext
import EvaluationContextConfig
import Expression
import FunctionDeclaration
import android.widget.Button
import android.widget.TextView
import com.example.ac_sdk.AdaptiveCardParser
import com.example.ac_sdk.objectmodel.parser.ParseContext
import io.adaptivecards.objectmodel.AdaptiveCard
import io.adaptivecards.objectmodel.ParseResult
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import kotlin.random.Random

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

    // STEP 1: Define the host function.
// This is your actual implementation. It must be a `suspend` function
// to perform non-blocking operations like network calls or delays.
    suspend fun authorizeUser(): Boolean {
        println("Host Function: Starting authorization check...")
        // Simulate a 2-second network delay without blocking the thread
        delay(2000L)
        val isAuthorized = Random.nextBoolean() // Simulate a random success/failure
        println("Host Function: Authorization check complete. Result: $isAuthorized")
        return isAuthorized
    }

    // The main entry point of our application.
// We use `runBlocking` to start a coroutine from a regular `main` function.
    fun evalExpression() = runBlocking {
        println("--- Expression Evaluation Demo ---")

        // The expression string, just like in the Adaptive Card JSON
        val expressionString = "if(authorizeUser(), 'Access granted', 'Access denied')"

        // STEP 2: Register the host function with the evaluator.
        // This creates the bridge between the string "authorizeUser" and your Kotlin code.
        val authorizeUserDeclaration = FunctionDeclaration(
            name = "authorizeUser",
            // The callback is a lambda that calls your actual function.
            // This is the key part: it's a direct function reference, no reflection needed.
            callback = { _ -> authorizeUser() } // `_` because it takes no params
        )

        // STEP 3: Create the evaluation context.
        // The context is configured with all the functions the host provides.
        val contextConfig = EvaluationContextConfig(functions = listOf(authorizeUserDeclaration))
        val evaluationContext = EvaluationContext(contextConfig)

        // STEP 4: Create an Expression object.
        // The constructor would normally parse the string into an AST.
        val expression = Expression(expressionString)

        // STEP 5: Evaluate the expression.
        // This is the actual "call". It's a suspend function, so it must be
        // called from within a coroutine (like our `runBlocking` block).
        println("\nCalling expression.evaluate()... The program will now wait for the result.")
        val startTime = System.currentTimeMillis()

        val result = expression.evaluate(evaluationContext) // This triggers the entire chain

        val endTime = System.currentTimeMillis()
        println("\nEvaluation finished in ${endTime - startTime}ms.")

        // STEP 6: Use the result.
        // In a real app, you would use this result to update the UI.
        println("Final Result: '$result'")
        println("------------------------------------")
    }

    private suspend fun evalExpressionAndReturnResult(expressionString: String): String {
        return  withContext(Dispatchers.IO) {

            val authorizeUserDeclaration = FunctionDeclaration(
                name = "authorizeUser",
                callback = { _ -> authorizeUser() }
            )

            val contextConfig = EvaluationContextConfig(functions = listOf(authorizeUserDeclaration))
            val evaluationContext = EvaluationContext(contextConfig)
            val expression = Expression(expressionString)

            expression.evaluate(evaluationContext).toString()
        }
    }

    fun evaluateAndSetText(expression:String, textView: TextView) {
        val scope = MainScope() // Creates a coroutine scope on Main Dispatcher
        scope.launch {
            try {
                val result = evalExpressionAndReturnResult(expression)
                textView.text = result
            } catch (e: Exception) {
                textView.text = "Error: ${e.message}"
            }
        }
    }

    fun evaluateAndSetVisible(expression:String, button: Button) {
        val scope = MainScope() // Creates a coroutine scope on Main Dispatcher
        scope.launch {
            try {
                val result = evalExpressionAndReturnResult(expression)
                button.isEnabled = result.toBoolean()
            } catch (e: Exception) {
            }
        }
    }

}
