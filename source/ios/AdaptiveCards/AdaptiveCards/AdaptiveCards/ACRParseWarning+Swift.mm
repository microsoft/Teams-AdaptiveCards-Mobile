//
//  ACRParseWarning+Swift.mm
//  AdaptiveCards
//
//  Created on 5/15/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACRParseWarning+Swift.h"
#import "ACRParseWarningPrivate.h"

@implementation ACRParseWarning (Swift)

+ (instancetype)createWithStatusCode:(unsigned int)statusCode reason:(NSString *)reason {
    ACRParseWarning *warning = [[ACRParseWarning alloc] init];
    // Access private methods through the ACRParseWarningPrivate header
//    [warning setStatusCode:statusCode]; // FIXME
//    [warning setReason:reason];
//    warning.statusCode = statusCode;
//    warning.reason = reason;
    return warning;
}

@end
