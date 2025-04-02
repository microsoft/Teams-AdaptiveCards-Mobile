// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
#pragma once

#include "pch.h"
#include "BaseActionElement.h"
#include "ActionParserRegistration.h"

namespace AdaptiveCards
{
    static const std::string DEFAULT_POSITION = "Above";
    static const bool DEFAULT_DISPLAY_ARROW = true;

    class PopoverAction : public BaseActionElement {

        friend class PopoverActionParser;

    public:
        PopoverAction();
        PopoverAction(const PopoverAction&) = default;
        PopoverAction(PopoverAction&&) = default;
        PopoverAction& operator=(const PopoverAction&) = default;
        PopoverAction& operator=(PopoverAction&&) = default;
        ~PopoverAction() = default;

        Json::Value SerializeToJsonValue() const override;

        const bool GetDisplayArrow() const;
        const std::string GetMaxPopoverWidth() const;
        const std::string GetPosition() const;
        const std::shared_ptr<AdaptiveCards::BaseCardElement> GetContent() const;

    private:
        void PopulateKnownPropertiesSet();
        std::shared_ptr<BaseCardElement> m_content;
        bool m_displayArrow;
        std::string m_position;
        std::string m_maxPopoverWidth;
    };

    class PopoverActionParser : public ActionElementParser
    {

    public:
        PopoverActionParser() = default;
        PopoverActionParser(const PopoverActionParser&) = default;
        PopoverActionParser(PopoverActionParser&&) = default;
        PopoverActionParser& operator=(const PopoverActionParser&) = default;
        PopoverActionParser& operator=(PopoverActionParser&&) = default;
        virtual ~PopoverActionParser() = default;

        std::shared_ptr<BaseActionElement> Deserialize(ParseContext& context, const Json::Value& value) override;
        std::shared_ptr<BaseActionElement> DeserializeFromString(ParseContext& context, const std::string& jsonString) override;
    };
} // namespace AdaptiveCards
