//
//  ACOCitation.mm
//  AdaptiveCards
//
//  Created by Harika P on 30/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACOCitation.h"

@implementation ACOCitation

- (instancetype)initWithDisplayText:(NSString *)displayText
                     referenceIndex:(NSNumber *)referenceIndex
{
    self = [super init];
    if (self)
    {
        self.displayText = displayText;
        self.referenceIndex = referenceIndex;
    }
    return self;
}

@end
