//
//  ACOReference.h
//  AdaptiveCards
//
//  Created by Gaurav Keshre on 30/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Represents different types of references
 */
typedef NS_ENUM(NSUInteger, ACOReferenceType) {
    ACOReferenceTypeAdaptiveCard = 0,
    ACOReferenceTypeDocument = 1
};

@class ACOAdaptiveCard;

/**
 * Objective-C wrapper for AdaptiveCards::References
 * Contains reference information for citations
 */
@interface ACOReference : NSObject

/**
 * The type of reference (AdaptiveCard or Document)
 */
@property (nonatomic, readonly) ACOReferenceType type;

/**
 * Abstract or summary of the reference
 */
@property (nonatomic, readonly, copy) NSString *abstract;

/**
 * Title of the reference
 */
@property (nonatomic, readonly, copy) NSString *title;

/**
 * URL of the reference
 */
@property (nonatomic, readonly, copy) NSString *url;

/**
 * Keywords associated with the reference
 */
@property (nonatomic, readonly, copy) NSArray<NSString *> *keywords;

/**
 * Optional adaptive card content for the reference
 */
@property (nonatomic, readonly, nullable) ACOAdaptiveCard *content;

@end

NS_ASSUME_NONNULL_END