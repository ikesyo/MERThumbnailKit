//
//  NSFileManager+MEExtensions.m
//  MEFrameworks
//
//  Created by William Towe on 4/19/13.
//  Copyright (c) 2013 Maestro. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "NSFileManager+MEExtensions.h"
#import "MEFunctions.h"
#import "MEMacros.h"
#import "MEDebugging.h"

#if defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
#import "NSBundle+MEExtensions.h"
#endif

@implementation NSFileManager (MEExtensions)

- (NSURL *)ME_applicationSupportDirectoryURL {
    NSURL *retval = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].lastObject;
    
#if defined (__MAC_OS_X_VERSION_MIN_REQUIRED)
    retval = [retval URLByAppendingPathComponent:[[NSBundle mainBundle] ME_executable] isDirectory:YES];
#endif
    
    if (![retval checkResourceIsReachableAndReturnError:NULL]) {
        NSError *outError;
        if (![[NSFileManager defaultManager] createDirectoryAtURL:retval withIntermediateDirectories:YES attributes:nil error:&outError])
            MELogObject(outError);
    }
    
    return retval;
}

- (void)ME_createFileAtPath:(NSString *)path contents:(NSData *)contents attributes:(NSDictionary *)attributes completion:(void (^)(BOOL success))completion; {
    MEBlockWeakSelf weakSelf = self;
    
    MEDispatchBackgroundAsync(^{
        if ([weakSelf createFileAtPath:path contents:contents attributes:attributes]) {
            if (completion) {
                MEDispatchMainAsync(^{
                    completion(YES);
                });
            }
        }
        else {
            if (completion) {
                MEDispatchMainAsync(^{
                    completion(NO);
                });
            }
        }
    });
}

- (void)ME_copyItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL completion:(void (^)(BOOL success,NSError *error))completion; {
    MEBlockWeakSelf weakSelf = self;
    
    MEDispatchBackgroundAsync(^{
        NSError *outError;
        
        if ([weakSelf copyItemAtURL:srcURL toURL:dstURL error:&outError]) {
            if (completion) {
                MEDispatchMainAsync(^{
                    completion(YES,nil);
                });
            }
        }
        else {
            if (completion) {
                MEDispatchMainAsync(^{
                    completion(NO,outError);
                });
            }
        }
    });
}
- (void)ME_moveItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL completion:(void (^)(BOOL success,NSError *error))completion; {
    MEBlockWeakSelf weakSelf = self;
    
    MEDispatchBackgroundAsync(^{
        NSError *outError;
        
        if ([weakSelf moveItemAtURL:srcURL toURL:dstURL error:&outError]) {
            if (completion) {
                MEDispatchMainAsync(^{
                    completion(YES,nil);
                });
            }
        }
        else {
            if (completion) {
                MEDispatchMainAsync(^{
                    completion(NO,outError);
                });
            }
        }
    });
}

@end
