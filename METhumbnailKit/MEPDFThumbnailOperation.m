//
//  MEPDFThumbnailOperation.m
//  METhumbnailKit
//
//  Created by William Towe on 10/17/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import "MEPDFThumbnailOperation.h"
#import "UIImage+METKExtensions.h"

@interface MEPDFThumbnailOperation ()
@property (readwrite,strong,nonatomic) NSURL *url;
@property (readwrite,assign,nonatomic) CGSize size;
@property (assign,nonatomic) NSInteger page;
@property (copy,nonatomic) METhumbnailOperationCompletionBlock completion;
@end

@implementation MEPDFThumbnailOperation

- (void)main {
    CGPDFDocumentRef documentRef = CGPDFDocumentCreateWithURL((__bridge CFURLRef)self.url);
    size_t numberOfPages = CGPDFDocumentGetNumberOfPages(documentRef);
    size_t const kMinimumPageNumber = 1;
    size_t pageNumber = MAX(MIN(self.page, numberOfPages), kMinimumPageNumber);
    CGPDFPageRef pageRef = CGPDFDocumentGetPage(documentRef, pageNumber);
    CGSize pageSize = CGPDFPageGetBoxRect(pageRef, kCGPDFMediaBox).size;
    
    UIGraphicsBeginImageContextWithOptions(pageSize, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextTranslateCTM(context, 0, pageSize.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextDrawPDFPage(context, pageRef);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImage *retval = [image METK_thumbnailOfSize:self.size];
    
    CGPDFDocumentRelease(documentRef);
    
    self.completion(self.url,retval);
}

- (instancetype)initWithURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time completion:(METhumbnailOperationCompletionBlock)completion; {
    if (!(self = [super init]))
        return nil;
    
    NSParameterAssert(url);
    NSParameterAssert(!CGSizeEqualToSize(size, CGSizeZero));
    NSParameterAssert(completion);
    
    [self setUrl:url];
    [self setSize:size];
    [self setPage:page];
    [self setCompletion:completion];
    
    return self;
}

@end
