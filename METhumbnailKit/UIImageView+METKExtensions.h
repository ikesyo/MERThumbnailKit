//
//  UIImageView+METKExtensions.h
//  METhumbnailKit
//
//  Created by William Towe on 10/17/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (METKExtensions)

- (void)METK_setImageForThumbnailFromURL:(NSURL *)url size:(CGSize)size placeholderImage:(UIImage *)placeholderImage;
- (void)METK_setImageForThumbnailFromURL:(NSURL *)url size:(CGSize)size time:(NSTimeInterval)time placeholderImage:(UIImage *)placeholderImage;

@end
