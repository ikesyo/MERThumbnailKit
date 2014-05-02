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
    objc_setAssociatedObject(self, kMER_subscriberKey, MER_subscriber, OBJC_ASSOCIATION_ASSIGN);
}

@end
