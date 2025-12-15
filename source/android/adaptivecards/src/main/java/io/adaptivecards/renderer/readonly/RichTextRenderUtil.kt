package io.adaptivecards.renderer.readonly

import io.adaptivecards.objectmodel.CitationRun
import io.adaptivecards.objectmodel.Inline

object RichTextRenderUtil {

    @JvmStatic
    fun splitInlines(inlines: List<Inline>): List<List<Inline>> {
        if (inlines.isEmpty()) return emptyList()

        val result = mutableListOf<MutableList<Inline>>()
        var currentGroup = mutableListOf<Inline>()

        for (inline in inlines) {
            when (inline) {
                is CitationRun -> {
//                    // flush current group if not empty
//                    if (currentGroup.isNotEmpty()) {
//                        result.add(currentGroup)
//                        currentGroup = mutableListOf()
//                    }
//
//                    // add this Image/Icon as its own group
//                    result.add(mutableListOf(inline))
                    currentGroup.add(inline)
                }
                else -> {
                    // accumulate normal items
                    currentGroup.add(inline)
                }
            }
        }

        // add remaining text/citation group if any
        if (currentGroup.isNotEmpty()) {
            result.add(currentGroup)
        }

        return result
    }
}