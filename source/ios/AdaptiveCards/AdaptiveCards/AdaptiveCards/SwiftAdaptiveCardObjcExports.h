#import <Foundation/Foundation.h>

#ifdef SWIFT_PACKAGE

NS_ASSUME_NONNULL_BEGIN

@class SwiftAdaptiveCardParseResult;

@interface SwiftAdaptiveCardParser : NSObject

+ (BOOL)isSwiftParserEnabled;
+ (void)setSwiftParserEnabled:(BOOL)enabled;
+ (SwiftAdaptiveCardParseResult *)parseWithPayload:(NSString *)payload;

@end

@interface SwiftAdaptiveCardParseResult : NSObject

@property (nonatomic, strong, nullable) NSArray *warnings;

@end

NS_ASSUME_NONNULL_END

#endif // SWIFT_PACKAGE
