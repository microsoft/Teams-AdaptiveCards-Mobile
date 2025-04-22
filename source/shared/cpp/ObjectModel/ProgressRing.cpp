// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
#include "pch.h"
#include <iomanip>
#include <regex>
#include <iostream>
#include <codecvt>
#include "ParseContext.h"
#include "ParseUtil.h"
#include "Util.h"
#include "ProgressRing.h"

using namespace AdaptiveCards;

ProgressRing::ProgressRing() : BaseCardElement(CardElementType::ProgressRing) {
    PopulateKnownPropertiesSet();
}

void ProgressRing::PopulateKnownPropertiesSet(){
    m_knownProperties.insert({
        AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Label),
        AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::LabelPosition),
        AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Size)
    });
}

const std::string ProgressRing::GetLabel() const {
    return m_label;
}

const LabelPosition ProgressRing::GetLabelPosition() const {
    return m_labelPosition;
}

const ProgressSize ProgressRing::GetSize() const {
    return m_size;
}

const std::optional<HorizontalAlignment> ProgressRing::GetHorizontalAlignment() const {
    return m_horizontalAlignment;
}

Json::Value ProgressRing::SerializeToJsonValue() const {
    Json::Value root = BaseCardElement::SerializeToJsonValue();
    root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Label)] = GetLabel();
    root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::LabelPosition)] = LabelPositionToString(GetLabelPosition());
    root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Size)] = ProgressSizeToString(GetSize());

    if (m_horizontalAlignment.has_value()) {
        root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::HorizontalAlignment)] =HorizontalAlignmentToString(m_horizontalAlignment.value_or(HorizontalAlignment::Left));
    }
    return root;
}

std::shared_ptr<BaseCardElement> ProgressRingParser::Deserialize(ParseContext& context, const Json::Value& json) {
    ParseUtil::ExpectTypeString(json, CardElementType::ProgressRing);

    std::shared_ptr<ProgressRing> element = BaseCardElement::Deserialize<ProgressRing>(context, json);
    element->m_label = ParseUtil::GetString(json, AdaptiveCardSchemaKey::Label, "",false);
    element->m_labelPosition = ParseUtil::GetEnumValue<LabelPosition>(json, AdaptiveCardSchemaKey::LabelPosition, LabelPosition::Above, LabelPositionFromString);
    element->m_size = ParseUtil::GetEnumValue<ProgressSize>(json, AdaptiveCardSchemaKey::Size, ProgressSize::Medium, ProgressSizeFromString);
    element->m_horizontalAlignment = ParseUtil::GetOptionalEnumValue<HorizontalAlignment>(
            json, AdaptiveCardSchemaKey::HorizontalAlignment, HorizontalAlignmentFromString);

    return element;
}

std::shared_ptr<BaseCardElement> ProgressRingParser::DeserializeFromString(ParseContext& context, const std::string& jsonString) {
    return ProgressRingParser::Deserialize(context, ParseUtil::GetJsonValueFromString(jsonString));
}



