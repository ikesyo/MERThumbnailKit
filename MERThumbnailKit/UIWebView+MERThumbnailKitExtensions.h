//
//  UIWebView+MERThumbnailKitExtensions.h
//  MERThumbnailKit
//
//  Created by William Towe on 4/23/14.
//  Copyright (c) 2014 Maestro, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RACSubscriber;

@interface UIWebView (MERThumbnailKitExtensions)

@property (assign,nonatomic) id<RACSubscriber> MER_subscriber;

@end
