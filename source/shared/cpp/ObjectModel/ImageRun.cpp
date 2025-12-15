// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
#include "pch.h"
#include "ImageRun.h"

using namespace AdaptiveCards;

ImageRun::ImageRun() :
        Inline(InlineElementType::CitationRun), m_textElementProperties(std::make_shared<RichTextElementProperties>()),
        m_referenceIndex(1) {
    PopulateKnownPropertiesSet();
}

void ImageRun::PopulateKnownPropertiesSet() {
    m_textElementProperties->PopulateKnownPropertiesSet(m_knownProperties);
}

Json::Value ImageRun::SerializeToJsonValue() const {
    Json::Value root{};
    root = m_textElementProperties->SerializeToJsonValue(root);
    root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Type)] = GetInlineTypeString();
    root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::ReferenceIndex)] = m_referenceIndex;
    root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Text)] = m_textElementProperties->GetText();
    return root;
}

int ImageRun::GetReferenceIndex() const {
    return m_referenceIndex;
}

std::string ImageRun::GetText() const {
    return m_textElementProperties->GetText();
}

DateTimePreparser ImageRun::GetTextForDateParsing() const {
    return m_textElementProperties->GetTextForDateParsing();
}

std::shared_ptr<Inline> ImageRun::Deserialize(ParseContext& context, const Json::Value& json) {
    std::shared_ptr<ImageRun> inlineCitationRun = std::make_shared<ImageRun>();
    ParseUtil::ExpectTypeString(json, InlineElementTypeToString(InlineElementType::CitationRun));

    inlineCitationRun->m_textElementProperties->Deserialize(context, json);
    inlineCitationRun->m_referenceIndex = ParseUtil::GetInt(json, AdaptiveCardSchemaKey::ReferenceIndex, 1, true);
    HandleUnknownProperties(json, inlineCitationRun->m_knownProperties, inlineCitationRun->m_additionalProperties);

    return inlineCitationRun;
}
