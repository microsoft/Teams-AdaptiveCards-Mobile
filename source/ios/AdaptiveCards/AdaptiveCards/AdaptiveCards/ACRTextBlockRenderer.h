//
//  ACRTextBlockRenderer
//  ACRTextBlockRenderer.h
//
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "ACRBaseCardElementRenderer.h"
#import "ACRCitationManagerDelegate.h"

@interface ACRTextBlockRenderer : ACRBaseCardElementRenderer <ACRCitationManagerDelegate>

+ (ACRTextBlockRenderer *)getInstance;

- (NSAttributedString *)processCitationsWithManager:(NSAttributedString *)content rootView:(ACRView *)rootView;

@end
