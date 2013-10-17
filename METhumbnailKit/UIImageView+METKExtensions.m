//
//  UIImageView+METKExtensions.m
//  METhumbnailKit
//
//  Created by William Towe on 10/17/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import "UIImageView+METKExtensions.h"
#import "METhumbnailManager.h"

#import <objc/runtime.h>

@implementation UIImageView (METKExtensions)

static void const *kMECKImageViewThumbnailOperationKey = &kMECKImageViewThumbnailOperationKey;

- (void)METK_setImageForThumbnailFromURL:(NSURL *)url size:(CGSize)size placeholderImage:(UIImage *)placeholderImage; {
    [self METK_setImageForThumbnailFromURL:url size:size time:0.0 placeholderImage:placeholderImage];
}
- (void)METK_setImageForThumbnailFromURL:(NSURL *)url size:(CGSize)size time:(NSTimeInterval)time placeholderImage:(UIImage *)placeholderImage; {
    NSOperation<METhumbnailOperation> *operation = objc_getAssociatedObject(self, kMECKImageViewThumbnailOperationKey);
    
    [operation cancel];
    
    [self setImage:placeholderImage];
    
    __weak typeof(self) weakSelf = self;
    
    operation = [[METhumbnailManager sharedManager] addThumbnailOperationForURL:url size:size page:0 time:time completion:^(NSURL *url, UIImage *image, METhumbnailManagerCacheType cacheType) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf setImage:image];
    }];
    
    objc_setAssociatedObject(self, kMECKImageViewThumbnailOperationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
