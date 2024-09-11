//
//  CarouselPage.cpp
//  AdaptiveCards
//
//  Created by Abhishek Gupta on 02/09/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//
#include "CarouselPage.h"

using namespace AdaptiveCards;

CarouselPage::CarouselPage() : StyledCollectionElement(CardElementType::CarouselPage)
{
    PopulateKnownPropertiesSet();
}

Json::Value CarouselPage::SerializeToJsonValue() const
{
    Json::Value root = BaseCardElement::SerializeToJsonValue();

    return root;
}

const std::vector<std::shared_ptr<BaseCardElement>>& CarouselPage::GetItems() const
{
    return m_items;
}

std::vector<std::shared_ptr<BaseCardElement>>& CarouselPage::GetItems()
{
    return m_items;
}

const std::vector<std::shared_ptr<Layout>>& CarouselPage::GetLayouts() const
{
    return m_layouts;
}

void CarouselPage::SetLayouts(const std::vector<std::shared_ptr<Layout>>& value)
{
    m_layouts = value;
}

std::shared_ptr<CarouselPage> CarouselPage::Deserialize(ParseContext& context, const Json::Value& json)
{
    ParseUtil::ExpectTypeString(json, CardElementType::CarouselPage);
    return CarouselPage::DeserializeWithoutCheckingType(context, json);
}

std::shared_ptr<CarouselPage> CarouselPage::DeserializeWithoutCheckingType(ParseContext& context, const Json::Value& json)
{
    std::shared_ptr<CarouselPage> carouselPage = StyledCollectionElement::Deserialize<CarouselPage>(context, json);
    return carouselPage;
}

void CarouselPage::DeserializeChildren(ParseContext& context, const Json::Value& value)
{
    // Parse items
    auto cardElements = ParseUtil::GetElementCollection<BaseCardElement>(
        true, // isTopToBottomContainer
        context,
        value,
        AdaptiveCardSchemaKey::Items,
        false); // isRequired
    m_items = std::move(cardElements);
}

void CarouselPage::PopulateKnownPropertiesSet()
{
    
}
