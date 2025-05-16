//
//  AdaptiveCardsSwift-Bridging-Header.h
//  AdaptiveCardsSwift
//
//  Created on 5/15/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#ifndef AdaptiveCardsSwift_Bridging_Header_h
#define AdaptiveCardsSwift_Bridging_Header_h

// Include the main bridging header from AdaptiveCards
#if __has_include(<AdaptiveCards/AdaptiveCards-Bridging-Header.h>)
#import <AdaptiveCards/AdaptiveCards-Bridging-Header.h>
#elif __has_include("AdaptiveCards-Bridging-Header.h")
#import "AdaptiveCards-Bridging-Header.h"
#endif

// SVGKit imports
#if __has_include(<SVGKit/SVGKit.h>)
#import <SVGKit/SVGKit.h>
#elif __has_include("SVGKit.h")
#import "SVGKit.h"
#endif

// Add any additional Objective-C headers here that need to be exposed to Swift

#endif /* AdaptiveCardsSwift_Bridging_Header_h */
