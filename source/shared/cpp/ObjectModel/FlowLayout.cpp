//
//  FlowLayout.cpp
//  AdaptiveCards
//
//  Created by Abhishek on 02/08/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#include "FlowLayout.h"
#include "pch.h"
#include "ParseContext.h"
#include "ParseUtil.h"

using namespace AdaptiveCards;

ItemFit FlowLayout::GetItemFit() const
{
    return m_itemFit;
}

void FlowLayout::setItemFit(const ItemFit& value)
{
    m_itemFit = value;
}

Spacing FlowLayout::GetRowSpacing() const
{
    return m_rowSpacing;
}

void FlowLayout::SetRowSpacing(const Spacing& value)
{
    m_rowSpacing = value;
}

Spacing FlowLayout::GetColumnSpacing() const
{
    return m_columnSpacing;
}

void FlowLayout::SetColumnSpacing(const Spacing& value)
{
    m_columnSpacing = value;
}

HorizontalAlignment FlowLayout::GetHorizontalAlignment() const
{
    return m_horizontalAlignment;
}

void FlowLayout::SetHorizontalAlignment(const HorizontalAlignment& value)
{
    m_horizontalAlignment = value;
}

std::optional<std::string> FlowLayout::GetItemWidth() const
{
    return m_itemWidth;
}

void FlowLayout::SetItemWidth(const std::optional<std::string>& value)
{
    m_itemWidth = value;
}

std::optional<std::string> FlowLayout::GetMinItemWidth() const
{
    return m_minItemWidth;
}

void FlowLayout::SetMinItemWidth(const std::optional<std::string>& value)
{
    m_minItemWidth = value;
}

std::optional<std::string> FlowLayout::GetMaxItemWidth() const
{
    return m_maxItemWidth;
}

void FlowLayout::SetMaxItemWidth(const std::optional<std::string>& value)
{
    m_maxItemWidth = value;
}

bool FlowLayout::ShouldSerialize() const
{
    return true;
}

std::string FlowLayout::Serialize() const
{
    return ParseUtil::JsonToString(SerializeToJsonValue());
}

Json::Value FlowLayout::SerializeToJsonValue() const
{
    Json::Value root;

    if (m_itemFit != ItemFit::Fit)
    {
        root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::itemFit)] = ItemFitToString(m_itemFit);
    }
    
    if (m_rowSpacing != Spacing::Default)
    {
        root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::rowSpacing)] = SpacingToString(m_rowSpacing);
    }
    
    if (m_columnSpacing != Spacing::Default)
    {
        root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::rowSpacing)] = SpacingToString(m_columnSpacing);
    }
    
    if (m_horizontalAlignment != HorizontalAlignment::Center)
    {
        root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::horizontalItemsAlignment)] = HorizontalAlignmentToString(m_horizontalAlignment);
    }
    
    if (m_itemWidth.has_value())
    {
        root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::itemWidth)] = m_itemWidth.value_or("");
    }
    
    if (m_minItemWidth.has_value())
    {
        root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::minItemWidth)] = m_minItemWidth.value_or("");
    }
    
    if (m_maxItemWidth.has_value())
    {
        root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::maxItemWidth)] = m_maxItemWidth.value_or("");
    }

    return root;
}

std::shared_ptr<FlowLayout> FlowLayout::Deserialize(const Json::Value& json)
{
    
    std::shared_ptr<Layout> base_layout = Layout::Deserialize(json);
    std::shared_ptr<FlowLayout> layout = std::make_shared<FlowLayout>();
    layout->SetLayoutContainerType(base_layout->GetLayoutContainerType());
    layout->SetTargetWidth(base_layout->GetTargetWidth());
    layout->setItemFit(ParseUtil::GetEnumValue<ItemFit>(json, AdaptiveCardSchemaKey::itemFit, ItemFit::Fit, ItemFitFromString));
    layout->SetRowSpacing(ParseUtil::GetEnumValue<Spacing>(json, AdaptiveCardSchemaKey::rowSpacing, Spacing::Default, SpacingFromString));
    layout->SetColumnSpacing(ParseUtil::GetEnumValue<Spacing>(json, AdaptiveCardSchemaKey::columnSpacing, Spacing::Default, SpacingFromString));
    layout->SetHorizontalAlignment(ParseUtil::GetEnumValue<HorizontalAlignment>(json, AdaptiveCardSchemaKey::horizontalItemsAlignment, HorizontalAlignment::Center, HorizontalAlignmentFromString));
    layout->SetItemWidth(ParseUtil::GetOptionalString(json, AdaptiveCardSchemaKey::itemWidth));
    layout->SetMinItemWidth(ParseUtil::GetOptionalString(json, AdaptiveCardSchemaKey::minItemWidth));
    layout->SetMaxItemWidth(ParseUtil::GetOptionalString(json, AdaptiveCardSchemaKey::maxItemWidth));
    return layout;
}

std::shared_ptr<FlowLayout> FlowLayout::DeserializeFromString(const std::string& jsonString)
{
    return FlowLayout::Deserialize(ParseUtil::GetJsonValueFromString(jsonString));
}
