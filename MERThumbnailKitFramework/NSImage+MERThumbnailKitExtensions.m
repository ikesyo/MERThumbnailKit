//
//  NSImage+MERThumbnailKitExtensions.m
//  MERThumbnailKit
//
//  Created by William Towe on 5/1/14.
//  Copyright (c) 2014 Maestro, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
