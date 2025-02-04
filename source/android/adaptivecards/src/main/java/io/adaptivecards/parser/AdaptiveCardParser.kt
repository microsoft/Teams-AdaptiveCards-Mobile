package io.adaptivecards.parser

import android.util.Log
import io.adaptivecards.parser.elements.ActionElement
import io.adaptivecards.parser.elements.InputElement
import io.adaptivecards.parser.elements.BaseActionElement
import io.adaptivecards.parser.elements.BaseCardElement
import io.adaptivecards.parser.elements.BaseInputElement
import io.adaptivecards.parser.elements.CardElement
import io.adaptivecards.parser.parsing.ParseResult
import kotlinx.serialization.json.Json
import kotlinx.serialization.modules.SerializersModule
import kotlinx.serialization.modules.polymorphic
import java.io.File

class AdaptiveCardParser {

    fun deserializeFromString(jsonString: String): ParseResult?{
        val module = SerializersModule {
            // Register polymorphic base class BaseCardElement
            polymorphic(BaseCardElement::class) {
                subclass(CardElement.TextBlock::class, CardElement.TextBlock.serializer()) // Register TextBlock as subclass
            }
        }

        val json = Json {
            serializersModule = module
            decodeEnumsCaseInsensitive = true
            ignoreUnknownKeys =true
        }


        val result = json.decodeFromString<AdaptiveCard>(testJsonString)
        Log.d("check-point", result.toString())
        return null

    }

    fun readJsonFromFile(filePath: String): String {
        return try {
            val file = File(filePath)
            file.readText(Charsets.UTF_8)
        } catch (e: Exception) {
            e.printStackTrace()
            ""
        }
    }

    val testJsonString= "{\n" +
            "\t\"\$schema\": \"http://adaptivecards.io/schemas/adaptive-card.json\",\n" +
            "\t\"type\": \"AdaptiveCard\",\n" +
            "\t\"version\": \"1.0\",\n" +
            "\t\"body\": [\n" +
            "\t\t{\n" +
            "\t\t\t\"type\": \"ColumnSet\",\n" +
            "\t\t\t\"columns\": [\n" +
            "\t\t\t\t{\n" +
            "\t\t\t\t\t\"type\": \"Column\",\n" +
            "\t\t\t\t\t\"items\": [\n" +
            "\t\t\t\t\t\t{\n" +
            "\t\t\t\t\t\t\t\"type\": \"TextBlock\",\n" +
            "\t\t\t\t\t\t\t\"text\": \"Column 1\"\n" +
            "\t\t\t\t\t\t}\n" +
            "\t\t\t\t\t]\n" +
            "\t\t\t\t},\n" +
            "\t\t\t\t{\n" +
            "\t\t\t\t\t\"type\": \"Column\",\n" +
            "\t\t\t\t\t\"items\": [\n" +
            "\t\t\t\t\t\t{\n" +
            "\t\t\t\t\t\t\t\"type\": \"TextBlock\",\n" +
            "\t\t\t\t\t\t\t\"text\": \"Column 2\"\n" +
            "\t\t\t\t\t\t}\n" +
            "\t\t\t\t\t]\n" +
            "\t\t\t\t},\n" +
            "\t\t\t\t{\n" +
            "\t\t\t\t\t\"type\": \"Column\",\n" +
            "\t\t\t\t\t\"items\": [\n" +
            "\t\t\t\t\t\t{\n" +
            "\t\t\t\t\t\t\t\"type\": \"TextBlock\",\n" +
            "\t\t\t\t\t\t\t\"text\": \"Column 3\"\n" +
            "\t\t\t\t\t\t}\n" +
            "\n" +
            "\t\t\t\t\t]\n" +
            "\t\t\t\t}\n" +
            "\t\t\t]\n" +
            "\t\t}\n" +
            "\t]\n" +
            "}\n"}