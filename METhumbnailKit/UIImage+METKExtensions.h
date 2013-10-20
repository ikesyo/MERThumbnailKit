//
//  UIImage+METKExtensions.h
//  METhumbnailKit
//
//  Created by William Towe on 10/16/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (METKExtensions)

/**
 Creates and returns a thumbnail of _image_ with _size_.
 
 @param image The image from which to create the thumbnail
 @param size The size of the thumbnail
 */
+ (UIImage *)METK_thumbnailOfImage:(UIImage *)image size:(CGSize)size;
/**
 Calls `METK_thumbnailOfImage:size:` passing `self` and _size_ respectively.
 */
- (UIImage *)METK_thumbnailOfSize:(CGSize)size;

@end
