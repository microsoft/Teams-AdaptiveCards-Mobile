// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
#pragma once

#include "pch.h"
#include "BaseActionElement.h"
#include "ActionParserRegistration.h"

namespace AdaptiveCards
{
    class PopoverAction : public BaseActionElement
    {

    public:
        PopoverAction();
        PopoverAction(const PopoverAction&) = default;
        PopoverAction(PopoverAction&&) = default;
        PopoverAction& operator=(const PopoverAction&) = default;
        PopoverAction& operator=(PopoverAction&&) = default;
        ~PopoverAction() = default;

        Json::Value SerializeToJsonValue() const override;

        const std::shared_ptr<AdaptiveCards::BaseCardElement> GetContent() const;
        const void SetContent(const std::shared_ptr<AdaptiveCards::BaseCardElement>);

    private:
        void PopulateKnownPropertiesSet();
        std::shared_ptr<BaseCardElement> m_content;
    };

    class PopoverActionActionParser : public ActionElementParser
    {

    public:
        PopoverActionActionParser() = default;
        PopoverActionActionParser(const PopoverActionActionParser&) = default;
        PopoverActionActionParser(PopoverActionActionParser&&) = default;
        PopoverActionActionParser& operator=(const PopoverActionActionParser&) = default;
        PopoverActionActionParser& operator=(PopoverActionActionParser&&) = default;
        virtual ~PopoverActionActionParser() = default;

        std::shared_ptr<BaseActionElement> Deserialize(ParseContext& context, const Json::Value& value) override;
        std::shared_ptr<BaseActionElement> DeserializeFromString(ParseContext& context, const std::string& jsonString) override;
    };
} // namespace AdaptiveCards
