//
//  AdaptiveCards-Bridging-Header.h
//  AdaptiveCards
//
//  Created on 05/15/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

// This file serves as a bridging header between Objective-C/C++ code and Swift
// Any headers you want to expose to Swift should be imported here

#ifndef AdaptiveCards_Bridging_Header_h
#define AdaptiveCards_Bridging_Header_h

// Core Adaptive Cards headers
#import "AdaptiveCards/ACFramework.h"
#import "AdaptiveCards/ACRView.h"
#import "AdaptiveCards/ACOHostConfig.h"
#import "AdaptiveCards/ACOAdaptiveCard.h"
#import "AdaptiveCards/ACRRenderer.h"
#import "AdaptiveCards/ACRRendererPrivate.h"
#import "AdaptiveCards/ACOBaseCardElement.h"
#import "AdaptiveCards/ACOHostConfigPrivate.h"
#import "AdaptiveCards/ACRViewPrivate.h"
#import "AdaptiveCards/ACOAdaptiveCardPrivate.h"
#import "AdaptiveCards/ACOBaseActionElement.h"
#import "AdaptiveCards/SharedAdaptiveCard.h"
#import "AdaptiveCards/ParseContext.h"
#import "AdaptiveCards/TextBlock.h"
#import "AdaptiveCards/BaseCardElement.h"
#import "AdaptiveCards/ACRInputRenderer.h"
#import "AdaptiveCards/ACOBundle.h"
#import "AdaptiveCards/ACRParseWarning.h"

// Dependency headers (conditionally imported)
#if __has_include(<SVGKit/SVGKit.h>)
#import <SVGKit/SVGKit.h>
#endif

#endif /* AdaptiveCards_Bridging_Header_h */
