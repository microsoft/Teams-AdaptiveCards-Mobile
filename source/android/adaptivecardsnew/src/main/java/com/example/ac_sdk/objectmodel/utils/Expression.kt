// --- FILE: ExpressionLanguage.kt ---

import kotlinx.coroutines.*
import java.util.* // For ArrayDeque

// Assuming these helper functions are defined elsewhere in the project
// object Helpers {
//   fun compareValues(a: Any?, b: Any?): Boolean { ... }
//   fun isObjectKey(a: Any?): Boolean { ... }
//   fun isPropertyBag(a: Any?): Boolean { ... }
//   val substrFunction: FunctionCallback = { ... }
//   ... and all other imported functions
// }


// --- 1. Language Vocabulary (Tokens & Operators) ---

private val arithmeticOperatorTokens = listOf("+", "-", "*", "/")
private val comparisonOperatorTokens = listOf("==", "!=", "<", "<=", ">", ">=", "&&", "||")
private val membershipOperatorTokens = listOf("in")

val binaryOperatorTokens = arithmeticOperatorTokens + comparisonOperatorTokens + membershipOperatorTokens

private val bracketTokens = listOf("\${", "}", "[", "]", "(", ")")
private val otherTokens = listOf("?#", ".", ",")
private val literalTokens = listOf("string", "number", "boolean", "identifier")

val allTokens = binaryOperatorTokens + bracketTokens + literalTokens + otherTokens

// Type Aliases for clarity
typealias Token = String
typealias BinaryOperatorToken = String
typealias EvaluationResult = Any?
typealias FunctionCallback = suspend (params: List<Any?>) -> EvaluationResult

private val orderedBinaryOperators: List<BinaryOperatorToken> = listOf(
    "/", "*", "-", "+", "==", "!=", "<", "<=", ">", ">=", "&&", "||", "in"
)

val operatorPriorityGroups: List<List<BinaryOperatorToken>> = listOf(
    listOf("/", "*"),
    listOf("-", "+"),
    listOf("==", "!=", "<", "<=", ">", ">=", "&&", "||", "in")
)

data class TokenizerRule(val tokenType: Token?, val regEx: Regex)
data class TokenInfo(val type: Token, val value: String, val originalPosition: Int)


// --- 2. Tokenizer (Lexical Analysis) ---

object Tokenizer {
    // Rules are processed in order. More specific rules must come first.
    private val rules: List<TokenizerRule> = listOf(
        TokenizerRule(null, Regex("^\\s+")), // Skip whitespace
        TokenizerRule("\${", Regex("^\\$\\{")), // Correctly escaped
        TokenizerRule("?#", Regex("^\\?#")),     // Correctly escaped
        TokenizerRule("}", Regex("^\\}")),       // <<< THE FIX IS HERE
        TokenizerRule("[", Regex("^\\[")),       // Correctly escaped
        TokenizerRule("]", Regex("^\\]")),       // Correctly escaped
        TokenizerRule("(", Regex("^\\(")),       // Correctly escaped
        TokenizerRule(")", Regex("^\\)")),       // Correctly escaped
        TokenizerRule("boolean", Regex("^true|^false")),
        TokenizerRule(".", Regex("^\\.")),       // Correctly escaped
        TokenizerRule(",", Regex("^,")),
        TokenizerRule("+", Regex("^\\+")),       // Correctly escaped
        TokenizerRule("-", Regex("^-")),
        TokenizerRule("*", Regex("^\\*")),       // Correctly escaped
        TokenizerRule("/", Regex("^/")),
        TokenizerRule("==", Regex("^==")),
        TokenizerRule("!=", Regex("^!=")),
        TokenizerRule("<=", Regex("^<=")),
        TokenizerRule("<", Regex("^<")),
        TokenizerRule(">=", Regex("^>=")),
        TokenizerRule(">", Regex("^>")),
        TokenizerRule("&&", Regex("^&&")),
        TokenizerRule("||", Regex("^\\|\\|")),   // Correctly escaped
        TokenizerRule("in", Regex("^in\\b")), // Use word boundary for safety
        TokenizerRule("string", Regex("^\"([^\"]*)\"")),
        TokenizerRule("string", Regex("^'([^']*)'")),
        TokenizerRule("number", Regex("^\\d*\\.?\\d+")),
        // Identifier regex from previous discussion
        TokenizerRule("identifier", Regex("^[_a-zA-Z$][_a-zA-Z0-9$]*"))
    )

    fun parse(expression: String): List<TokenInfo> {
        val result = mutableListOf<TokenInfo>()
        var i = 0

        while (i < expression.length) {
            val subExpression = expression.substring(i)
            var matchFound = false

            for (rule in rules) {
                val match = rule.regEx.find(subExpression)
                if (match != null && match.range.first == 0) {
                    if (match.groups.size > 2) {
                        throw Error("A tokenizer rule matched more than one group.")
                    }

                    if (rule.tokenType != null) {
                        // If there's a capture group, use it; otherwise, use the full match.
                        val value = if (match.groupValues.size > 1) match.groupValues[1] else match.value
                        result.add(TokenInfo(rule.tokenType, value, i))
                    }

                    i += match.value.length
                    matchFound = true
                    break
                }
            }

            if (!matchFound) {
                throw Error("Unexpected character \"${subExpression[0]}\" at position $i.")
            }
        }
        return result
    }
}

// --- 3. Evaluation Context and Runtime ---

private fun assertValueType(value: Any?): Any? {
    if (value is Map<*, *> && value !is List<*>) { // Assuming objects are represented as Maps
        throw Error("Invalid value type \"${value::class.simpleName}\"")
    }
    return value
}

data class FunctionDeclaration(
    val name: String,
    val cacheResultFor: Long? = null, // Cache duration in milliseconds
    val callback: FunctionCallback
)

private data class EvaluationContextState(val data: Any?, val index: Int)

data class EvaluationContextConfig(
    val root: Any? = null,
    val functions: List<FunctionDeclaration> = emptyList()
)

private class CachedFunctionCall(
    val declaration: FunctionDeclaration,
    val params: List<EvaluationResult>?
) {
    private var timeStamp: Long? = null
    private var executionJob: Deferred<EvaluationResult>? = null

    suspend fun execute(scope: CoroutineScope): EvaluationResult {
        val isNew = executionJob == null

        if (isNew) {
            executionJob = scope.async { declaration.callback(params ?: emptyList()) }
        }

        val result = executionJob!!.await()

        if (isNew) {
            timeStamp = System.currentTimeMillis()
        }
        return result
    }

    fun isOutdated(): Boolean {
        if (declaration.cacheResultFor == null) return true
        val ts = timeStamp ?: return false // Not outdated if it has never run
        return (System.currentTimeMillis() - ts) > declaration.cacheResultFor
    }
}

private class FunctionCallCache {
    private val callCache = mutableMapOf<String, MutableSet<CachedFunctionCall>>()

    suspend fun callFunction(
        scope: CoroutineScope,
        declaration: FunctionDeclaration,
        params: List<EvaluationResult>?
    ): EvaluationResult {
        val cachedCalls = callCache.getOrPut(declaration.name) { mutableSetOf() }

        // Find a non-outdated, matching cached call
        var call = cachedCalls.find { !it.isOutdated() && it.params == params /* Assuming deep equals on list */ }

        if (call == null) {
            // Remove any outdated calls with the same params
            cachedCalls.removeIf { it.isOutdated() && it.params == params }
            call = CachedFunctionCall(declaration, params)
            cachedCalls.add(call)
        }

        return call.execute(scope)
    }
}

class EvaluationContext(config: EvaluationContextConfig? = null) {
    private val stateStack = ArrayDeque<EvaluationContextState>()
    private val functions = config?.functions?.associateBy { it.name }?.toMutableMap() ?: mutableMapOf()
    private val functionCallCache = FunctionCallCache()

    val root: Any? = config?.root
    var data: Any? = null
    var index: Int = 0

    val currentDataContext: Any? get() = data ?: root


        companion object {
            // The 'if' function logic from Step 1 can be placed here as a private val
            private val ifFunction: FunctionCallback = { params ->
                if (params.size != 3) {
                    throw IllegalArgumentException("if() function requires 3 arguments, but got ${params.size}.")
                }
                val condition = params[0] as? Boolean ?: false
                if (condition) params[1] else params[2]
            }

            // Add other built-in functions here as you implement them
            // For example:
            private val toUpperFunction: FunctionCallback = { params ->
                if (params.isEmpty()) null else params[0]?.toString()?.uppercase()
            }

            // The map of all built-in functions, mapping their string name to their logic.
            private val builtInFunctions = mapOf<String, FunctionCallback>(
                // <<< THE FIX IS HERE >>>
                "if" to ifFunction,
                "toUpper" to toUpperFunction,
                // "substr" to substrFunction,
                // "JSON.parse" to jsonParseFunction,
                // "toString" to toStringFunction,
                // ... and all the others from the TypeScript file
            )
    }

    suspend fun executeFunction(name: String, params: List<ExpressionNode>): EvaluationResult = coroutineScope {
        val declaration = getFunction(name) ?: throw Error("Unknown function \"$name\"")

        val evaluatedParams = params.map { async { it.evaluate(this@EvaluationContext) } }.awaitAll()

        functionCallCache.callFunction(this, declaration, evaluatedParams)
    }

    private fun getFunction(name: String): FunctionDeclaration? {
        return functions[name] ?: builtInFunctions[name]?.let { FunctionDeclaration(name, callback = it) }
    }

    fun saveState() {
        stateStack.addLast(EvaluationContextState(data, index))
    }

    fun restoreLastState() {
        val savedState = stateStack.removeLast()
            ?: throw Error("There is no evaluation context state to restore.")
        data = savedState.data
        index = savedState.index
    }
}


// --- 4. Abstract Syntax Tree (AST) Nodes ---

sealed class EvaluationNode {
    abstract suspend fun evaluate(context: EvaluationContext): EvaluationResult
}

class BinaryOperatorNode(val operator: BinaryOperatorToken) : EvaluationNode() {
    // This is a helper, not the main evaluation path.
    // The main path is in ExpressionNode.
    @Suppress("UNCHECKED_CAST")
    suspend fun evaluate(context: EvaluationContext, left: Any?, right: Any?): EvaluationResult {
        // Special handling for lists
        if (left is List<*> || right is List<*>) {
            when (operator) {
                "in" -> if (right is List<*>) return right.contains(left)
                "+" -> return when {
                    left is List<*> && right is List<*> -> left + right
                    left is List<*> -> left + right
                    right is List<*> -> listOf(left) + right
                    else -> Unit // Fall through
                }
            }
        }
        
        // General purpose evaluation
        val leftNum = (left as? Number)?.toDouble()
        val rightNum = (right as? Number)?.toDouble()
        
        return when (operator) {
            "/" -> leftNum!! / rightNum!!
            "*" -> leftNum!! * rightNum!!
            "-" -> leftNum!! - rightNum!!
            "+" -> if (left is String || right is String) "$left$right" else leftNum!! + rightNum!!
            "==" -> left == right
            "!=" -> left != right
            "<" -> (left as Comparable<Any?>).compareTo(right) < 0
            "<=" -> (left as Comparable<Any?>).compareTo(right) <= 0
            ">" -> (left as Comparable<Any?>).compareTo(right) > 0
            ">=" -> (left as Comparable<Any?>).compareTo(right) >= 0
            "&&" -> (left as? Boolean ?: false) && (right as? Boolean ?: false)
            "||" -> (left as? Boolean ?: false) || (right as? Boolean ?: false)
            else -> throw Error("Incompatible operand types for operator \"$operator\"")
        }
    }
    
    override suspend fun evaluate(context: EvaluationContext): EvaluationResult {
        throw UnsupportedOperationException("BinaryOperatorNode cannot be evaluated directly.")
    }
}


class ExpressionNode : EvaluationNode() {
    val nodes = mutableListOf<EvaluationNode>()
    var allowNull = true

    override suspend fun evaluate(context: EvaluationContext): EvaluationResult = coroutineScope {
        if (nodes.size == 1) return@coroutineScope nodes[0].evaluate(context)

        val nodesCopy = nodes.toMutableList()

        for (priorityGroup in operatorPriorityGroups) {
            var i = 0
            while (i < nodesCopy.size) {
                val node = nodesCopy.getOrNull(i)
                if (node is BinaryOperatorNode && node.operator in priorityGroup) {
                    // Evaluate left and right operands concurrently
                    val (leftResult, rightResult) = awaitAll(
                        async { nodesCopy[i - 1].evaluate(context) },
                        async { nodesCopy[i + 1].evaluate(context) }
                    )

                    val result = node.evaluate(context, assertValueType(leftResult), assertValueType(rightResult))

                    // Replace the three nodes (left, op, right) with the single result node
                    nodesCopy.removeAt(i - 1) // left
                    nodesCopy.removeAt(i - 1) // op
                    nodesCopy.removeAt(i - 1) // right
                    nodesCopy.add(i - 1, LiteralNode(result))
                    
                    i-- // Step back to re-evaluate from the new node's position
                }
                i++
            }
        }
        return@coroutineScope nodesCopy[0].evaluate(context)
    }
}

class IdentifierNode(var identifier: String? = null) : EvaluationNode() {
    override suspend fun evaluate(context: EvaluationContext): EvaluationResult = identifier
}

class IndexerNode(var index: ExpressionNode? = null) : EvaluationNode() {
    override suspend fun evaluate(context: EvaluationContext): EvaluationResult = index?.evaluate(context)
}

class FunctionCallNode(val functionName: String) : EvaluationNode() {
    val parameters = mutableListOf<ExpressionNode>()
    override suspend fun evaluate(context: EvaluationContext): EvaluationResult =
        context.executeFunction(functionName, parameters)
}

class LiteralNode(val value: Any?) : EvaluationNode() {
    override suspend fun evaluate(context: EvaluationContext): EvaluationResult = value
}

class ArrayNode : EvaluationNode() {
    val items = mutableListOf<ExpressionNode>()
    override suspend fun evaluate(context: EvaluationContext): EvaluationResult = coroutineScope {
        items.map { async { it.evaluate(context) } }.awaitAll()
    }
}

typealias PathPart = EvaluationNode // Simplified union type

class PathNode : EvaluationNode() {
    val parts = mutableListOf<PathPart>()

    @Suppress("UNCHECKED_CAST")
    override suspend fun evaluate(context: EvaluationContext): EvaluationResult {
        var result: EvaluationResult = null
        
        parts.forEachIndexed { index, part ->
            if (index == 0) {
                if (part is IdentifierNode) {
                    result = when (part.identifier) {
                        "\$root" -> context.root
                        "\$data" -> context.currentDataContext
                        "\$index" -> context.index
                        else -> {
                            val dataCtx = context.currentDataContext
                            // Assuming property bag is a Map
                            if (dataCtx is Map<*, *> && part.identifier != null) {
                                dataCtx[part.identifier]
                            } else null
                        }
                    }
                } else {
                     result = part.evaluate(context)
                }
            } else {
                val partValue = part.evaluate(context)
                val currentResult = result
                // Assuming property bag is a Map
                if (currentResult is Map<*, *> && partValue != null) {
                     result = currentResult[partValue]
                } else if (currentResult is List<*> && partValue is Int) {
                    result = currentResult.getOrNull(partValue)
                } else {
                    throw Error("Invalid path node.")
                }
            }
        }
        return result
    }
}


// --- 5. Expression Parser (Syntactic Analysis) ---

class ExpressionParser(expression: String) {
    private val tokens: List<TokenInfo> = Tokenizer.parse(expression)
    private var index = 0

    private val eof: Boolean get() = index >= tokens.size
    private val current: TokenInfo get() = tokens[index]

    private fun unexpectedToken(): Nothing =
        throw Error("Unexpected token \"${current.value}\" at position ${current.originalPosition}.")
    
    private fun unexpectedEof(): Nothing =
        throw Error("Unexpected end of expression.")

    private fun moveNext() { index++ }
    
    private fun parseToken(vararg expectedTokenTypes: Token): TokenInfo {
        if (eof) unexpectedEof()
        if (current.type !in expectedTokenTypes) unexpectedToken()
        return current.also { moveNext() }
    }
    
    private fun parseOptionalToken(vararg expectedTokenTypes: Token): Boolean {
        if (eof || current.type !in expectedTokenTypes) return false
        moveNext()
        return true
    }

    // ... The rest of the parsing methods (parsePath, parseExpression, etc.) would be a direct
    // logical translation of the TypeScript methods, using `when` instead of `switch` and
    // Kotlin collection methods. The logic is highly detailed and would be lengthy to replicate
    // here, but it follows the same state-machine pattern as the original. The below `parseExpression`
    // is a simplified example to show the structure.

    private fun parsePrimary(): EvaluationNode {
        return when (current.type) {
            "identifier" -> parsePath()
            "[" -> parseArray()
            "string" -> LiteralNode(current.value).also { moveNext() }
            "number" -> LiteralNode(current.value.toDouble()).also { moveNext() }
            "boolean" -> LiteralNode(current.value.toBoolean()).also { moveNext() }
            "(" -> {
                moveNext() // Consume '('
                val expr = parseExpression()
                parseToken(")") // Consume ')'
                expr
            }
            else -> unexpectedToken()
        }
    }
    
    // A simplified placeholder for the complex parseExpression logic
    private fun parseExpression(): ExpressionNode {
        val result = ExpressionNode()
        result.nodes.add(parsePrimary())

        while(!eof && current.type in binaryOperatorTokens) {
            result.nodes.add(BinaryOperatorNode(current.type))
            moveNext()
            result.nodes.add(parsePrimary())
        }
        return result
    }

    // Inside the ExpressionParser class

    private fun parseFunctionCall(functionName: String): FunctionCallNode {
        val result = FunctionCallNode(functionName)

        parseToken("(")

        if (current.type != ")") {
            // Parse first parameter
            result.parameters.add(parseExpression())

            // Parse subsequent parameters as long as there is a comma
            while (parseOptionalToken(",")) {
                result.parameters.add(parseExpression())
            }
        }

        parseToken(")")
        return result
    }

    private fun parseIdentifier(): IdentifierNode {
        val token = parseToken("identifier")
        return IdentifierNode(token.value)
    }

    private fun parseIndexer(): IndexerNode {
        val result = IndexerNode()
        parseToken("[")
        result.index = parseExpression()
        parseToken("]")
        return result
    }
    // Inside the ExpressionParser class

    private fun parseArray(): ArrayNode {
        val result = ArrayNode()

        parseToken("[")

        // Check if the array is not empty
        if (current.type != "]") {
            // Parse the first item
            result.items.add(parseExpression())

            // Keep parsing items as long as we find a comma separator
            while (parseOptionalToken(",")) {
                result.items.add(parseExpression())
            }
        }

        // An array must end with a closing bracket
        parseToken("]")

        return result
    }

    // Inside the ExpressionParser class

    private fun parsePath(): PathNode {
        val result = PathNode()

        // The state machine's expected next tokens
        var expectedNextTokenTypes: List<Token> = listOf("identifier", "(")
        // A flag to know if the path can legally end at the current position
        var canEnd = false

        while (!eof) {
            if (current.type !in expectedNextTokenTypes) {
                // If the current token isn't what we expect, check if the path
                // could have legally ended on the *previous* token. If so, we're done.
                return if (result.parts.isNotEmpty() && canEnd) {
                    result
                } else {
                    // Otherwise, it's a syntax error.
                    unexpectedToken()
                }
            }

            canEnd = false

            when (current.type) {
                "(" -> {
                    if (result.parts.isEmpty()) {
                        // Path starts with a parenthesis, e.g., (1 + 2).name
                        moveNext() // Consume '('
                        result.parts.add(this.parseExpression())
                        parseToken(")")
                    } else {
                        // This is a function call, like my.func() or JSON.parse()
                        // We need to "reduce" the preceding identifiers into a single function name.
                        val functionName = result.parts.joinToString(".") { part ->
                            (part as? IdentifierNode)?.identifier ?: unexpectedToken()
                        }
                        result.parts.clear()
                        result.parts.add(parseFunctionCall(functionName))
                    }
                    expectedNextTokenTypes = listOf(".", "[")
                    canEnd = true
                }
                "[" -> {
                    // An indexer, e.g., path[0]
                    result.parts.add(parseIndexer())
                    expectedNextTokenTypes = listOf(".", "(", "[")
                    canEnd = true
                }
                "identifier" -> {
                    // A property identifier
                    result.parts.add(parseIdentifier())
                    expectedNextTokenTypes = listOf(".", "(", "[")
                    canEnd = true
                }
                "." -> {
                    // A property accessor dot
                    moveNext() // Consume '.'
                    // The only thing allowed after a dot is another identifier
                    expectedNextTokenTypes = listOf("identifier")
                    // A path cannot legally end with a dot
                    canEnd = false
                }
                else -> {
                    // Should not happen due to the check at the top of the loop
                    unexpectedToken()
                }
            }
        }

        // After the loop, check if the path ended in a valid state
        if (result.parts.isNotEmpty() && canEnd) {
            return result
        }

        // If we reach the end of the expression in an invalid state (e.g., "my.path.")
        throw Error("Invalid path.")
    }

    fun parse(): ExpressionNode {
        val result = parseExpression()
        if (!eof) unexpectedToken()
        return result
    }

    fun parseBinding(): Pair<ExpressionNode, Boolean> {
        parseToken("\${")
        val allowNull = !parseOptionalToken("?#")
        val expression = parseExpression()
        parseToken("}")
        if (!eof) unexpectedToken()
        return Pair(expression, allowNull)
    }
}

// --- 6. Public API ---

class Expression(val expressionString: String) {
    // The real implementation would use the full parser
    private val expressionNode: ExpressionNode = ExpressionParser(expressionString).parse()

    suspend fun evaluate(context: EvaluationContext? = null): EvaluationResult {
        return expressionNode.evaluate(context ?: EvaluationContext())
    }
}

class Binding(val expressionString: String) {
    private val expressionNode: ExpressionNode
    val allowNull: Boolean

    init {
        val (expr, allow) = ExpressionParser(expressionString).parseBinding()
        expressionNode = expr
        allowNull = allow
    }

    suspend fun evaluate(context: EvaluationContext? = null): EvaluationResult {
        val result = expressionNode.evaluate(context ?: EvaluationContext())
        if (!allowNull && result == null) {
            throw Error("Binding expression returned null but allowNull is false.")
        }
        return result
    }
}