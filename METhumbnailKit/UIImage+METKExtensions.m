//
//  UIImage+METKExtensions.m
//  METhumbnailKit
//
//  Created by William Towe on 10/16/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import "UIImage+METKExtensions.h"
#import <MEFoundation/MEDebugging.h>

#import <Accelerate/Accelerate.h>

@implementation UIImage (METKExtensions)

+ (UIImage *)METK_thumbnailOfImage:(UIImage *)image size:(CGSize)size; {
    if (!image || CGSizeEqualToSize(size, CGSizeZero))
        return image;
    
    CGImageRef sourceImageRef = image.CGImage;
    CFDataRef sourceDataRef = CGDataProviderCopyData(CGImageGetDataProvider(sourceImageRef));
    vImage_Buffer source = {
        .data=(void *)CFDataGetBytePtr(sourceDataRef),
        .height=CGImageGetHeight(sourceImageRef),
        .width=CGImageGetWidth(sourceImageRef),
        .rowBytes=CGImageGetBytesPerRow(sourceImageRef)
    };
    vImage_Buffer destination;
    vImage_Error error = vImageBuffer_Init(&destination, (vImagePixelCount)size.height, (vImagePixelCount)size.width, CGImageGetBitsPerPixel(sourceImageRef), kvImageNoFlags);
    
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
        .bitsPerComponent = CGImageGetBitsPerComponent(sourceImageRef),
        .bitsPerPixel = CGImageGetBitsPerPixel(sourceImageRef),
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

- (UIImage *)METK_thumbnailOfSize:(CGSize)size; {
    return [self.class METK_thumbnailOfImage:self size:size];
}

@end
