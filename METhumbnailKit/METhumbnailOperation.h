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

@protocol METhumbnailOperation <NSObject>
@required

@property (readonly,strong,nonatomic) NSURL *url;
@property (readonly,assign,nonatomic) CGSize size;

- (instancetype)initWithURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time completion:(METhumbnailOperationCompletionBlock)completion;
@end
