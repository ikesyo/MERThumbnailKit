//
//  UIImage+MERThumnailKitExtensions.m
//  MERThumbnailKit
//
//  Created by William Towe on 4/23/14.
//  Copyright (c) 2014 Maestro, LLC. All rights reserved.
//

#import "UIImage+MERThumnailKitExtensions.h"
#import <MEFoundation/MEDebugging.h>

#import <Accelerate/Accelerate.h>
#import <AVFoundation/AVFoundation.h>

@implementation UIImage (MERThumnailKitExtensions)

- (BOOL)MER_hasAlpha; {
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(self.CGImage);
    
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

+ (UIImage *)MER_thumbnailOfImage:(UIImage *)image size:(CGSize)size; {
    if (!image || CGSizeEqualToSize(size, CGSizeZero))
        return image;
    
    CGSize destSize = AVMakeRectWithAspectRatioInsideRect(CGSizeMake(image.size.width, image.size.height), CGRectMake(0, 0, size.width, size.height)).size;
    CGImageRef sourceImageRef = image.CGImage;
    CFDataRef sourceDataRef = CGDataProviderCopyData(CGImageGetDataProvider(sourceImageRef));
    vImage_Buffer source = {
        .data = (void *)CFDataGetBytePtr(sourceDataRef),
        .height = CGImageGetHeight(sourceImageRef),
        .width = CGImageGetWidth(sourceImageRef),
        .rowBytes = CGImageGetBytesPerRow(sourceImageRef)
    };
    vImage_Buffer destination;
    vImage_Error error = vImageBuffer_Init(&destination, (vImagePixelCount)destSize.height, (vImagePixelCount)destSize.width, (uint32_t)CGImageGetBitsPerPixel(sourceImageRef), kvImageNoFlags);
    
    if (error != kvImageNoError) {
        MELogObject(@(error));
        CFRelease(sourceDataRef);
        return nil;
    }
    
    error = vImageScale_ARGB8888(&source, &destination, NULL, kvImageHighQualityResampling|kvImageEdgeExtend);
    
    if (error != kvImageNoError) {
        MELogObject(@(error));
        CFRelease(sourceDataRef);
        return nil;
    }
    
    CFRelease(sourceDataRef);
    
    vImage_CGImageFormat format = {
        .bitsPerComponent = (uint32_t)CGImageGetBitsPerComponent(sourceImageRef),
        .bitsPerPixel = (uint32_t)CGImageGetBitsPerPixel(sourceImageRef),
        .colorSpace = NULL,
        .bitmapInfo = CGImageGetBitmapInfo(sourceImageRef),
        .version = 0,
        .decode = NULL,
        .renderingIntent = kCGRenderingIntentDefault
    };
    CGImageRef destImageRef = vImageCreateCGImageFromBuffer(&destination, &format, NULL, NULL, kvImageNoFlags, &error);
    
    free(destination.data);
    
    if (error != kvImageNoError) {
        MELogObject(@(error));
        CGImageRelease(destImageRef);
        return nil;
    }
    
    UIImage *retval = [UIImage imageWithCGImage:destImageRef];
    
    CGImageRelease(destImageRef);
    
    return retval;
}

- (UIImage *)MER_thumbnailOfSize:(CGSize)size; {
    return [self.class MER_thumbnailOfImage:self size:size];
}

@end
