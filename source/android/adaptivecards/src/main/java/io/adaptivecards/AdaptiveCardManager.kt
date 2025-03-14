//package io.adaptivecards
//
//import android.util.JsonWriter
//import com.example.ac_sdk.AdaptiveCardParser
//import com.example.ac_sdk.objectmodel.elements.Layout
//import com.example.ac_sdk.objectmodel.elements.LayoutElement
//import com.example.ac_sdk.objectmodel.parser.ParseContext
//import com.example.ac_sdk.objectmodel.utils.HorizontalAlignment
//import com.example.ac_sdk.objectmodel.utils.ImageFillMode
//import com.example.ac_sdk.objectmodel.utils.LayoutContainerType
//import com.example.ac_sdk.objectmodel.utils.Spacing
//import com.example.ac_sdk.objectmodel.utils.TargetWidthType
//import com.example.ac_sdk.objectmodel.utils.VerticalAlignment
//import io.adaptivecards.objectmodel.AdaptiveCard
//import io.adaptivecards.objectmodel.BackgroundImage
//import io.adaptivecards.objectmodel.HeightType
//import io.adaptivecards.objectmodel.JsonValue
//import io.adaptivecards.objectmodel.ParseResult
//import io.adaptivecards.objectmodel.StringVector
//
//object AdaptiveCardManager {
//
//    fun deserializeFromString(
//        jsonPayload: String,
//        rendererVersion: String,
//        deprecateOldParsing: Boolean = false
//    ): ParseResult? {
//        if (deprecateOldParsing) {
//
//            val parseResult = AdaptiveCardParser.deserializeFromString(
//                jsonPayload,
//                rendererVersion,
//                ParseContext()
//            )
//            val newAdaptiveCard = parseResult.adaptiveCard
//
//
//            AdaptiveCard().apply {
//                newAdaptiveCard.apply {
//                    SetVersion(version)
//                    SetFallbackText(fallbackText)
//                    SetRtl(rtl)
//                    SetSpeak(speak)
//                    SetLanguage(language)
//                    SetMinHeight(minHeight?.toLong() ?: 0)
//                    SetHeight(mapHeightType(height))
//                    SetBackgroundImage(mapBackgroundImage(backgroundImage))
//                    SetLayouts(mapToLayouts(layouts))
//                }
//            }
//            return null;
//
//        } else {
//            return AdaptiveCard.DeserializeFromString(jsonPayload, rendererVersion)
//        }
//    }
//
//    private fun mapHeightType(newHeight: com.example.ac_sdk.objectmodel.utils.HeightType?): HeightType {
//        when (newHeight) {
//            com.example.ac_sdk.objectmodel.utils.HeightType.AUTO -> return HeightType.Auto
//            com.example.ac_sdk.objectmodel.utils.HeightType.STRETCH -> return HeightType.Stretch
//            else -> return HeightType.Auto
//        }
//    }
//
//    private fun mapBackgroundImage(newBackgroundImage: com.example.ac_sdk.objectmodel.BackgroundImage?): BackgroundImage? {
//        if (newBackgroundImage == null) {
//            return null
//        }
//        return BackgroundImage().apply {
//            SetUrl(newBackgroundImage.url)
//            SetHorizontalAlignment(
//                mapHorizontalAlignment(newBackgroundImage.horizontalAlignment)
//            )
//            SetVerticalAlignment(
//                mapVerticalAlignment(newBackgroundImage.verticalAlignment)
//            )
//
//            SetFillMode(
//                mapImageFillMode(newBackgroundImage)
//            )
//        }
//    }
//
//    private fun mapImageFillMode(newBackgroundImage: com.example.ac_sdk.objectmodel.BackgroundImage) =
//        when (newBackgroundImage.fillMode) {
//            ImageFillMode.COVER -> io.adaptivecards.objectmodel.ImageFillMode.Cover
//            ImageFillMode.REPEAT_VERT -> io.adaptivecards.objectmodel.ImageFillMode.RepeatVertically
//            ImageFillMode.REPEAT -> io.adaptivecards.objectmodel.ImageFillMode.Repeat
//            ImageFillMode.REPEAT_HORIZ -> io.adaptivecards.objectmodel.ImageFillMode.RepeatHorizontally
//            else -> null
//        }
//
//    private fun mapVerticalAlignment(verticalAlignment: VerticalAlignment?) =
//        when (verticalAlignment) {
//            VerticalAlignment.TOP -> io.adaptivecards.objectmodel.VerticalAlignment.Top
//            VerticalAlignment.CENTER -> io.adaptivecards.objectmodel.VerticalAlignment.Center
//            VerticalAlignment.BOTTOM -> io.adaptivecards.objectmodel.VerticalAlignment.Bottom
//            else -> null
//        }
//
//    private fun mapHorizontalAlignment(horizontalAlignment:HorizontalAlignment?) =
//        when (horizontalAlignment) {
//            HorizontalAlignment.LEFT -> io.adaptivecards.objectmodel.HorizontalAlignment.Left
//            HorizontalAlignment.CENTER -> io.adaptivecards.objectmodel.HorizontalAlignment.Center
//            HorizontalAlignment.RIGHT -> io.adaptivecards.objectmodel.HorizontalAlignment.Right
//            else -> null
//        }
//
//    private fun mapSpacing(spacing: Spacing?) =
//        when (spacing) {
//            Spacing.NONE -> io.adaptivecards.objectmodel.Spacing.None
//            Spacing.SMALL -> io.adaptivecards.objectmodel.Spacing.Small
//            Spacing.MEDIUM -> io.adaptivecards.objectmodel.Spacing.Medium
//            Spacing.LARGE -> io.adaptivecards.objectmodel.Spacing.Large
//            Spacing.EXTRA_LARGE -> io.adaptivecards.objectmodel.Spacing.ExtraLarge
//            Spacing.PADDING -> io.adaptivecards.objectmodel.Spacing.Padding
//            else -> null
//        }
//
//    private fun mapTargetWidth(targetWidth: TargetWidthType?) =
//        when (targetWidth) {
//            TargetWidthType.WIDE -> io.adaptivecards.objectmodel.TargetWidthType.Wide
//            TargetWidthType.STANDARD -> io.adaptivecards.objectmodel.TargetWidthType.Standard
//            TargetWidthType.NARROW -> io.adaptivecards.objectmodel.TargetWidthType.Narrow
//            TargetWidthType.VERY_NARROW -> io.adaptivecards.objectmodel.TargetWidthType.VeryNarrow
//            TargetWidthType.AT_LEAST_WIDE -> io.adaptivecards.objectmodel.TargetWidthType.AtLeastWide
//            TargetWidthType.AT_LEAST_STANDARD -> io.adaptivecards.objectmodel.TargetWidthType.AtLeastStandard
//            TargetWidthType.AT_LEAST_NARROW -> io.adaptivecards.objectmodel.TargetWidthType.AtLeastNarrow
//            TargetWidthType.AT_LEAST_VERY_NARROW -> io.adaptivecards.objectmodel.TargetWidthType.AtLeastVeryNarrow
//            TargetWidthType.AT_MOST_WIDE -> io.adaptivecards.objectmodel.TargetWidthType.AtMostWide
//            TargetWidthType.AT_MOST_STANDARD -> io.adaptivecards.objectmodel.TargetWidthType.AtMostStandard
//            TargetWidthType.AT_MOST_NARROW -> io.adaptivecards.objectmodel.TargetWidthType.AtMostNarrow
//            TargetWidthType.AT_MOST_VERY_NARROW -> io.adaptivecards.objectmodel.TargetWidthType.AtMostVeryNarrow
//            else -> null
//        }
//
//    private fun mapToLayouts(layouts: ArrayList<Layout>?) : io.adaptivecards.objectmodel.LayoutVector{
//        val vector = io.adaptivecards.objectmodel.LayoutVector()
//        layouts?.forEach {
//            when (it.layoutContainerType) {
//                LayoutContainerType.FLOW -> {
//                    val flowLayout = it as LayoutElement.FlowLayout
//                    io.adaptivecards.objectmodel.FlowLayout().apply {
//                        SetLayoutContainerType(io.adaptivecards.objectmodel.LayoutContainerType.Flow)
//                        SetTargetWidth(mapTargetWidth(flowLayout.targetWidth))
//                        SetHorizontalAlignment(mapHorizontalAlignment(flowLayout.horizontalAlignment))
//                        //SetItemWidth(flowLayout.itemWidth ?: "0")
//                        SetItemPixelWidth(flowLayout.pixelItemWidth)
//                        SetMinItemPixelWidth(flowLayout.minItemWidth?.toInt() ?: 0)
//                        SetMaxItemPixelWidth(flowLayout.maxItemWidth?.toInt() ?: 0)
//                        SetRowSpacing(mapSpacing(flowLayout.rowSpacing))
//                        SetColumnSpacing(mapSpacing(flowLayout.columnSpacing))
//                    }.also {
//                        vector.add(it)
//                    }
//                }
//
//                LayoutContainerType.AREAGRID -> {
//                    val areaLayout = it as LayoutElement.AreaGridLayout
//                    io.adaptivecards.objectmodel.AreaGridLayout().apply {
//                        SetLayoutContainerType(io.adaptivecards.objectmodel.LayoutContainerType.AreaGrid)
//                        SetTargetWidth(mapTargetWidth(areaLayout.targetWidth))
//                        SetRowSpacing(mapSpacing(areaLayout.rowSpacing))
//                        SetColumnSpacing(mapSpacing(areaLayout.columnSpacing))
//                        val stringVector = StringVector()
//                        areaLayout.columns.forEach {
//                            stringVector.add(it)
//                        }
//                        SetColumns(stringVector)
//                        val gridAreaVector = io.adaptivecards.objectmodel.GridAreaVector()
//                        areaLayout.areas.forEach {
//                            val gridArea = io.adaptivecards.objectmodel.GridArea().apply {
//                                SetRow(it.row)
//                                SetColumn(it.column)
//                                SetRowSpan(it.rowSpan)
//                                SetColumnSpan(it.columnSpan)
//                                SetName(it.name)
//                            }
//                            gridAreaVector.add(gridArea)
//                        }
//                    }.also {
//                        vector.add(it)
//                    }
//                }
//
//                else -> {
//
//                }
//            }
//        }
//        return vector
//    }
//
//}