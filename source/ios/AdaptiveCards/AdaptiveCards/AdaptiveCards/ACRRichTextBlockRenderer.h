//
//  ACRRichTextBlockRenderer
//  ACRRichTextBlockRenderer.h
//
//  Copyright © 2019 Microsoft. All rights reserved.
//

#import "ACRBaseCardElementRenderer.h"
#import "ACRCitationManagerDelegate.h"

@interface ACRRichTextBlockRenderer : ACRBaseCardElementRenderer <ACRCitationManagerDelegate>

+ (ACRRichTextBlockRenderer *)getInstance;

+ (NSAttributedString *)processCitationsWithManager:(NSAttributedString *)content rootView:(ACRView *)rootView;

@end
