//
//  UIImage+METKExtensions.m
//  METhumbnailKit
//
//  Created by William Towe on 10/16/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import "UIImage+METKExtensions.h"

#import <Accelerate/Accelerate.h>

@implementation UIImage (METKExtensions)

+ (UIImage *)METK_thumbnailOfImage:(UIImage *)image size:(CGSize)size; {
    NSParameterAssert(image);
    NSParameterAssert(!CGSizeEqualToSize(size, CGSizeZero));
    
    CGImageRef sourceImageRef = image.CGImage;
    CFDataRef sourceDataRef = CGDataProviderCopyData(CGImageGetDataProvider(sourceImageRef));
    vImage_Buffer source = {.data=(void *)CFDataGetBytePtr(sourceDataRef), .height=CGImageGetHeight(sourceImageRef), .width=CGImageGetWidth(sourceImageRef), .rowBytes=CGImageGetBytesPerRow(sourceImageRef)};
    vImage_Buffer dest = {.data=malloc(size.height * CGImageGetBytesPerRow(sourceImageRef)), .width=size.width, .height=size.height, .rowBytes=CGImageGetBytesPerRow(sourceImageRef)};
    vImage_Error error = vImageScale_ARGB8888(&source, &dest, NULL, kvImageHighQualityResampling);
    
    if (error != kvImageNoError) {
        NSLog(@"%@",@(error));
        return nil;
    }
    
    CGContextRef contextRef = CGBitmapContextCreate(dest.data, dest.width, dest.height, 8, dest.rowBytes, CGImageGetColorSpace(sourceImageRef), CGImageGetBitmapInfo(sourceImageRef));
    CGImageRef destImageRef = CGBitmapContextCreateImage(contextRef);
    UIImage *retval = [UIImage imageWithCGImage:destImageRef];
    
    CFRelease(sourceDataRef);
    free(dest.data);
    CGContextRelease(contextRef);
    CGImageRelease(destImageRef);
    
    return retval;
}

- (UIImage *)METK_thumbnailOfSize:(CGSize)size; {
    return [self.class METK_thumbnailOfImage:self size:size];
}

@end
