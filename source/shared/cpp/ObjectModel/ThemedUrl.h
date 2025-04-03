//
//  ThemedUrl.h
//  AdaptiveCards
//
//  Created by Meeth Jain.
//  Copyright © 2024 Microsoft. All rights reserved.
//
#pragma once

#include "ParseContext.h"
#include "ParseUtil.h"

namespace AdaptiveCards
{

    class ThemedUrl {

    public:
        ThemedUrl();
        ThemedUrl(const ThemedUrl&) = default;
        ThemedUrl(ThemedUrl&&) = default;
        ThemedUrl& operator=(const ThemedUrl&) = default;
        ThemedUrl& operator=(ThemedUrl&&) = default;
        ~ThemedUrl() = default;

        Json::Value SerializeToJsonValue() const;
        static std::shared_ptr<ThemedUrl> Deserialize(ParseContext&, const Json::Value& json);

        const Theme GetTheme() const;
        const std::string& GetUrl() const;

        static const std::string& GetThemedUrl(const Theme theme, std::vector<std::shared_ptr<AdaptiveCards::ThemedUrl>> themedUrls, const std::string& defaultIconUrl) {
            if (!themedUrls.empty()) {
                for (const auto &themedUrl: themedUrls) {
                    if (themedUrl->GetTheme() == theme && !themedUrl->GetUrl().empty()) {
                        return themedUrl->GetUrl();
                    }
                }
            }
            return defaultIconUrl;
        }

    private:
        void PopulateKnownPropertiesSet();

        std::unordered_set<std::string> m_knownProperties;
        Theme m_theme;
        std::string m_url;
    };
} // namespace AdaptiveCards
