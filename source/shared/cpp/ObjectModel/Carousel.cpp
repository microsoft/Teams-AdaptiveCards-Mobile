//
//  Carousel.cpp
//  AdaptiveCards
//
//  Created by Abhishek Gupta on 30/08/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#include "pch.h"
#include "ParseUtil.h"
#include "ParseContext.h"
#include "Util.h"
#include "Carousel.h"
#import "CarouselPage.h"

using namespace AdaptiveCards;

Carousel::Carousel() : StyledCollectionElement(CardElementType::Carousel)
{
    PopulateKnownPropertiesSet();
}

Json::Value Carousel::SerializeToJsonValue() const
{
    Json::Value root = StyledCollectionElement::SerializeToJsonValue();

    return root;
}

const std::vector<std::shared_ptr<BaseCardElement>>& Carousel::GetItems() const
{
    return m_pages;
}

std::vector<std::shared_ptr<BaseCardElement>>& Carousel::GetItems()
{
    return m_pages;
}

PageAnimation Carousel::getPageAnimation()
{
    return m_pageAnimation;
}

void Carousel::setPageAnimation(PageAnimation value)
{
    m_pageAnimation = value;
}

std::shared_ptr<BaseCardElement> CarouselParser::DeserializeFromString(ParseContext& context, const std::string& jsonString)
{
    return CarouselParser::Deserialize(context, ParseUtil::GetJsonValueFromString(jsonString));
}

std::shared_ptr<BaseCardElement> CarouselParser::Deserialize(ParseContext& context, const Json::Value& json)
{
    ParseUtil::ExpectTypeString(json, CardElementType::Carousel);
    return CarouselParser::DeserializeWithoutCheckingType(context, json);
}

std::shared_ptr<BaseCardElement> CarouselParser::DeserializeWithoutCheckingType(ParseContext& context, const Json::Value& json)
{
    std::shared_ptr<Carousel> carousel = StyledCollectionElement::Deserialize<Carousel>(context, json);
    carousel->setPageAnimation(ParseUtil::GetEnumValue(json, AdaptiveCardSchemaKey::PageAnimation,PageAnimation::Slide,PageAnimationFromString));
    return carousel;
}

void Carousel::DeserializeChildren(ParseContext& context, const Json::Value& value)
{
    auto elementArray = ParseUtil::GetArray(value, AdaptiveCardSchemaKey::Pages, false);

    std::vector<std::shared_ptr<BaseCardElement>> elements;
    if (elementArray.empty())
    {
        return;
    }
    
    elements.reserve(elementArray.size());

  for (const Json::Value& CarouselPage : elementArray)
    {
        auto el = CarouselPage::Deserialize(context,CarouselPage);
        if (el != nullptr)
        {
            elements.push_back(el);
        }
    }
    m_pages = elements;
}

void Carousel::PopulateKnownPropertiesSet()
{
    
}

void Carousel::GetResourceInformation(std::vector<RemoteResourceInformation>& resourceInfo)
{
    auto items = GetItems();
    StyledCollectionElement::GetResourceInformation<BaseCardElement>(resourceInfo, items);
    return;
}

