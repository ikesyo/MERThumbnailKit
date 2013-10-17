//
//  UIImage+METKExtensions.h
//  METhumbnailKit
//
//  Created by William Towe on 10/16/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (METKExtensions)

+ (UIImage *)METK_coreImageThumbnailOfImage:(UIImage *)image size:(CGSize)size;
+ (UIImage *)METK_accelerateThumbnailOfImage:(UIImage *)image size:(CGSize)size;

- (UIImage *)METK_coreImageThumbnailOfSize:(CGSize)size;
- (UIImage *)METK_accelerateThumbnailOfSize:(CGSize)size;

@end
