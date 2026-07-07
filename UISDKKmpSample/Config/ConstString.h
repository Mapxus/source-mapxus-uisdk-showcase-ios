//
//  ConstString.h
//  UISDKKmpSample
//
//  Provides Mapxus credentials injected at compile time via
//  GCC_PREPROCESSOR_DEFINITIONS (see BuildConfig/*.xcconfig).
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConstString : NSObject

+ (NSString *)getMapxusKey;
+ (NSString *)getMapxusSecret;

@end

NS_ASSUME_NONNULL_END
