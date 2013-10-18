//
//  MEReachability.m
//  MEFrameworks
//
//  Created by William Towe on 6/14/13.
//  Copyright (c) 2013 Maestro. All rights reserved.
//

#import "MEReachability.h"

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#import <SystemConfiguration/SystemConfiguration.h>
#endif

@interface MEReachability ()
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
@property (readwrite,copy,nonatomic) NSString *hostName;
@property (assign,nonatomic) SCNetworkReachabilityRef reachabilityRef;
@property (copy,nonatomic) void (^notifyBlock)(MEReachability *reachability);

- (void)_handleReachabilityRefCallback:(SCNetworkReachabilityFlags)flags;
#endif
@end

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
static void MEReachabilityRefCallback(SCNetworkReachabilityRef reachabilityRef, SCNetworkReachabilityFlags flags, void *info) {
    [(__bridge MEReachability *)info _handleReachabilityRefCallback:flags];
}
#endif

@implementation MEReachability

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
- (instancetype)initWithHostName:(NSString *)hostName; {
    if (!(self = [super init]))
        return nil;
    
    [self setReachabilityRef:SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [hostName UTF8String])];
    
    SCNetworkReachabilityContext context = {0, (__bridge void *)self, NULL, NULL, NULL};
    SCNetworkReachabilitySetCallback(self.reachabilityRef, &MEReachabilityRefCallback, &context);
    
    return self;
}

- (void)startNotifyingWithBlock:(void (^)(MEReachability *reachability))block; {
    NSParameterAssert(block);
    
    [self setNotifyBlock:block];
    
    SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, dispatch_get_main_queue());
}
- (void)stopNotifying; {
    [self setNotifyBlock:nil];
    
    SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, NULL);
}

- (BOOL)isReachable {
    SCNetworkReachabilityFlags flags = 0;
    SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags);
    
    return ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
}
- (BOOL)isReachableViaWiFi {
    SCNetworkReachabilityFlags flags = 0;
    SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags);
    
    return ((flags & kSCNetworkReachabilityFlagsReachable) != 0) && ((flags & kSCNetworkReachabilityFlagsIsWWAN) == 0);
}
- (BOOL)isReachableViaWAN {
    SCNetworkReachabilityFlags flags = 0;
    SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags);
    
    return ((flags & kSCNetworkReachabilityFlagsReachable) != 0) && ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0);
}

- (void)setReachabilityRef:(SCNetworkReachabilityRef)reachabilityRef {
    if (_reachabilityRef)
        CFRelease(reachabilityRef);
    
    _reachabilityRef = reachabilityRef;
}

- (void)_handleReachabilityRefCallback:(SCNetworkReachabilityFlags)flags; {
    if (self.notifyBlock)
        self.notifyBlock(self);
}
#endif

@end
