//
//  NSImage+MERThumbnailKitExtensions.m
//  MERThumbnailKit
//
//  Created by William Towe on 5/1/14.
//  Copyright (c) 2014 Maestro, LLC. All rights reserved.
//

#import "NSImage+MERThumbnailKitExtensions.h"
#import "MERThumbnailKitFunctions.h"

#if !__has_feature(objc_arc)
#error MERThumbnailKit requires ARC
#endif

@implementation NSImage (MERThumbnailKitExtensions)

- (BOOL)MER_hasAlpha {
    return MERThumbnailKitCGImageHasAlpha([self CGImageForProposedRect:NULL context:NULL hints:nil]);
}

+ (NSImage *)MER_thumbnailOfImage:(NSImage *)image size:(CGSize)size; {
    NSParameterAssert(image);
    
    CGImageRef sourceImageRef = [image CGImageForProposedRect:NULL context:NULL hints:nil];
    CGImageRef imageRef = MERThumbnailKitCreateCGImageThumbnailWithSize(sourceImageRef, size);
    NSImage *retval = [[NSImage alloc] initWithCGImage:imageRef size:NSZeroSize];
    
    CGImageRelease(imageRef);
    
    return retval;
}

- (NSImage *)MER_thumbnailOfSize:(CGSize)size; {
    return [self.class MER_thumbnailOfImage:self size:size];
}

@end
