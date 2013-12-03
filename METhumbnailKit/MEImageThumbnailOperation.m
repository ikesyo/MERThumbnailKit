//
//  MEImageThumbnailOperation.m
//  METhumbnailKit
//
//  Created by William Towe on 10/16/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import "MEImageThumbnailOperation.h"
#import "UIImage+METKExtensions.h"

@interface MEImageThumbnailOperation ()
@property (readwrite,strong,nonatomic) NSURL *url;
@property (readwrite,assign,nonatomic) CGSize size;
@property (copy,nonatomic) METhumbnailOperationCompletionBlock completion;
@end

@implementation MEImageThumbnailOperation

- (void)main {
    UIImage *image = [UIImage imageWithContentsOfFile:self.url.path];
    UIImage *retval = [image METK_thumbnailOfSize:self.size];
    
    self.completion(self.url,(self.isCancelled) ? nil : retval);
}

- (instancetype)initWithURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time completion:(METhumbnailOperationCompletionBlock)completion; {
    if (!(self = [super init]))
        return nil;
    
    NSParameterAssert(url);
    NSParameterAssert(!CGSizeEqualToSize(size, CGSizeZero));
    NSParameterAssert(completion);
    
    [self setUrl:url];
    [self setSize:size];
    [self setCompletion:completion];
    
    return self;
}

@end
