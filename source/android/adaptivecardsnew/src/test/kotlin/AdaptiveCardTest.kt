import com.example.ac_sdk.BaseModelTest
import com.example.ac_sdk.objectmodel.AdaptiveCard
import com.example.ac_sdk.objectmodel.AuthCardButton
import com.example.ac_sdk.objectmodel.Authentication
import com.example.ac_sdk.objectmodel.TokenExchangeResource
import com.example.ac_sdk.objectmodel.elements.ActionElements
import com.example.ac_sdk.objectmodel.elements.CardElements
import com.example.ac_sdk.objectmodel.utils.HeightType
import com.example.ac_sdk.objectmodel.utils.VerticalAlignment
import kotlinx.serialization.json.Json
import org.junit.Assert.assertEquals
import org.junit.Test

class AdaptiveCardTest : BaseModelTest() {

    @Test
    fun `test AdaptiveCard serialization and deserialization`() {
        val adaptiveCard = AdaptiveCard(
            schema = "http://adaptivecards.io/schemas/adaptive-card.json",
            type = "AdaptiveCard",
            version = "1.2",
            language = "en",
            fallbackText = "Fallback text",
            speak = "speak text",
            minHeight = 200,
            height = HeightType.AUTO,
            verticalAlignment = VerticalAlignment.TOP,
            body = arrayListOf(
                CardElements.TextBlock(
                    text = "Sample Text"
                )
            ),
            actions = arrayListOf(
                ActionElements.ActionOpenUrl(
                    url = "https://example.com"
                )
            ),
            authentication = Authentication(
                connectionName = "connectionName",
                text = "text",
                tokenExchangeResource = TokenExchangeResource(
                    id = "id",
                    providerId = "providerId",
                    uri = "https://example.com/uri"
                ),
                buttons = listOf(
                    AuthCardButton(
                        type = "buttonType",
                        title = "buttonTitle"
                    )
                )
            ),
            rtl = true
        )

        val json = json.encodeToString(AdaptiveCard.serializer(), adaptiveCard)
        val deserializedAdaptiveCard = Json.decodeFromString(AdaptiveCard.serializer(), json)

        assertEquals(adaptiveCard, deserializedAdaptiveCard)
    }
}