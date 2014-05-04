//
//  NSImage+MERThumbnailKitExtensions.h
//  MERThumbnailKit
//
//  Created by William Towe on 5/1/14.
//  Copyright (c) 2014 Maestro, LLC. All rights reserved.
//

#import <AppKit/NSImage.h>

@interface NSImage (MERThumbnailKitExtensions)

@property (readonly,nonatomic) BOOL MER_hasAlpha;

+ (NSImage *)MER_thumbnailOfImage:(NSImage *)image size:(CGSize)size;

- (NSImage *)MER_thumbnailOfSize:(CGSize)size;

@end
