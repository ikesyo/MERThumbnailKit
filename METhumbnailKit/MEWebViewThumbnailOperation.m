//
//  MEOfficeThumbnailOperation.m
//  METhumbnailKit
//
//  Created by William Towe on 10/17/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import "MEWebViewThumbnailOperation.h"
#import "UIImage+METKExtensions.h"

@interface MEWebViewThumbnailOperation () <UIWebViewDelegate>
@property (readwrite,strong,nonatomic) NSURL *url;
@property (readwrite,assign,nonatomic) CGSize size;
@property (copy,nonatomic) METhumbnailOperationCompletionBlock completion;

@property (assign,nonatomic,getter = isExecuting) BOOL executing;
@property (assign,nonatomic,getter = isFinished) BOOL finished;

@property (strong,nonatomic) UIWebView *webView;
@end

@implementation MEWebViewThumbnailOperation

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
    
    [self setWebView:[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, METhumbnailOperationDefaultSize.width, METhumbnailOperationDefaultSize.height)]];
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
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        UIGraphicsBeginImageContext(webView.layer.bounds.size);
        
        [webView.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        UIImage *retval = [image METK_thumbnailOfSize:strongSelf.size];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [webView setDelegate:nil];
            [webView removeFromSuperview];
        });
        
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
    [self setCompletion:completion];
    
    return self;
}

@end
