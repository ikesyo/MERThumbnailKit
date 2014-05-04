//
//  NSURLRequest+MERThumbnailKitExtensions.h
//  MERThumbnailKit
//
//  Created by William Towe on 5/4/14.
//  Copyright (c) 2014 Maestro, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MERThumbnailManager.h"

@protocol RACSubscriber;

@interface NSURLRequest (MERThumbnailKitExtensions)

@property (readonly,strong,nonatomic) id<RACSubscriber> MER_subscriber;
@property (readonly,copy,nonatomic) MERThumbnailManagerDownloadProgressBlock MER_downloadProgressBlock;

@end

@interface NSMutableURLRequest (MERThumbnailKitExtensions)

@property (readwrite,strong,nonatomic) id<RACSubscriber> MER_subscriber;
@property (readwrite,copy,nonatomic) MERThumbnailManagerDownloadProgressBlock MER_downloadProgressBlock;

@end