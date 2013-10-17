//
//  UIImage+METKExtensions.m
//  METhumbnailKit
//
//  Created by William Towe on 10/16/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import "UIImage+METKExtensions.h"

#import <CoreImage/CoreImage.h>
#import <Accelerate/Accelerate.h>

@implementation UIImage (METKExtensions)

+ (UIImage *)METK_coreImageThumbnailOfImage:(UIImage *)image size:(CGSize)size; {
    NSParameterAssert(image);
    NSParameterAssert(!CGSizeEqualToSize(size, CGSizeZero));
    
    CGFloat scale = (size.width > size.height) ? (size.width / image.size.width) : (size.height / image.size.height);
    CIFilter *filter;
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending) {
        filter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
        
        [filter setDefaults];
        [filter setValue:@(scale) forKey:@"inputScale"];
    }
    else {
        filter = [CIFilter filterWithName:@"CIAffineTransform"];
        
        CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
        
        [filter setDefaults];
        [filter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    }
    
    [filter setValue:[[CIImage alloc] initWithImage:image] forKey:kCIInputImageKey];
    
    static CIContext *kContext;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kContext = [CIContext contextWithOptions:nil];
    });
    
    CGImageRef imageRef = [kContext createCGImage:filter.outputImage fromRect:filter.outputImage.extent];
    UIImage *retval = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    
    return retval;
}
+ (UIImage *)METK_accelerateThumbnailOfImage:(UIImage *)image size:(CGSize)size; {
    NSParameterAssert(image);
    NSParameterAssert(!CGSizeEqualToSize(size, CGSizeZero));
    
    CGImageRef imageRef = image.CGImage;
    vImage_Buffer src = {.width = image.size.width, .height = image.size.height, .rowBytes = CGImageGetBytesPerRow(imageRef), .data = malloc(image.size.height * CGImageGetBytesPerRow(imageRef))};
    CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
    CFDataRef data = CGDataProviderCopyData(dataProvider);
    
    memcpy(src.data, CFDataGetBytePtr(data), src.rowBytes * src.height);
    
    CFRelease(data);
    
    vImage_Buffer dest = {.width = size.width, .height = size.height, .rowBytes = CGImageGetBytesPerRow(imageRef), .data = malloc(CGImageGetBytesPerRow(imageRef) * size.height)};
    
    vImage_Error error = vImageScale_ARGB8888(&src, &dest, NULL, kvImageHighQualityResampling|kvImageEdgeExtend);
    UIImage *retval = nil;
    
    if (error != kvImageNoError) {
        NSLog(@"%@",@(error));
        return retval;
    }
    
    CGContextRef contextRef = CGBitmapContextCreate(dest.data, dest.width, dest.height, 8, dest.rowBytes, CGImageGetColorSpace(imageRef), CGImageGetBitmapInfo(imageRef));
    
    imageRef = CGBitmapContextCreateImage(contextRef);
    retval = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    
    CGImageRelease(imageRef);
    CGContextRelease(contextRef);
    free(src.data);
    
    return retval;
}

- (UIImage *)METK_coreImageThumbnailOfSize:(CGSize)size; {
    return [self.class METK_coreImageThumbnailOfImage:self size:size];
}
- (UIImage *)METK_accelerateThumbnailOfSize:(CGSize)size; {
    return [self.class METK_accelerateThumbnailOfImage:self size:size];
}

@end
