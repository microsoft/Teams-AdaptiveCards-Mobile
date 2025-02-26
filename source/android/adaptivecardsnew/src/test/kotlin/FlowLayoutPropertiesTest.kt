import com.example.ac_sdk.BaseModelTest
import com.example.ac_sdk.objectmodel.elements.LayoutElements
import com.example.ac_sdk.objectmodel.utils.HorizontalAlignment
import com.example.ac_sdk.objectmodel.utils.ItemFit
import com.example.ac_sdk.objectmodel.utils.Spacing
import org.junit.Assert.assertEquals
import org.junit.Test

class FlowLayoutPropertiesTest : BaseModelTest() {

    @Test
    fun `test FlowLayout properties`() {
        val jsonString = """
            {
                "type": "Layout.Flow",
                "itemFit": "Fit",
                "itemWidth": "100px",
                "minItemWidth": "50px",
                "maxItemWidth": "200px",
                "pixelItemWidth": 100,
                "itemMinPixelWidth": 50,
                "itemMaxPixelWidth": 200,
                "rowSpacing": "default",
                "columnSpacing": "default",
                "horizontalAlignment": "center"
            }
        """.trimIndent()

        val flowLayout = json.decodeFromString<LayoutElements.FlowLayout>(jsonString)

        assertEquals(ItemFit.Fit, flowLayout.itemFit)
        assertEquals("100px", flowLayout.itemWidth)
        assertEquals("50px", flowLayout.minItemWidth)
        assertEquals("200px", flowLayout.maxItemWidth)
        assertEquals(100, flowLayout.pixelItemWidth)
        assertEquals(50, flowLayout.itemMinPixelWidth)
        assertEquals(200, flowLayout.itemMaxPixelWidth)
        assertEquals(Spacing.DEFAULT, flowLayout.rowSpacing)
        assertEquals(Spacing.DEFAULT, flowLayout.columnSpacing)
        assertEquals(HorizontalAlignment.CENTER, flowLayout.horizontalAlignment)
    }
}