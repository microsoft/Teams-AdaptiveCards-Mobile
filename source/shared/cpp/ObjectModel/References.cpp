//
// Created by mejain on 10/08/25.
//
#include "pch.h"
#include "ParseUtil.h"
#include "References.h"

using namespace AdaptiveCards;

const ReferenceType References::GetType() const {
    return m_type;
}

const std::string References::GetAbstract() const {
    return m_abstract;
}

const std::string References::GetTitle() const {
    return m_title;
}

const std::string References::GetUrl() const {
    return m_url;
}

const std::vector<std::string> References::GetKeywords() const {
    return m_keywords;
}

// Indicates non-default values have been set. If false, serialization can be safely skipped.
bool References::ShouldSerialize() const {
    return true;
}

std::string References::Serialize() const {
    return ParseUtil::JsonToString(SerializeToJsonValue());
}

Json::Value References::SerializeToJsonValue() const {
    Json::Value root;

    root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Abstract)] = m_abstract;
    root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Title)] = m_title;
    root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Type)] = ReferenceTypeToString(m_type);
    root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Url)] = m_url;

    if (!m_keywords.empty()) {
        root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Keywords)] = Json::Value(Json::arrayValue);
        for (const auto& keyword : m_keywords) {
            root[AdaptiveCardSchemaKeyToString(AdaptiveCardSchemaKey::Keywords)].append(keyword);
        }
    }

    return root;
}

std::shared_ptr<References> References::DeserializeFromString(ParseContext& context, const std::string& jsonString) {
    return References::Deserialize(context, ParseUtil::GetJsonValueFromString(jsonString));
}

std::shared_ptr<References> References::Deserialize(ParseContext& context, const Json::Value& json) {
    std::shared_ptr<References> references = std::make_shared<References>();

    references->m_type = ParseUtil::GetEnumValue(json, AdaptiveCardSchemaKey::Type, ReferenceType::Document,ReferenceTypeFromString, false);
    references->m_title = ParseUtil::GetString(json, AdaptiveCardSchemaKey::Title, true);
    references->m_url = ParseUtil::GetString(json, AdaptiveCardSchemaKey::Url, true);
    references->m_abstract = ParseUtil::GetString(json, AdaptiveCardSchemaKey::Abstract, true);
    references->m_keywords = ParseUtil::GetStringArray(json, AdaptiveCardSchemaKey::Keywords, true);

    return references;
}
