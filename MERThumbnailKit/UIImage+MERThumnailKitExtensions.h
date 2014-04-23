//
//  UIImage+MERThumnailKitExtensions.h
//  MERThumbnailKit
//
//  Created by William Towe on 4/23/14.
//  Copyright (c) 2014 Maestro, LLC. All rights reserved.
//

#import <UIKit/UIImage.h>

@interface UIImage (MERThumnailKitExtensions)

@property (readonly,nonatomic) BOOL MER_hasAlpha;

+ (UIImage *)MER_thumbnailOfImage:(UIImage *)image size:(CGSize)size;

- (UIImage *)MER_thumbnailOfSize:(CGSize)size;

@end
