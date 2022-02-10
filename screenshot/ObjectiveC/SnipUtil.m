//
//  SnipUtil.m
//  screenshot
//
//  Created by Xinbo Lian on 2022/2/5.
//

#import "SnipUtil.h"

@implementation SnipUtil
+ (CGImageRef)screenShot:(NSScreen *)screen {
    CFArrayRef windowsRef = CGWindowListCreate(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
    if (windowsRef == nil) {
        return nil;
    }
    NSRect rect = [screen frame];
    NSRect mainRect = [NSScreen mainScreen].frame;
    for (NSScreen *subScreen in [NSScreen screens]) {
        if ((int) subScreen.frame.origin.x == 0 && (int) subScreen.frame.origin.y == 0) {
            mainRect = subScreen.frame;
        }
    }
    rect = NSMakeRect(rect.origin.x, (mainRect.size.height) - (rect.origin.y + rect.size.height), rect.size.width, rect.size.height);
    CGImageRef imgRef = CGWindowListCreateImageFromArray(rect, windowsRef, kCGWindowImageDefault);
    CFRelease(windowsRef);
    return imgRef;
}
@end
