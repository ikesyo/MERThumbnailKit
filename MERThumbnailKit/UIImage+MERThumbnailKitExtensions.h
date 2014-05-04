//
//  UIImage+MERThumbnailKitExtensions.h
//  MERThumbnailKit
//
//  Created by William Towe on 5/1/14.
//  Copyright (c) 2014 Maestro, LLC. All rights reserved.
//

#import <UIKit/UIImage.h>

@interface UIImage (MERThumbnailKitExtensions)

@property (readonly,nonatomic) BOOL MER_hasAlpha;

+ (UIImage *)MER_thumbnailOfImage:(UIImage *)image size:(CGSize)size;

- (UIImage *)MER_thumbnailOfSize:(CGSize)size;

@end
