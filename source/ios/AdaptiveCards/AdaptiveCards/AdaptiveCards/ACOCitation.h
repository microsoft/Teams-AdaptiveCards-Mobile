//
//  ACOCitation.h
//  AdaptiveCards
//
//  Created by Harika P on 30/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACOReference.h"

@interface ACOCitation : NSObject

@property (nonatomic, copy) NSString *displayText;
@property (nonatomic, copy) NSNumber *referenceIndex;
@property ACRTheme theme;

- (instancetype)initWithDisplayText:(NSString *)displayText
                     referenceIndex:(NSNumber *)referenceIndex
                              theme:(ACRTheme)theme;

@end
