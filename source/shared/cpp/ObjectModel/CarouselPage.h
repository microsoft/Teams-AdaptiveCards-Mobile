//
//  CarouselPage.h
//  AdaptiveCards
//
//  Created by Abhishek Gupta on 30/08/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#include "BaseActionElement.h"
#include "BaseCardElement.h"
#include "ElementParserRegistration.h"
#include "StyledCollectionElement.h"

namespace AdaptiveCards
{
    class CarouselPage : public StyledCollectionElement
    {
        public:
            CarouselPage(const CarouselPage&) = default;
            CarouselPage(CarouselPage&&) = default;
            CarouselPage& operator=(const CarouselPage&) = default;
            CarouselPage& operator=(CarouselPage&&) = default;

            Json::Value SerializeToJsonValue() const override;
            void DeserializeChildren(ParseContext& context, const Json::Value& value) override;
        private:
            void PopulateKnownPropertiesSet();
            std::vector<std::shared_ptr<BaseCardElement>>& GetItems();
            const std::vector<std::shared_ptr<BaseCardElement>>& GetItems() const;
        
        std::vector<std::shared_ptr<AdaptiveCards::BaseCardElement>> m_items;
    };

    class CarouselPageParser : public BaseCardElementParser
    {
        public:
            CarouselPageParser() = default;
            CarouselPageParser(const CarouselPageParser&) = default;
            CarouselPageParser(CarouselPageParser&&) = default;
            CarouselPageParser& operator=(const class CarouselPageParser&) = default;
            CarouselPageParser& operator=(CarouselPageParser&&) = default;
            virtual ~CarouselPageParser() = default;

            std::shared_ptr<BaseCardElement> Deserialize(ParseContext& context, const Json::Value& root) override;
            std::shared_ptr<BaseCardElement> DeserializeWithoutCheckingType(ParseContext& context, const Json::Value& root);
            std::shared_ptr<BaseCardElement> DeserializeFromString(ParseContext& context, const std::string& jsonString) override;
    };
}
