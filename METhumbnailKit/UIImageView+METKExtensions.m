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

- (void)METK_setImageForThumbnailFromURL:(NSURL *)url; {
    [self METK_setImageForThumbnailFromURL:url size:self.bounds.size page:[METhumbnailManager sharedManager].thumbnailPage time:[METhumbnailManager sharedManager].thumbnailTime placeholder:nil];
}
- (void)METK_setImageForThumbnailFromURL:(NSURL *)url placeholder:(UIImage *)placeholder; {
    [self METK_setImageForThumbnailFromURL:url size:self.bounds.size page:[METhumbnailManager sharedManager].thumbnailPage time:METhumbnailManagerDefaultThumbnailTime placeholder:placeholder];
}
- (void)METK_setImageForThumbnailFromURL:(NSURL *)url page:(NSInteger)page placeholder:(UIImage *)placeholder; {
    [self METK_setImageForThumbnailFromURL:url size:self.bounds.size page:page time:[METhumbnailManager sharedManager].thumbnailTime placeholder:placeholder];
}
- (void)METK_setImageForThumbnailFromURL:(NSURL *)url time:(NSTimeInterval)time placeholder:(UIImage *)placeholder; {
    [self METK_setImageForThumbnailFromURL:url size:self.bounds.size page:[METhumbnailManager sharedManager].thumbnailPage time:time placeholder:placeholder];
}

- (void)METK_setImageForThumbnailFromURL:(NSURL *)url size:(CGSize)size placeholder:(UIImage *)placeholder; {
    [self METK_setImageForThumbnailFromURL:url size:size page:[METhumbnailManager sharedManager].thumbnailPage time:[METhumbnailManager sharedManager].thumbnailTime placeholder:placeholder];
}
- (void)METK_setImageForThumbnailFromURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page placeholder:(UIImage *)placeholder; {
    [self METK_setImageForThumbnailFromURL:url size:size page:page time:[METhumbnailManager sharedManager].thumbnailTime placeholder:placeholder];
}
- (void)METK_setImageForThumbnailFromURL:(NSURL *)url size:(CGSize)size time:(NSTimeInterval)time placeholder:(UIImage *)placeholder; {
    [self METK_setImageForThumbnailFromURL:url size:size page:[METhumbnailManager sharedManager].thumbnailPage time:time placeholder:placeholder];
}

static void const *kMECKImageViewThumbnailOperationKey = &kMECKImageViewThumbnailOperationKey;

- (void)METK_setImageForThumbnailFromURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time placeholder:(UIImage *)placeholder; {
    __block NSOperation<METhumbnailOperation> *operation = objc_getAssociatedObject(self, kMECKImageViewThumbnailOperationKey);
    
    [operation cancel];
    
    [self setImage:placeholder];
    
    __weak typeof(self) weakSelf = self;
    
    operation = [[METhumbnailManager sharedManager] addThumbnailOperationForURL:url size:size page:page time:time completion:^(NSURL *url, UIImage *image, METhumbnailManagerCacheType cacheType) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf setImage:(image) ?: placeholder];
        
        operation = nil;
        
        objc_setAssociatedObject(strongSelf, kMECKImageViewThumbnailOperationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }];
    
    objc_setAssociatedObject(self, kMECKImageViewThumbnailOperationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
