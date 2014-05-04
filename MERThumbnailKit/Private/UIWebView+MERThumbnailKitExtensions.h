//
//  UIWebView+MERThumbnailKitExtensions.h
//  MERThumbnailKit
//
//  Created by William Towe on 5/2/14.
//  Copyright (c) 2014 Maestro, LLC. All rights reserved.
//

#import <UIKit/UIWebView.h>

@protocol RACSubscriber;

@interface UIWebView (MERThumbnailKitExtensions)

@property (assign,nonatomic) id<RACSubscriber> MER_subscriber;
@property (strong,nonatomic) NSURL *MER_originalURL;
@property (assign,nonatomic) NSInteger MER_concurrentRequestCount;

@end
