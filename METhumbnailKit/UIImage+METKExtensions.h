//
//  UIImage+METKExtensions.h
//  METhumbnailKit
//
//  Created by William Towe on 10/16/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (METKExtensions)

+ (UIImage *)METK_thumbnailOfImage:(UIImage *)image size:(CGSize)size;

- (UIImage *)METK_thumbnailOfSize:(CGSize)size;

@end
