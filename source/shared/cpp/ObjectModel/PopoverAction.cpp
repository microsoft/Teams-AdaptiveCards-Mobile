// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
#include "pch.h"
#include "SharedAdaptiveCard.h"
#include "ParseUtil.h"
#include "PopoverAction.h"
#include "ParseContext.h"

using namespace AdaptiveCards;

PopoverAction::PopoverAction() : BaseActionElement(ActionType::Popover)
{
    PopulateKnownPropertiesSet();
}

Json::Value PopoverAction::SerializeToJsonValue() const
{
    Json::Value root = BaseActionElement::SerializeToJsonValue();

    root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Content)] = GetContent()->SerializeToJsonValue();

    return root;
}

void PopoverAction::PopulateKnownPropertiesSet()
{
    m_knownProperties.insert({AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Content)});
}

std::shared_ptr<BaseCardElement> PopoverAction::GetContent() const
{
    return m_content;
}

void PopoverAction::SetContent(const std::shared_ptr<BaseCardElement> content)
{
    m_content = content;
}

std::shared_ptr<BaseActionElement> PopoverActionActionParser::DeserializeFromString(ParseContext& context, const std::string& jsonString)
{
    return PopoverActionActionParser::Deserialize(context, ParseUtil::GetJsonValueFromString(jsonString));
}

std::shared_ptr<BaseActionElement> PopoverActionActionParser::Deserialize(ParseContext& context, const Json::Value& json)
{
    std::shared_ptr<PopoverAction> popoverAction = BaseActionElement::Deserialize<PopoverAction>(context, json);

    const std::string& propertyName = AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Content);

    auto parseResult = AdaptiveCard::Deserialize(json.get(propertyName, Json::Value()), "", context);

    auto showCardWarnings = parseResult->GetWarnings();
    context.warnings.insert(context.warnings.end(), showCardWarnings.begin(), showCardWarnings.end());

    //popoverAction->SetContent(parseResult->GetAdaptiveCard());

    return popoverAction;
}
