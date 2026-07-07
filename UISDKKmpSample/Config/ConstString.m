//
//  ConstString.m
//  UISDKKmpSample
//
//  The MAPXUS_API_KEY / MAPXUS_SECRET macros are supplied by
//  GCC_PREPROCESSOR_DEFINITIONS and hold the raw credential tokens.
//  See BuildConfig/Secrets.example.xcconfig.
//

#import "ConstString.h"

// Turn the raw macro token into an Objective-C string literal.
#define MXM_STRINGIZE_HELPER(x) #x
#define MXM_STRINGIZE(x) MXM_STRINGIZE_HELPER(x)

#ifndef MAPXUS_API_KEY
#define MAPXUS_API_KEY
#endif

#ifndef MAPXUS_SECRET
#define MAPXUS_SECRET
#endif

@implementation ConstString

+ (NSString *)getMapxusKey {
    return @(MXM_STRINGIZE(MAPXUS_API_KEY));
}

+ (NSString *)getMapxusSecret {
    return @(MXM_STRINGIZE(MAPXUS_SECRET));
}

@end
