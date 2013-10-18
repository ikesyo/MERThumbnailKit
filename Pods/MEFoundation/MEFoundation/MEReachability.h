//
//  MEReachability.h
//  MEFrameworks
//
//  Created by William Towe on 6/14/13.
//  Copyright (c) 2013 Maestro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MEReachability : NSObject

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
@property (readonly,copy,nonatomic) NSString *hostName;

@property (readonly,nonatomic,getter = isReachable) BOOL reachable;
@property (readonly,nonatomic,getter = isReachableViaWiFi) BOOL reachableViaWifi;
@property (readonly,nonatomic,getter = isReachableViaWAN) BOOL reachableViaWAN;

- (instancetype)initWithHostName:(NSString *)hostName;

- (void)startNotifyingWithBlock:(void (^)(MEReachability *reachability))block;
- (void)stopNotifying;
#endif

@end
