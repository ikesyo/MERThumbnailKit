//
//  METhumbnailOperation.h
//  METhumbnailKit
//
//  Created by William Towe on 10/16/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIImage.h>

typedef void(^METhumbnailOperationCompletionBlock)(NSURL *url,UIImage *image);

static CGSize const METhumbnailOperationDefaultSize = {.width=320, .height=480};

@protocol METhumbnailOperation <NSObject>
@required

@property (readonly,strong,nonatomic) NSURL *url;
@property (readonly,assign,nonatomic) CGSize size;

- (instancetype)initWithURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time completion:(METhumbnailOperationCompletionBlock)completion;
@end
