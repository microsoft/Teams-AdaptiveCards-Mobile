// Created by mejain on 10/08/25.
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
#pragma once

#include <utility>

#include "pch.h"
#include "BaseActionElement.h"

namespace AdaptiveCards {

    class References {

    public:
        References(){}
        References(
                ReferenceType type,
                std::string abstract,
                std::string title,
                std::string url,
                std::vector<std::string> keywords) :
                m_type(type), m_abstract(abstract), m_title(title), m_url(url), m_keywords(std::move(keywords)) {
        }

        bool ShouldSerialize() const;
        std::string Serialize() const;
        Json::Value SerializeToJsonValue() const;

        const ReferenceType GetType() const;
        const std::string GetAbstract() const;
        const std::string GetTitle() const;
        const std::string GetUrl() const;
        const std::vector<std::string> GetKeywords() const;

        static std::shared_ptr<References> Deserialize(ParseContext& context, const Json::Value& json);
        static std::shared_ptr<References> DeserializeFromString(ParseContext& context, const std::string& jsonString);

    private:
        ReferenceType m_type;
        std::string m_abstract;
        std::string m_title;
        std::string m_url;
        std::vector<std::string> m_keywords;
    };
} // namespace AdaptiveCards
