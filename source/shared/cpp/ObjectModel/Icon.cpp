// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
#include "pch.h"
#include "Icon.h"
#include "ParseUtil.h"
#include "ParseContext.h"
#include "Util.h"

using namespace AdaptiveCards;

Icon::Icon() :
    BaseCardElement(CardElementType::Icon), m_iconStyle(IconStyle::Regular), m_iconSize(IconSize::Standard), m_foregroundColor(ForegroundColor::Default)
{
    PopulateKnownPropertiesSet();
}

Json::Value Icon::SerializeToJsonValue() const
{
    Json::Value root = BaseCardElement::SerializeToJsonValue();

    if (m_iconSize != IconSize::Standard)
    {
        root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Size)] = IconSizeToString(m_iconSize);
    }

    if (m_iconStyle != IconStyle::Regular)
    {
        root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Style)] = IconStyleToString(m_iconStyle);
    }

    if (m_foregroundColor != ForegroundColor::Default)
    {
        root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Color)] = ForegroundColorToString(m_foregroundColor);
    }

    if (!m_name.empty())
    {
        root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Name)] = m_name;
    }

    if (m_selectAction != nullptr)
    {
        root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::SelectAction)] =
            BaseCardElement::SerializeSelectAction(m_selectAction);
    }

    return root;
}

ForegroundColor Icon::getForgroundColor() const
{
    return m_foregroundColor;
}

void Icon::setForgroundColor(const ForegroundColor value)
{
    m_foregroundColor = value;
}

IconSize Icon::getIconSize() const
{
    return m_iconSize;
}

void Icon::setIconSize(const IconSize value)
{
    m_iconSize = value;
}

IconStyle Icon::getIconStyle() const
{
    return m_iconStyle;
}

void Icon::setIconStyle(const IconStyle value)
{
    m_iconStyle = value;
}

std::string Icon::GetName() const
{
    return m_name;
}

void Icon::SetName(const std::string& value)
{
    m_name = value;
}

std::shared_ptr<BaseActionElement> Icon::GetSelectAction() const
{
    return m_selectAction;
}

void Icon::SetSelectAction(const std::shared_ptr<BaseActionElement> action)
{
    m_selectAction = action;
}

std::shared_ptr<BaseCardElement> IconParser::DeserializeFromString(ParseContext& context, const std::string& jsonString)
{
    return IconParser::Deserialize(context, ParseUtil::GetJsonValueFromString(jsonString));
}

std::shared_ptr<BaseCardElement> IconParser::Deserialize(ParseContext& context, const Json::Value& json)
{
    ParseUtil::ExpectTypeString(json, CardElementType::Icon);
    return IconParser::DeserializeWithoutCheckingType(context, json);
}

std::shared_ptr<BaseCardElement> IconParser::DeserializeWithoutCheckingType(ParseContext& context, const Json::Value& json)
{
    std::shared_ptr<Icon> icon = BaseCardElement::Deserialize<Icon>(context, json);

    icon->setIconSize(ParseUtil::GetEnumValue<IconSize>(json, AdaptiveCardSchemaKey::Size, IconSize::Standard, IconSizeFromString));

    icon->setIconStyle(ParseUtil::GetEnumValue<IconStyle>(json, AdaptiveCardSchemaKey::Style, IconStyle::Regular, IconStyleFromString));

    icon->setForgroundColor(ParseUtil::GetEnumValue<ForegroundColor>(json, AdaptiveCardSchemaKey::Color, ForegroundColor::Default, ForegroundColorFromString));

    icon->SetName(ParseUtil::GetString(json, AdaptiveCardSchemaKey::Name));

    // Parse optional selectAction
    icon->SetSelectAction(ParseUtil::GetAction(context, json, AdaptiveCardSchemaKey::SelectAction, false));
    return icon;
}

void Icon::PopulateKnownPropertiesSet()
{
    m_knownProperties.insert(
        {AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Name),
         AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Size),
         AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Color),
         AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Style),
         AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::SelectAction)});
}

void Icon::GetResourceInformation(std::vector<RemoteResourceInformation>& resourceInfo)
{
    RemoteResourceInformation imageResourceInfo;
    imageResourceInfo.url = GetSVGResourceURL();
    imageResourceInfo.mimeType = "image";
    resourceInfo.push_back(imageResourceInfo);
}

std::string Icon::GetSVGResourceURL() const
{
    // format: "https://res-1.cdn.office.net/assets/fluentui-react-icons/2.0.226/<Icon Name>/<IconName><Size>Regular.json"
    std::string m_url = "https://res-1.cdn.office.net/assets/fluentui-react-icons/2.0.226/" + GetName() + "/" + GetName() + std::to_string(getSize()) + getStyle() + ".json";
    return m_url;
}

unsigned int Icon::getSize() const
{
    unsigned int _size = 24;
    switch (getIconSize())
    {
        case IconSize::xxSmall:
            _size = 12;
            break;
        case IconSize::xSmall:
            _size = 16;
            break;
        case IconSize::Small:
            _size = 20;
            break;
        case IconSize::Standard:
            _size = 24;
            break;
        case IconSize::Medium:
            _size = 28;
            break;
        case IconSize::Large:
            _size = 32;
            break;
        case IconSize::xLarge:
            _size = 40;
            break;
        case IconSize::xxLarge:
            _size = 48;
            break;
    }
    return _size;
}

std::string Icon::getStyle() const
{
    std::string _style = "Regular";
    switch (getIconStyle())
    {
        case IconStyle::Regular:
            _style = "Regular";
            break;
        case IconStyle::Filled:
            _style = "Filled";
            break;
    }
    return _style;
}
