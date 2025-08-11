//
//  ACOResourceResolvers.mm
//  ACOResourceResolvers.h
//
//  Copyright © 2018 Microsoft. All rights reserved.
//
#import "ACOResourceResolvers.h"
#import "ACOIResourceResolver.h"
#import "ACOAdaptiveCard.h"
#import "ACOAdaptiveCardParseResult.h"
#import "ACOHostConfig.h"
#import "ACRView.h"
#import "ACRRenderer.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Forward declare classes to avoid circular imports
// Note: TestCompositeImageView and MockSwiftKVOManager are now defined in ADCKVOTestResolver files
@class TestCompositeImageView;
@class MockSwiftKVOManager;

@implementation ACOResourceResolvers {
    NSMutableDictionary<NSString *, NSObject<ACOIResourceResolver> *> *_resolvers;
    NSMutableDictionary<NSString *, NSNumber *> *_resolversIFMap;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _resolvers = [[NSMutableDictionary alloc] init];
        _resolversIFMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setResourceResolver:(NSObject<ACOIResourceResolver> *)resolver scheme:(NSString *)scheme
{
    self->_resolvers[scheme] = resolver;

    _resolversIFMap[scheme] = [NSNumber numberWithInt:ACODefaultIF];

    // only one IF per scheme is supported and ACRImageViewIF will be chosen
    // when both are implemented
    if ([resolver respondsToSelector:@selector(resolveImageViewResource:)]) {
        _resolversIFMap[scheme] = [NSNumber numberWithInt:ACOImageViewIF];
    } else if ([resolver respondsToSelector:@selector(resolveImageResource:)]) {
        _resolversIFMap[scheme] = [NSNumber numberWithInt:ACOImageIF];
    }
}

- (NSObject<ACOIResourceResolver> *)getResourceResolverForScheme:(NSString *)scheme
{
    return self->_resolvers[scheme];
}

- (ACOResolverIFType)getResolverIFType:(NSString *)scheme
{
    return (ACOResolverIFType)[_resolversIFMap[scheme] intValue];
}

@end

/*
// MARK: - Generic View Resolution Architecture

// The new generic view resolution allows composite views (like TeamsUI ImageView) 
// to be used instead of just UIImageViews.

// Key Components:
// 1. ACOIResourceResolver protocol extended with resolveImageViewAsGenericView and resolveBackgroundImageViewAsGenericView
// 2. ACRView.mm and ACRRenderer.mm updated to check for generic methods first
// 3. Test implementation in ADCKVOTestResolver files (TestGenericViewImageResolver, TestCompositeImageView, MockSwiftKVOManager)

// Usage Example (in visualizer):
// TestGenericViewImageResolver *resolver = [TestGenericViewImageResolver sharedResolver];
// resolver.useGenericViewResolution = YES;
// resolver.enableExternalKVO = YES;

// For TeamsSpace Integration:
// 1. Replace TestCompositeImageView with TeamsUI ImageView in your resolver
// 2. Replace MockSwiftKVOManager with TeamsSpace KVO management
// 3. Implement resolver that provides TeamsUI ImageViews via resolveImageViewAsGenericView
// 4. The SDK will automatically use generic resolution when available, falling back to UIImageView
*/
