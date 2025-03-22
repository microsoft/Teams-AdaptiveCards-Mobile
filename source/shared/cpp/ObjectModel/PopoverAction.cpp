// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
#include "pch.h"
#include "SharedAdaptiveCard.h"
#include "ParseUtil.h"
#include "PopoverAction.h"
#include "ParseContext.h"

using namespace AdaptiveCards;

PopoverAction::PopoverAction() : BaseActionElement(ActionType::Popover) {
    PopulateKnownPropertiesSet();
}

Json::Value PopoverAction::SerializeToJsonValue() const {
    Json::Value root = BaseActionElement::SerializeToJsonValue();
    root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Content)] = GetContent()->SerializeToJsonValue();
    root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::DisplayArrow)] = GetDisplayArrow();
    root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::MaxPopoverWidth)] = GetMaxPopoverWidth();
    root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Position)] = GetPosition();
    return root;
}

void PopoverAction::PopulateKnownPropertiesSet() {
    m_knownProperties.insert({AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Content)});
    m_knownProperties.insert({AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::DisplayArrow)});
    m_knownProperties.insert({AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::MaxPopoverWidth)});
    m_knownProperties.insert({AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Position)});
}

const bool PopoverAction::GetDisplayArrow() const {
    return m_displayArrow;
}

const std::string PopoverAction::GetMaxPopoverWidth() const {
    return m_maxPopoverWidth;
}

const std::string PopoverAction::GetPosition() const {
    return m_position;
}

const std::shared_ptr<BaseCardElement> PopoverAction::GetContent() const {
    return m_content;
}

std::shared_ptr<BaseActionElement> PopoverActionActionParser::Deserialize(ParseContext& context, const Json::Value& json) {
    std::shared_ptr<PopoverAction> popoverAction = BaseActionElement::Deserialize<PopoverAction>(context, json);

    const std::string& propertyName = AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Content);
    popoverAction->m_content = BaseCardElement::Deserialize<BaseCardElement>(context, json.get(propertyName, Json::Value()));
    popoverAction->m_displayArrow = ParseUtil::GetBool(json, AdaptiveCardSchemaKey::DisplayArrow,DEFAULT_DISPLAY_ARROW);
    popoverAction->m_maxPopoverWidth = ParseUtil::GetString(json, AdaptiveCardSchemaKey::MaxPopoverWidth,"", false);
    popoverAction->m_position = ParseUtil::GetString(json, AdaptiveCardSchemaKey::MaxPopoverWidth, DEFAULT_POSITION, false);
    return popoverAction;
}

std::shared_ptr<BaseActionElement> PopoverActionActionParser::DeserializeFromString(ParseContext& context, const std::string& jsonString) {
    return PopoverActionActionParser::Deserialize(context, ParseUtil::GetJsonValueFromString(jsonString));
}
