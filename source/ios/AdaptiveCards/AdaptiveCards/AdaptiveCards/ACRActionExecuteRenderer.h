//
//  ACRActionExecuteRenderer
//  ACRActionExecuteRenderer.h
//
//  Copyright © 2021 Microsoft. All rights reserved.
//

#import "ACRBaseActionElementRenderer.h"

@interface ACRActionExecuteRenderer : ACRBaseActionElementRenderer <ACRInputChangeDelegate>

+ (ACRActionExecuteRenderer *)getInstance;

@end
