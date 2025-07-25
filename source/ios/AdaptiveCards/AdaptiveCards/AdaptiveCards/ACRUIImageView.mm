//
//  ACRUIImageView.m
//  AdaptiveCards
//
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "ACRUIImageView.h"
#import "ACRContentHoldingUIView.h"

@implementation ACRUIImageView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.tag = eACRUIImageTag;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.tag = eACRUIImageTag;
        self.desiredSize = frame.size;
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    [super setImage:image];
    
    // Call completion block when image is set (non-KVO approach)
    if (image && self.imageSetCompletionBlock) {
        NSLog(@"ACR_COMPLETION_BLOCK: Image set, calling completion block. Image size: %@", NSStringFromCGSize(image.size));
        
        // Store the completion block and clear it to prevent multiple calls
        ACRImageSetCompletionBlock completionBlock = self.imageSetCompletionBlock;
        self.imageSetCompletionBlock = nil;
        
        // Call the completion block immediately - this should replicate the KVO behavior
        completionBlock(self);
        
        NSLog(@"ACR_COMPLETION_BLOCK: Completion block called successfully");
    } else if (self.imageSetCompletionBlock) {
        NSLog(@"ACR_COMPLETION_BLOCK: Completion block exists but image is nil");
    }
}

@end
