package io.adaptivecards.renderer.input

import android.text.SpannableStringBuilder
import io.adaptivecards.objectmodel.BaseInputElement
import io.adaptivecards.objectmodel.ForegroundColor
import io.adaptivecards.objectmodel.HostConfig
import io.adaptivecards.objectmodel.TextInput
import io.adaptivecards.renderer.RenderArgs
import io.adaptivecards.renderer.Util
import io.adaptivecards.renderer.readonly.RichTextBlockRenderer

object InputUtils {

    @JvmStatic
    fun appendRequiredLabelSuffix(
        input: CharSequence,
        label: String?,
        hostConfig: HostConfig,
        renderArgs: RenderArgs
    ): SpannableStringBuilder {

        val paragraph = SpannableStringBuilder(input)

        if (label.isNullOrEmpty() || !TextInput.getIsRequired(label)) {
            return paragraph
        }

        val inputLabelConfig = hostConfig.GetInputs().label.requiredInputs
        val spanStart = paragraph.length
        var requiredLabelSuffix = inputLabelConfig.suffix
        if (requiredLabelSuffix == null || requiredLabelSuffix.isEmpty()) {
            requiredLabelSuffix = " *"
        }
        paragraph.append(requiredLabelSuffix)
        return RichTextBlockRenderer.setColor(paragraph, spanStart, spanStart + requiredLabelSuffix.length,
                ForegroundColor.Attention, false, hostConfig, renderArgs)
    }

    @JvmStatic
    fun shouldShowLabel(element: BaseInputElement) : Boolean {
        // In case there's a corresponding label for TextInput from TextBlock/RichTextBlock
        // we don't show the Label
        val textInput = Util.tryCastTo(element, TextInput::class.java)
        return textInput == null || TextInput.getLabel(textInput.GetId()).isEmpty()
    }
}
