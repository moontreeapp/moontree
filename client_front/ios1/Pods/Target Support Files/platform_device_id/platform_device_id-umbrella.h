#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "PlatformDeviceIdPlugin.h"

FOUNDATION_EXPORT double platform_device_idVersionNumber;
FOUNDATION_EXPORT const unsigned char platform_device_idVersionString[];

