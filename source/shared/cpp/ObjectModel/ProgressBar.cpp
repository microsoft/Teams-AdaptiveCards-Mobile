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
#include "ProgressBar.h"

using namespace AdaptiveCards;

const static ProgressBarColor DEFAULT_COLOR = ProgressBarColor::Accent;
constexpr static double DEFAULT_MAX = 100.0;
const static HorizontalAlignment DEFAULT_HORIZONTAL_ALIGNMENT = HorizontalAlignment::Left;

ProgressBar::ProgressBar() : BaseCardElement(CardElementType::ProgressBar)
    ,m_color(DEFAULT_COLOR), m_max(DEFAULT_MAX), m_value(0.0), m_horizontalAlignment(DEFAULT_HORIZONTAL_ALIGNMENT) {
    PopulateKnownPropertiesSet();
}

void ProgressBar::PopulateKnownPropertiesSet(){
    m_knownProperties.insert({
        AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Label),
        AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::LabelPosition),
        AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Size),
        AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::HorizontalAlignment)
    });
}

ProgressBarColor ProgressBar::GetColor() const {
    return m_color;
}

double ProgressBar::GetMax() const {
    return m_max;
}

std::optional<double> ProgressBar::GetValue() const {
    return m_value;
}

const HorizontalAlignment ProgressBar::GetHorizontalAlignment() const {
    return m_horizontalAlignment;
}

Json::Value ProgressBar::SerializeToJsonValue() const {
    Json::Value root = BaseCardElement::SerializeToJsonValue();
    root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Color)] = ProgressBarColorToString(m_color);
    root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Max)] = m_max;
    if (m_value.has_value()) {
        root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Max)] = m_value.value();
    }
    root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::HorizontalAlignment)] = HorizontalAlignmentToString(m_horizontalAlignment);
    return root;
}


std::shared_ptr<BaseCardElement> ProgressBarParser::Deserialize(ParseContext& context, const Json::Value& json) {
    ParseUtil::ExpectTypeString(json, CardElementType::ProgressBar);

    std::shared_ptr<ProgressBar> element = BaseCardElement::Deserialize<ProgressBar>(context, json);
    element->m_color = ParseUtil::GetEnumValue<ProgressBarColor>(json, AdaptiveCardSchemaKey::Color, DEFAULT_COLOR,ProgressBarColorFromString);
    element->m_max = ParseUtil::GetDouble(json, AdaptiveCardSchemaKey::Max, DEFAULT_MAX, false);
    auto value = ParseUtil::GetOptionalDouble(json, AdaptiveCardSchemaKey::Value);
    if (value.has_value() && value.value() > element->m_max) {
        value = element->m_max;
    }
    element->m_value = value;
    element->m_horizontalAlignment = ParseUtil::GetEnumValue<HorizontalAlignment>(
            json, AdaptiveCardSchemaKey::HorizontalAlignment,
            DEFAULT_HORIZONTAL_ALIGNMENT, HorizontalAlignmentFromString,
            false);
    return element;
}

std::shared_ptr<BaseCardElement> ProgressBarParser::DeserializeFromString(ParseContext& context, const std::string& jsonString) {
    return ProgressBarParser::Deserialize(context, ParseUtil::GetJsonValueFromString(jsonString));
}



