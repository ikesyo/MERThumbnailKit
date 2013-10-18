//
//  MEOfficeThumbnailOperation.m
//  METhumbnailKit
//
//  Created by William Towe on 10/17/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import "MEOfficeThumbnailOperation.h"
#import "UIImage+METKExtensions.h"

#import <UIKit/UIKit.h>

@interface MEOfficeThumbnailOperation () <UIWebViewDelegate>
@property (readwrite,strong,nonatomic) NSURL *url;
@property (readwrite,assign,nonatomic) CGSize size;
@property (assign,nonatomic) NSInteger page;
@property (copy,nonatomic) METhumbnailOperationCompletionBlock completion;

@property (assign,nonatomic,getter = isExecuting) BOOL executing;
@property (assign,nonatomic,getter = isFinished) BOOL finished;

@property (strong,nonatomic) UIWebView *webView;
@end

@implementation MEOfficeThumbnailOperation

- (BOOL)isConcurrent {
    return YES;
}
- (void)start {
    if (![NSThread isMainThread]) {
        [self performSelector:@selector(start) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    [self setExecuting:YES];
    [self didChangeValueForKey:@"isExecuting"];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [self setWebView:[[UIWebView alloc] initWithFrame:window.bounds]];
    [self.webView setUserInteractionEnabled:NO];
    [self.webView setScalesPageToFit:YES];
    [self.webView setDelegate:self];
    [window insertSubview:self.webView atIndex:0];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.webView setDelegate:nil];
    [self.webView removeFromSuperview];
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        strongSelf.completion(strongSelf.url,nil);
        
        [strongSelf willChangeValueForKey:@"isExecuting"];
        [strongSelf willChangeValueForKey:@"isFinished"];
        [strongSelf setExecuting:NO];
        [strongSelf setFinished:YES];
        [strongSelf didChangeValueForKey:@"isExecuting"];
        [strongSelf didChangeValueForKey:@"isFinished"];
    });
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.webView setDelegate:nil];
    [self.webView removeFromSuperview];
    
    __weak typeof(self) weakSelf = self;
    __weak CALayer *layer = webView.layer;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        __strong CALayer *strongLayer = layer;
        
        UIGraphicsBeginImageContext(strongLayer.bounds.size);
        
        [strongLayer renderInContext:UIGraphicsGetCurrentContext()];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        UIImage *retval = [image METK_thumbnailOfSize:strongSelf.size];
        
        strongSelf.completion(strongSelf.url,retval);
        
        [strongSelf willChangeValueForKey:@"isExecuting"];
        [strongSelf willChangeValueForKey:@"isFinished"];
        [strongSelf setExecuting:NO];
        [strongSelf setFinished:YES];
        [strongSelf didChangeValueForKey:@"isExecuting"];
        [strongSelf didChangeValueForKey:@"isFinished"];
    });
}

- (instancetype)initWithURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time completion:(METhumbnailOperationCompletionBlock)completion {
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