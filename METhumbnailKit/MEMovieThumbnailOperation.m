//
//  MEMovieThumbnailOperation.m
//  METhumbnailKit
//
//  Created by William Towe on 10/17/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import "MEMovieThumbnailOperation.h"
#import "UIImage+METKExtensions.h"

#import <AVFoundation/AVFoundation.h>

@interface MEMovieThumbnailOperation ()
@property (readwrite,strong,nonatomic) NSURL *url;
@property (readwrite,assign,nonatomic) CGSize size;
@property (assign,nonatomic) NSTimeInterval time;
@property (copy,nonatomic) METhumbnailOperationCompletionBlock completion;
@end

@implementation MEMovieThumbnailOperation

- (void)main {
    AVAsset *asset = [AVAsset assetWithURL:self.url];
    AVAssetImageGenerator *assetImageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    
    [assetImageGenerator setAppliesPreferredTrackTransform:YES];
    
    int32_t const kPreferredTimeScale = 1;
    CGImageRef imageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(self.time, kPreferredTimeScale) actualTime:NULL error:NULL];
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    UIImage *retval = [image METK_accelerateThumbnailOfSize:self.size];
    
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
    [self setTime:time];
    [self setCompletion:completion];
    
    return self;
}

@end
