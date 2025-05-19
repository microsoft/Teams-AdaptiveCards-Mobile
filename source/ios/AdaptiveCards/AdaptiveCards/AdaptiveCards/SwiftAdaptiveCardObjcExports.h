#import <Foundation/Foundation.h>

#ifdef SWIFT_PACKAGE
@class SwiftAdaptiveCardParseResult;

NS_ASSUME_NONNULL_BEGIN

@interface SwiftAdaptiveCardParser : NSObject

+ (BOOL)isSwiftParserEnabled;
+ (void)setSwiftParserEnabled:(BOOL)enabled;
+ (SwiftAdaptiveCardParseResult *)parseWithPayload:(NSString *)payload;

@end

@interface SwiftAdaptiveCardParseResult : NSObject

@property (nonatomic, strong, nullable) NSArray *warnings;

@end
#endif

NS_ASSUME_NONNULL_END
