//
//  UIImage+METKExtensions.m
//  METhumbnailKit
//
//  Created by William Towe on 10/16/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import "UIImage+METKExtensions.h"

#import <Accelerate/Accelerate.h>
#import <CoreImage/CoreImage.h>

@implementation UIImage (METKExtensions)

+ (UIImage *)METK_thumbnailOfImage:(UIImage *)image size:(CGSize)size; {
    NSParameterAssert(image);
    NSParameterAssert(!CGSizeEqualToSize(size, CGSizeZero));
    
//    CGFloat scale = (size.width > size.height) ? (size.width / image.size.width) : (size.height / image.size.height);
//    CIFilter *filter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
//    
//    [filter setDefaults];
//    [filter setValue:@(scale) forKey:@"inputScale"];
//    [filter setValue:[[CIImage alloc] initWithImage:image] forKey:kCIInputImageKey];
//    
//    static CIContext *kContext;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        kContext = [CIContext contextWithOptions:nil];
//    });
//    
//    CGImageRef imageRef = [kContext createCGImage:filter.outputImage fromRect:filter.outputImage.extent];
//    UIImage *retval = [UIImage imageWithCGImage:imageRef];
//    
//    CGImageRelease(imageRef);
//    
//    return retval;
    
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
        NSLog(@"%@",@(error));
        return nil;
    }
    
    error = vImageScale_ARGB8888(&source, &destination, NULL, kvImageHighQualityResampling|kvImageEdgeExtend);
    
    if (error != kvImageNoError) {
        NSLog(@"%@",@(error));
        return nil;
    }
    
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
    
    if (error != kvImageNoError) {
        NSLog(@"%@",@(error));
        return nil;
    }
    
    UIImage *retval = [UIImage imageWithCGImage:destImageRef];
    
    return retval;
}

- (UIImage *)METK_thumbnailOfSize:(CGSize)size; {
    return [self.class METK_thumbnailOfImage:self size:size];
}

@end
