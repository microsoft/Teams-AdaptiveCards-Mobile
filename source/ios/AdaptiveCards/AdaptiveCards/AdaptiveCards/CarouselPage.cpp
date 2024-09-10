//
//  CarouselPage.cpp
//  AdaptiveCards
//
//  Created by Abhishek Gupta on 02/09/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//
#include "CarouselPage.h"

using namespace AdaptiveCards;

CarouselPage::CarouselPage()
{
    PopulateKnownPropertiesSet();
}

Json::Value CarouselPage::SerializeToJsonValue() const
{
    Json::Value root = BaseCardElement::SerializeToJsonValue();

    return root;
}

std::vector<std::shared_ptr<BaseCardElement>>& CarouselPage::getItems()
{
    return m_items;
}

void CarouselPage::setItems(std::vector<std::shared_ptr<BaseCardElement>> items)
{
    m_items = items;
}

std::shared_ptr<CarouselPage> CarouselPage::DeserializeFromString(ParseContext& context, const std::string& jsonString)
{
    return CarouselPage::Deserialize(context, ParseUtil::GetJsonValueFromString(jsonString));
}

std::shared_ptr<CarouselPage> CarouselPage::Deserialize(ParseContext& context, const Json::Value& json)
{
    ParseUtil::ExpectTypeString(json, CardElementType::CarouselPage);
    return CarouselPage::DeserializeWithoutCheckingType(context, json);
}

std::shared_ptr<CarouselPage> CarouselPage::DeserializeWithoutCheckingType(ParseContext& context, const Json::Value& json)
{
    std::shared_ptr<CarouselPage> carouselPage = StyledCollectionElement::Deserialize<CarouselPage>(context, json);
    auto cardElements = ParseUtil::GetElementCollection<BaseCardElement>(true,
                                                                         context,
                                                                         json,
                                                                         AdaptiveCardSchemaKey::Items,
                                                                         false);
    carouselPage->setItems(cardElements);
    return carouselPage;
}

void CarouselPage::PopulateKnownPropertiesSet()
{
    
}
