//
//  NSURLRequest+MERThumbnailKitExtensions.m
//  MERThumbnailKit
//
//  Created by William Towe on 5/4/14.
//  Copyright (c) 2014 Maestro, LLC. All rights reserved.
//

#import "NSURLRequest+MERThumbnailKitExtensions.h"
#import <ReactiveCocoa/RACSubscriber.h>

static NSString *const kMER_subscriberKey = @"kMER_subscriberKey";
static NSString *const kMER_downloadProgressBlock = @"kMER_downloadProgressBlock";

@implementation NSURLRequest (MERThumbnailKitExtensions)

- (id<RACSubscriber>)MER_subscriber {
    return [NSURLProtocol propertyForKey:kMER_subscriberKey inRequest:self];
}
- (MERThumbnailManagerDownloadProgressBlock)MER_downloadProgressBlock {
    return [NSURLProtocol propertyForKey:kMER_downloadProgressBlock inRequest:self];
}

@end

@implementation NSMutableURLRequest (MERThumbnailKitExtensions)

- (void)setMER_subscriber:(id<RACSubscriber>)MER_subscriber {
    [NSURLProtocol setProperty:MER_subscriber forKey:kMER_subscriberKey inRequest:self];
}
- (void)setMER_downloadProgressBlock:(MERThumbnailManagerDownloadProgressBlock)MER_downloadProgressBlock {
    [NSURLProtocol setProperty:MER_downloadProgressBlock forKey:kMER_downloadProgressBlock inRequest:self];
}

@end
