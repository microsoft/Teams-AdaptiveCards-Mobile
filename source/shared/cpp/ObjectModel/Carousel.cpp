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

Carousel::Carousel(CardElementType derivedType) : StyledCollectionElement(derivedType)
{
    PopulateKnownPropertiesSet();
}

Json::Value Carousel::SerializeToJsonValue() const
{
    Json::Value root = StyledCollectionElement::SerializeToJsonValue();

    std::string const& itemsPropertyName = AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Pages);
    root[itemsPropertyName] = Json::Value(Json::arrayValue);
    for (const auto& cardElement : m_pages)
    {
        root[itemsPropertyName].append(cardElement->SerializeToJsonValue());
    }

    return root;
}

const std::vector<std::shared_ptr<AdaptiveCards::CarouselPage>>& Carousel::GetPages() const
{
    return m_pages;
}

std::vector<std::shared_ptr<AdaptiveCards::CarouselPage>>& Carousel::GetPages()
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

std::shared_ptr<BaseCardElement> CarouselParser::DeserializeFromString(ParseContext &context, const std::string &jsonString)
{
    // Convert the string into a JSON value and delegate.
    Json::Value json = ParseUtil::GetJsonValueFromString(jsonString);
    return Deserialize(context, json);
}

std::shared_ptr<BaseCardElement> CarouselParser::Deserialize(ParseContext &context, const Json::Value &json)
{
    // Verify the type is Carousel and then delegate.
    ParseUtil::ExpectTypeString(json, CardElementType::Carousel);
    return DeserializeWithoutCheckingType(context, json);
}

std::shared_ptr<BaseCardElement> CarouselParser::DeserializeWithoutCheckingType(ParseContext &context, const Json::Value &json)
{
    // Deserialize a Carousel instance using the helper method from StyledCollectionElement.
    auto carousel = StyledCollectionElement::Deserialize<Carousel>(context, json);
    
    // Set the page animation (defaulting to Slide if not present).
    carousel->setPageAnimation(
        ParseUtil::GetEnumValue(json, AdaptiveCardSchemaKey::PageAnimation, PageAnimation::Slide, PageAnimationFromString)
    );
    
    return carousel;
}

void Carousel::DeserializeChildren(ParseContext& context, const Json::Value& value)
{
    auto elementArray = ParseUtil::GetArray(value, AdaptiveCardSchemaKey::Pages, false);

    std::vector<std::shared_ptr<CarouselPage>> elements;
    if (elementArray.empty())
    {
        return;
    }

    elements.reserve(elementArray.size());

  for (const Json::Value& CarouselPage : elementArray)
    {
        auto el = CarouselPage::Deserialize(context, CarouselPage);
        if (el != nullptr)
        {
            elements.push_back(el);
        }
    }
    m_pages = elements;
}

void Carousel::PopulateKnownPropertiesSet()
{
    m_knownProperties.insert({
        AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::PageAnimation),
        AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::CarouselPage)
    });
}

void Carousel::GetResourceInformation(std::vector<RemoteResourceInformation>& resourceInfo)
{
    auto pages = GetPages();
    StyledCollectionElement::GetResourceInformation<CarouselPage>(resourceInfo, pages);
    return;
}

