//
//  UIWebView+MERThumbnailKitExtensions.m
//  MERThumbnailKit
//
//  Created by William Towe on 5/2/14.
//  Copyright (c) 2014 Maestro, LLC. All rights reserved.
//

#import "UIWebView+MERThumbnailKitExtensions.h"
#import <ReactiveCocoa/RACSubscriber.h>

#import <objc/runtime.h>

@implementation UIWebView (MERThumbnailKitExtensions)

static void const *kMER_subscriberKey = &kMER_subscriberKey;

@dynamic MER_subscriber;
- (id<RACSubscriber>)MER_subscriber {
    return objc_getAssociatedObject(self, kMER_subscriberKey);
}
- (void)setMER_subscriber:(id<RACSubscriber>)MER_subscriber {
    objc_setAssociatedObject(self, kMER_subscriberKey, MER_subscriber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static void const *kMER_originalURLKey = &kMER_originalURLKey;

@dynamic MER_originalURL;
- (NSURL *)MER_originalURL {
    return objc_getAssociatedObject(self, kMER_originalURLKey);
}
- (void)setMER_originalURL:(NSURL *)MER_originalURL {
    objc_setAssociatedObject(self, kMER_originalURLKey, MER_originalURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static void const *kMER_concurrentRequestCountKey = &kMER_concurrentRequestCountKey;

@dynamic MER_concurrentRequestCount;
- (NSInteger)MER_concurrentRequestCount {
    return [objc_getAssociatedObject(self, kMER_concurrentRequestCountKey) integerValue];
}
- (void)setMER_concurrentRequestCount:(NSInteger)MER_concurrentRequestCount {
    objc_setAssociatedObject(self, kMER_concurrentRequestCountKey, @(MER_concurrentRequestCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
