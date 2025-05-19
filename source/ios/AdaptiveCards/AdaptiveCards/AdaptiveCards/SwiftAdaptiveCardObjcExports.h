#import <Foundation/Foundation.h>

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

NS_ASSUME_NONNULL_END
