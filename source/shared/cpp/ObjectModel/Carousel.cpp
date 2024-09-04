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



//std::shared_ptr<BaseActionElement> Carousel::GetSelectAction() const
//{
//    return m_selectAction;
//}

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
    
    return carousel;
}

void Carousel::DeserializeChildren(ParseContext& context, const Json::Value& value)
{
    
}

void Carousel::PopulateKnownPropertiesSet()
{
    
}
