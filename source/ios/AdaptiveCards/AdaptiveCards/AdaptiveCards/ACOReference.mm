//
//  ACOReference.mm
//  AdaptiveCards
//
//  Created by Gaurav Keshre on 30/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACOReference.h"
#import "ACOReferencePrivate.h"
#import "ACOAdaptiveCard.h"
#import "ACOAdaptiveCardPrivate.h"
#import "SharedAdaptiveCard.h"

using namespace AdaptiveCards;

@implementation ACOReference {
    std::shared_ptr<References> _reference;
}

- (instancetype)initWithReference:(const std::shared_ptr<References> &)reference {
    self = [super init];
    if (self && reference) {
        _reference = reference;
    }
    return self;
}

- (ACOReferenceType)type {
    if (!_reference) {
        return ACOReferenceTypeDocument;
    }
    
    ReferenceType cppType = _reference->GetType();
    switch (cppType) {
        case ReferenceType::AdaptiveCard:
            return ACOReferenceTypeAdaptiveCard;
        case ReferenceType::Document:
        default:
            return ACOReferenceTypeDocument;
    }
}

- (NSString *)abstract {
    if (!_reference) {
        return @"";
    }
    return [NSString stringWithUTF8String:_reference->GetAbstract().c_str()];
}

- (NSString *)title {
    if (!_reference) {
        return @"";
    }
    return [NSString stringWithUTF8String:_reference->GetTitle().c_str()];
}

- (NSString *)url {
    if (!_reference) {
        return @"";
    }
    return [NSString stringWithUTF8String:_reference->GetUrl().c_str()];
}

- (NSArray<NSString *> *)keywords {
    if (!_reference) {
        return @[];
    }
    
    NSMutableArray<NSString *> *keywordArray = [NSMutableArray array];
    std::vector<std::string> cppKeywords = _reference->GetKeywords();
    
    for (const auto& keyword : cppKeywords) {
        [keywordArray addObject:[NSString stringWithUTF8String:keyword.c_str()]];
    }
    
    return [keywordArray copy];
}

- (ACOAdaptiveCard *)content {
    if (!_reference) {
        return nil;
    }
    
    auto contentOpt = _reference->GetContent();
    if (!contentOpt || !contentOpt.value()) {
        return nil;
    }
    
    ACOAdaptiveCard *acoCard = [[ACOAdaptiveCard alloc] init];
    [acoCard setCard:contentOpt.value()];
    return acoCard;
}

- (std::shared_ptr<References>)reference {
    return _reference;
}

@end