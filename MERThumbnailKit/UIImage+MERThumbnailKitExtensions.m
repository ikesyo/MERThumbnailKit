//
//  UIImage+MERThumbnailKitExtensions.m
//  MERThumbnailKit
//
//  Created by William Towe on 5/1/14.
//  Copyright (c) 2014 Maestro, LLC. All rights reserved.
//

#import "UIImage+MERThumbnailKitExtensions.h"
#import "MERThumbnailKitFunctions.h"

#if !__has_feature(objc_arc)
#error MERThumbnailKit requires ARC
#endif

@implementation UIImage (MERThumbnailKitExtensions)

+ (UIImage *)MER_thumbnailOfImage:(UIImage *)image size:(CGSize)size; {
    NSParameterAssert(image);
    
    CGImageRef imageRef = MERThumbnailKitCreateCGImageThumbnailWithSize(image.CGImage, size);
    UIImage *retval = [[UIImage alloc] initWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    
    return retval;
}

- (UIImage *)MER_thumbnailOfSize:(CGSize)size; {
    return [self.class MER_thumbnailOfImage:self size:size];
}

@end
