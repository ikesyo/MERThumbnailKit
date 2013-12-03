//
//  UIImageView+METKExtensions.m
//  METhumbnailKit
//
//  Created by William Towe on 10/17/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import "UIImageView+METKExtensions.h"
#import "METhumbnailManager.h"
#import <MEFoundation/MEFunctions.h>

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

static void const *kMETKImageViewThumbnailOperationKey = &kMETKImageViewThumbnailOperationKey;

- (void)METK_setImageForThumbnailFromURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time placeholder:(UIImage *)placeholder; {
    NSOperation<METhumbnailOperation> *oldOperation = objc_getAssociatedObject(self, kMETKImageViewThumbnailOperationKey);
    if (oldOperation) {
        [oldOperation cancel];
        
        objc_setAssociatedObject(self, kMETKImageViewThumbnailOperationKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [self setImage:placeholder];
    
    __weak typeof(self) weakSelf = self;
    
    NSOperation<METhumbnailOperation> *newOperation = [[METhumbnailManager sharedManager] addThumbnailOperationForURL:url size:size page:page time:time completion:^(NSURL *url, UIImage *image, METhumbnailManagerCacheType cacheType) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (image) {
            if (cacheType == METhumbnailManagerCacheTypeNone &&
                strongSelf.window != nil) {
                
                [strongSelf setImage:image];
            }
            else {
                [strongSelf setImage:image];
            }
        }
    }];
    
    objc_setAssociatedObject(self, kMETKImageViewThumbnailOperationKey, newOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
