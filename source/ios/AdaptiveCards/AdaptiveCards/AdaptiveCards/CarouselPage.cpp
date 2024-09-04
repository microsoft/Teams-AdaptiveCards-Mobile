//
//  CarouselPage.cpp
//  AdaptiveCards
//
//  Created by Abhishek Gupta on 02/09/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//
#include "CarouselPage.h"

using namespace AdaptiveCards;

Json::Value CarouselPage::SerializeToJsonValue() const
{
    Json::Value root = StyledCollectionElement::SerializeToJsonValue();

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

std::shared_ptr<BaseCardElement> CarouselPageParser::DeserializeFromString(ParseContext& context, const std::string& jsonString)
{
    return CarouselPageParser::Deserialize(context, ParseUtil::GetJsonValueFromString(jsonString));
}

std::shared_ptr<BaseCardElement> CarouselPageParser::Deserialize(ParseContext& context, const Json::Value& json)
{
    ParseUtil::ExpectTypeString(json, CardElementType::Carousel);
    return CarouselPageParser::DeserializeWithoutCheckingType(context, json);
}

//std::shared_ptr<BaseCardElement> CarouselPageParser::DeserializeWithoutCheckingType(ParseContext& context, const Json::Value& json)
//{
//    std::shared_ptr<StyledCollectionElement> carouselPage = StyledCollectionElement::Deserialize<StyledCollectionElement>(context, json);
//    return carouselPage;
//}

void CarouselPage::DeserializeChildren(ParseContext& context, const Json::Value& value)
{
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
