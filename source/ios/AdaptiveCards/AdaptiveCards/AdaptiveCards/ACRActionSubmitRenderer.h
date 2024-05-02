//
//  ACRActionSubmitRenderer
//  ACRActionSubmitRenderer.h
//
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "ACRBaseActionElementRenderer.h"

@interface ACRActionSubmitRenderer : ACRBaseActionElementRenderer <ACRInputChangeDelegate>

+ (ACRActionSubmitRenderer *)getInstance;

@end
