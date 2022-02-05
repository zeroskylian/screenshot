//
//  SnipUtil.h
//  screenshot
//
//  Created by Xinbo Lian on 2022/2/5.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SnipUtil : NSObject

+ (CGImageRef _Nullable)screenShot:(NSScreen *)screen;

@end

NS_ASSUME_NONNULL_END
