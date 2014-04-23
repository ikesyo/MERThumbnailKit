//
//  MERThumbnailManager.m
//  MERThumbnailKit
//
//  Created by William Towe on 4/23/14.
//  Copyright (c) 2014 Maestro, LLC. All rights reserved.
//

#import "MERThumbnailManager.h"
#import <MEFoundation/MEDebugging.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <libextobjc/EXTScope.h>
#import "UIImage+MERThumnailKitExtensions.h"
#import <MEFoundation/MEMacros.h>
#import <MEFoundation/MEFunctions.h>
#import <UIKit/UIKit.h>
#import "UIWebView+MERThumbnailKitExtensions.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

static CGSize const kMERThumbnailManagerDefaultThumbnailSize = {.width=175, .height=175};
static NSInteger const kMERThumbnailManagerDefaultThumbnailPage = 1;
static NSTimeInterval const kMERThumbnailManagerDefaultThumbnailTime = 1.0;

static long const kWebViewThumbnailMaxConcurrent = 2;

@interface MERThumbnailManager () <UIWebViewDelegate,NSCacheDelegate>
@property (readwrite,strong,nonatomic) NSURL *fileCacheDirectoryURL;

@property (strong,nonatomic) NSCache *memoryCache;
@property (strong,nonatomic) dispatch_queue_t fileCacheQueue;

@property (strong,nonatomic) dispatch_queue_t webViewThumbnailQueue;
@property (strong,nonatomic) dispatch_semaphore_t webViewThumbnailSemaphore;

- (void)_cacheImageToFile:(UIImage *)image url:(NSURL *)url;
- (void)_cacheImageToMemory:(UIImage *)image key:(NSString *)key;

- (RACSignal *)_imageThumbnailForURL:(NSURL *)url size:(CGSize)size;
- (RACSignal *)_movieThumbnailForURL:(NSURL *)url size:(CGSize)size time:(NSTimeInterval)time;
- (RACSignal *)_pdfThumbnailForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page;
- (RACSignal *)_rtfThumbnailForURL:(NSURL *)url size:(CGSize)size;
- (RACSignal *)_textThumbnailForURL:(NSURL *)url size:(CGSize)size;
- (RACSignal *)_webViewThumbnailForURL:(NSURL *)url size:(CGSize)size;

- (RACSignal *)_remoteImageThumbnailForURL:(NSURL *)url size:(CGSize)size;
- (RACSignal *)_remoteMovieThumbnailForURL:(NSURL *)url size:(CGSize)size time:(NSTimeInterval)time;
@end

@implementation MERThumbnailManager
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init {
    if (!(self = [super init]))
        return nil;
    
    [self setMemoryCache:[[NSCache alloc] init]];
    [self.memoryCache setName:[NSString stringWithFormat:@"com.maestro.merthumbnailkit.memorycache.%p",self]];
    [self.memoryCache setDelegate:self];
    
    [self setFileCacheQueue:dispatch_queue_create([NSString stringWithFormat:@"com.maestro.merthumbnailkit.filecache.%p",self].UTF8String, DISPATCH_QUEUE_SERIAL)];
    
    [self setWebViewThumbnailSemaphore:dispatch_semaphore_create(kWebViewThumbnailMaxConcurrent)];
    [self setWebViewThumbnailQueue:dispatch_queue_create([NSString stringWithFormat:@"com.maestro.merthumbnailkit.webview.%p",self].UTF8String, DISPATCH_QUEUE_CONCURRENT)];
    
    [self setCacheOptions:MERThumbnailManagerCacheOptionsDefault];
    
    NSURL *cachesDirectoryURL = [[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask].lastObject;
    NSURL *fileCacheDirectoryURL = [cachesDirectoryURL URLByAppendingPathComponent:@"com.maestro.merthumbnailkit.cache" isDirectory:YES];
    
    if (![fileCacheDirectoryURL checkResourceIsReachableAndReturnError:NULL]) {
        NSError *outError;
        if (![[NSFileManager defaultManager] createDirectoryAtURL:fileCacheDirectoryURL withIntermediateDirectories:YES attributes:nil error:&outError])
            MELogObject(outError);
    }
    
    [self setFileCacheDirectoryURL:fileCacheDirectoryURL];
    
    [self setThumbnailSize:kMERThumbnailManagerDefaultThumbnailSize];
    [self setThumbnailPage:kMERThumbnailManagerDefaultThumbnailPage];
    [self setThumbnailTime:kMERThumbnailManagerDefaultThumbnailTime];
    
    @weakify(self);
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil]
      takeUntil:[self rac_willDeallocSignal]]
     subscribeNext:^(id _) {
         @strongify(self);
         
         [self clearMemoryCache];
    }];
    
    return self;
}
#pragma mark NSCacheDelegate
- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    MELog(@"%@ %@",cache,obj);
}
#pragma mark UIWebViewDelegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    id<RACSubscriber> subscriber = webView.MER_subscriber;
    
    [subscriber sendNext:RACTuplePack(webView.request.URL,nil,@(MERThumbnailManagerCacheTypeNone))];
    [subscriber sendCompleted];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    id<RACSubscriber> subscriber = webView.MER_subscriber;
    
    NSURL *url = webView.request.URL;
    CGSize size = CGSizeMake(CGRectGetWidth(webView.frame), CGRectGetHeight(webView.frame));
    
    @weakify(self);
    
    MEDispatchDefaultAsync(^{
        @strongify(self);
        
        UIGraphicsBeginImageContext(size);
        
        [webView.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        dispatch_semaphore_signal(self.webViewThumbnailSemaphore);
        
        UIImage *retval = [image MER_thumbnailOfSize:self.thumbnailSize];
        
        [subscriber sendNext:RACTuplePack(url,retval,@(MERThumbnailManagerCacheTypeNone))];
        [subscriber sendCompleted];
        
        MEDispatchMainSync(^{
            [webView setDelegate:nil];
            [webView removeFromSuperview];
        });
    });
}
#pragma mark *** Public Methods ***
+ (instancetype)sharedManager; {
    static id retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[MERThumbnailManager alloc] init];
    });
    return retval;
}

- (void)clearFileCache; {
    NSError *outError;
    if (![[NSFileManager defaultManager] removeItemAtURL:self.fileCacheDirectoryURL error:&outError])
        MELogObject(outError);
}
- (void)clearMemoryCache; {
    [self.memoryCache removeAllObjects];
}

- (NSURL *)fileCacheURLForMemoryCacheKey:(NSString *)key; {
    NSParameterAssert(key);
    
    return [self.fileCacheDirectoryURL URLByAppendingPathComponent:key isDirectory:NO];
}
- (NSString *)memoryCacheKeyForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time; {
    NSParameterAssert(url);
    
    return [[NSString stringWithFormat:@"%@%@%@%@",url.lastPathComponent.stringByDeletingPathExtension,NSStringFromCGSize(size),@(page),@(time)] stringByAppendingPathExtension:url.lastPathComponent.pathExtension];
}
#pragma mark Signals
- (RACSignal *)thumbnailForURL:(NSURL *)url; {
    return [self thumbnailForURL:url size:self.thumbnailSize page:self.thumbnailPage time:self.thumbnailTime];
}
- (RACSignal *)thumbnailForURL:(NSURL *)url size:(CGSize)size; {
    return [self thumbnailForURL:url size:size page:self.thumbnailPage time:self.thumbnailTime];
}
- (RACSignal *)thumbnailForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page; {
    return [self thumbnailForURL:url size:size page:page time:self.thumbnailTime];
}
- (RACSignal *)thumbnailForURL:(NSURL *)url size:(CGSize)size time:(NSTimeInterval)time; {
    return [self thumbnailForURL:url size:size page:self.thumbnailPage time:time];
}
- (RACSignal *)thumbnailForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time; {
    NSParameterAssert(url);
    
    @weakify(self);
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        
        UIImage *retval = nil;
        
        // the key used to cache our thumbnail in memory
        NSString *key = [self memoryCacheKeyForURL:url size:size page:page time:time];
        
        // is memory caching enabled?
        if (self.isMemoryCachingEnabled) {
            // retrieve the thumbnail from the memory cache
            retval = [self.memoryCache objectForKey:key];
            
            // did we get a thumbnail? if so, we are done
            if (retval) {
                [subscriber sendNext:RACTuplePack(url,retval,@(MERThumbnailManagerCacheTypeMemory))];
                [subscriber sendCompleted];
            }
        }
        
        // no thumbnail yet?
        if (!retval) {
            // the file url used to cache our thumbnail on disk
            NSURL *cacheURL = [self fileCacheURLForMemoryCacheKey:key];
            
            // is file caching enabled?
            if (self.isFileCachingEnabled) {
                // check to see if the thumbnail exists at the cache url
                if ([cacheURL checkResourceIsReachableAndReturnError:NULL]) {
                    retval = [UIImage imageWithContentsOfFile:cacheURL.path];
                    
                    // did we get a thumbnail? if so, we are done
                    if (retval) {
                        [subscriber sendNext:RACTuplePack(url,retval,@(MERThumbnailManagerCacheTypeFile))];
                        [subscriber sendCompleted];
                    }
                }
            }
            
            // still no thumbnail?
            if (!retval) {
                // does the url point to a local file?
                if (url.isFileURL) {
                    NSString *uti = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)url.lastPathComponent.pathExtension, NULL);
                    
                    if (UTTypeConformsTo((__bridge CFStringRef)uti, kUTTypeImage)) {
                        [[self _imageThumbnailForURL:url size:size] subscribe:subscriber];
                    }
                    else if (UTTypeConformsTo((__bridge CFStringRef)uti, kUTTypeMovie)) {
                        [[self _movieThumbnailForURL:url size:size time:time] subscribe:subscriber];
                    }
                    else if (UTTypeConformsTo((__bridge CFStringRef)uti, kUTTypePDF)) {
                        [[self _pdfThumbnailForURL:url size:size page:page] subscribe:subscriber];
                    }
                    else if (UTTypeConformsTo((__bridge CFStringRef)uti, kUTTypeRTF) ||
                             UTTypeConformsTo((__bridge CFStringRef)uti, kUTTypeRTFD)) {
                        [[self _rtfThumbnailForURL:url size:size] subscribe:subscriber];
                    }
                    else if (UTTypeConformsTo((__bridge CFStringRef)uti, kUTTypePlainText)) {
                        [[self _textThumbnailForURL:url size:size] subscribe:subscriber];
                    }
                    else if (UTTypeConformsTo((__bridge CFStringRef)uti, kUTTypeHTML) ||
                             [@[@"doc",
                                @"docx",
                                @"ppt",
                                @"pptx",
                                @"xls",
                                @"xlsx",
                                @"csv"] containsObject:url.lastPathComponent.pathExtension.lowercaseString]) {
                        [[self _webViewThumbnailForURL:url size:size] subscribe:subscriber];
                    }
                    else {
                        [subscriber sendNext:RACTuplePack(url,nil,@(MERThumbnailManagerCacheTypeNone))];
                        [subscriber sendCompleted];
                    }
                }
                else {
                    NSString *uti = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)url.lastPathComponent.pathExtension, NULL);
                    
                    if (UTTypeConformsTo((__bridge CFStringRef)uti, kUTTypeImage)) {
                        [[self _remoteImageThumbnailForURL:url size:size] subscribe:subscriber];
                    }
                    else if (UTTypeConformsTo((__bridge CFStringRef)uti, kUTTypeMovie)) {
                        [[self _remoteMovieThumbnailForURL:url size:size time:time] subscribe:subscriber];
                    }
                    else {
                        [subscriber sendNext:RACTuplePack(url,nil,@(MERThumbnailManagerCacheTypeNone))];
                        [subscriber sendCompleted];
                    }
                }
            }
        }
        
        return nil;
    }] flattenMap:^RACStream *(RACTuple *value) {
        @strongify(self);
        
        RACTupleUnpack(NSURL *url, UIImage *image, NSNumber *cacheType) = value;
        
        if (image) {
            NSString *key = [self memoryCacheKeyForURL:url size:size page:page time:time];
            
            if (cacheType.integerValue == MERThumbnailManagerCacheTypeNone) {
                if (self.isFileCachingEnabled) {
                    NSURL *cacheURL = [self fileCacheURLForMemoryCacheKey:key];
                    
                    [self _cacheImageToFile:image url:cacheURL];
                }
                
                if (self.isMemoryCachingEnabled) {
                    [self _cacheImageToMemory:image key:key];
                }
            }
            
            if (cacheType.integerValue == MERThumbnailManagerCacheTypeFile) {
                if (self.isMemoryCachingEnabled) {
                    [self _cacheImageToMemory:image key:key];
                }
            }
        }
        
        return [RACSignal return:value];
    }];
}
#pragma mark Properties
- (BOOL)isFileCachingEnabled {
    return ((self.cacheOptions & MERThumbnailManagerCacheOptionsFile) != 0);
}
- (BOOL)isMemoryCachingEnabled {
    return ((self.cacheOptions & MERThumbnailManagerCacheOptionsMemory) != 0);
}

- (void)setThumbnailSize:(CGSize)thumbnailSize {
    _thumbnailSize = (CGSizeEqualToSize(CGSizeZero, thumbnailSize)) ? kMERThumbnailManagerDefaultThumbnailSize : thumbnailSize;
}
- (void)setThumbnailPage:(NSInteger)thumbnailPage {
    _thumbnailPage = MAX(thumbnailPage, kMERThumbnailManagerDefaultThumbnailPage);
}
#pragma mark *** Private Methods ***
- (void)_cacheImageToFile:(UIImage *)image url:(NSURL *)url; {
    NSParameterAssert(image);
    NSParameterAssert(url);
    
    dispatch_async(self.fileCacheQueue, ^{
        NSData *data = (image.MER_hasAlpha) ? UIImagePNGRepresentation(image) : UIImageJPEGRepresentation(image, 1.0);
        
        [data writeToURL:url options:NSDataWritingAtomic error:NULL];
    });
}
- (void)_cacheImageToMemory:(UIImage *)image key:(NSString *)key; {
    NSParameterAssert(image);
    NSParameterAssert(key);
    
    [self.memoryCache setObject:image forKey:key cost:(image.size.width * image.size.height * image.scale)];
}
#pragma mark Signals
- (RACSignal *)_imageThumbnailForURL:(NSURL *)url size:(CGSize)size; {
    NSParameterAssert(url);
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        UIImage *image = [UIImage imageWithContentsOfFile:url.path];
        UIImage *retval = [image MER_thumbnailOfSize:size];
        
        [subscriber sendNext:RACTuplePack(url,retval,@(MERThumbnailManagerCacheTypeNone))];
        [subscriber sendCompleted];
        
        return nil;
    }];
}
- (RACSignal *)_movieThumbnailForURL:(NSURL *)url size:(CGSize)size time:(NSTimeInterval)time; {
    NSParameterAssert(url);
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        AVAsset *asset = [AVAsset assetWithURL:url];
        AVAssetImageGenerator *assetImageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        
        [assetImageGenerator setAppliesPreferredTrackTransform:YES];
        
        int32_t const kPreferredTimeScale = 1;
        
        CGImageRef imageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(time, kPreferredTimeScale) actualTime:NULL error:NULL];
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        
        CGImageRelease(imageRef);
        
        UIImage *retval = [image MER_thumbnailOfSize:size];
        
        [subscriber sendNext:RACTuplePack(url,retval,@(MERThumbnailManagerCacheTypeNone))];
        [subscriber sendCompleted];
        
        return nil;
    }];
}
- (RACSignal *)_pdfThumbnailForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page; {
    NSParameterAssert(url);
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        CGPDFDocumentRef documentRef = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
        size_t numberOfPages = CGPDFDocumentGetNumberOfPages(documentRef);
        size_t pageNumber = MEBoundedValue(page, kMERThumbnailManagerDefaultThumbnailPage, numberOfPages);
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
        
        UIImage *retval = [image MER_thumbnailOfSize:size];
        
        CGPDFDocumentRelease(documentRef);
        
        [subscriber sendNext:RACTuplePack(url,retval,@(MERThumbnailManagerCacheTypeNone))];
        [subscriber sendCompleted];
        
        return nil;
    }];
}
- (RACSignal *)_rtfThumbnailForURL:(NSURL *)url size:(CGSize)size; {
    NSParameterAssert(url);
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSDictionary *attributes;
        NSError *outError;
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithFileURL:url options:@{NSDocumentTypeDocumentAttribute: ([url.lastPathComponent.pathExtension isEqualToString:@"rtf"]) ? NSRTFTextDocumentType : NSRTFDTextDocumentType} documentAttributes:&attributes error:&outError];
        
        if (attributedString) {
            CGSize const kSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
            
            NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedString];
            NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
            NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:kSize];
            
            [textStorage addLayoutManager:layoutManager];
            [layoutManager addTextContainer:textContainer];
            
            [layoutManager ensureLayoutForCharacterRange:NSMakeRange(0, textStorage.length)];
            
            UIGraphicsBeginImageContextWithOptions(kSize, YES, 0);
            
            UIColor *backgroundColor = ([textStorage attribute:NSBackgroundColorAttributeName atIndex:0 effectiveRange:NULL]) ?: [UIColor whiteColor];
            
            [backgroundColor setFill];
            UIRectFill(CGRectMake(0, 0, kSize.width, kSize.height));
            
            [layoutManager drawGlyphsForGlyphRange:[layoutManager glyphRangeForCharacterRange:NSMakeRange(0, textStorage.length) actualCharacterRange:NULL] atPoint:CGPointZero];
            
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            
            UIImage *retval = [image MER_thumbnailOfSize:size];
            
            [subscriber sendNext:RACTuplePack(url,retval,@(MERThumbnailManagerCacheTypeNone))];
        }
        else {
            MELogObject(outError);
            
            [subscriber sendNext:RACTuplePack(url,nil,@(MERThumbnailManagerCacheTypeNone))];
        }
        
        [subscriber sendCompleted];
        
        return nil;
    }];
}
- (RACSignal *)_textThumbnailForURL:(NSURL *)url size:(CGSize)size; {
    NSParameterAssert(url);
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSDictionary *attributes;
        NSError *outError;
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithFileURL:url options:@{NSDocumentTypeDocumentAttribute: NSPlainTextDocumentType,NSDefaultAttributesDocumentAttribute: @{NSForegroundColorAttributeName: [UIColor blackColor],NSBackgroundColorAttributeName: [UIColor whiteColor],NSFontAttributeName: [UIFont systemFontOfSize:17]}} documentAttributes:&attributes error:&outError];
        
        if (attributedString) {
            CGSize const kSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
            
            NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedString];
            NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
            NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:kSize];
            
            [textStorage addLayoutManager:layoutManager];
            [layoutManager addTextContainer:textContainer];
            
            [layoutManager ensureLayoutForCharacterRange:NSMakeRange(0, textStorage.length)];
            
            UIGraphicsBeginImageContextWithOptions(kSize, YES, 0);
            
            UIColor *backgroundColor = ([textStorage attribute:NSBackgroundColorAttributeName atIndex:0 effectiveRange:NULL]) ?: [UIColor whiteColor];
            
            [backgroundColor setFill];
            UIRectFill(CGRectMake(0, 0, kSize.width, kSize.height));
            
            [layoutManager drawGlyphsForGlyphRange:[layoutManager glyphRangeForCharacterRange:NSMakeRange(0, textStorage.length) actualCharacterRange:NULL] atPoint:CGPointZero];
            
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            
            UIImage *retval = [image MER_thumbnailOfSize:size];
            
            [subscriber sendNext:RACTuplePack(url,retval,@(MERThumbnailManagerCacheTypeNone))];
        }
        else {
            MELogObject(outError);
            
            [subscriber sendNext:RACTuplePack(url,nil,@(MERThumbnailManagerCacheTypeNone))];
        }
        
        [subscriber sendCompleted];
        
        return nil;
    }];
}
- (RACSignal *)_webViewThumbnailForURL:(NSURL *)url size:(CGSize)size; {
    NSParameterAssert(url);
    
    @weakify(self);
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        
        dispatch_async(self.webViewThumbnailQueue, ^{
            @strongify(self);
            
            dispatch_semaphore_wait(self.webViewThumbnailSemaphore, DISPATCH_TIME_FOREVER);
            
            MEDispatchMainSync(^{
                @strongify(self);
                
                UIWindow *window = [UIApplication sharedApplication].keyWindow;
                UIWebView *webView = [[UIWebView alloc] initWithFrame:window.bounds];
                
                [webView setUserInteractionEnabled:NO];
                [webView setScalesPageToFit:YES];
                [webView setDelegate:self];
                [webView setMER_subscriber:subscriber];
                
                [window insertSubview:webView atIndex:0];
                
                [webView loadRequest:[NSURLRequest requestWithURL:url]];
            });
        });
        
        return nil;
    }];
}

- (RACSignal *)_remoteImageThumbnailForURL:(NSURL *)url size:(CGSize)size; {
    NSParameterAssert(url);
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                [subscriber sendError:error];
            }
            else {
                UIImage *image = [UIImage imageWithData:data];
                UIImage *retval = [image MER_thumbnailOfSize:size];
                
                [subscriber sendNext:RACTuplePack(url,retval,@(MERThumbnailManagerCacheTypeNone))];
                [subscriber sendCompleted];
            }
        }];
        
        [task resume];
        
        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
}
- (RACSignal *)_remoteMovieThumbnailForURL:(NSURL *)url size:(CGSize)size time:(NSTimeInterval)time; {
    NSParameterAssert(url);
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        AVAsset *asset = [AVAsset assetWithURL:url];
        AVAssetImageGenerator *assetImageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        
        [assetImageGenerator setAppliesPreferredTrackTransform:YES];
        
        int32_t const kPreferredTimeScale = 1;
        
        [assetImageGenerator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:CMTimeMakeWithSeconds(time, kPreferredTimeScale)]] completionHandler:^(CMTime requestedTime, CGImageRef imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
            if (result == AVAssetImageGeneratorSucceeded) {
                UIImage *image = [UIImage imageWithCGImage:imageRef];
                UIImage *retval = [image MER_thumbnailOfSize:size];
                
                [subscriber sendNext:RACTuplePack(url,retval,@(MERThumbnailManagerCacheTypeNone))];
                [subscriber sendCompleted];
            }
            else {
                [subscriber sendError:error];
            }
        }];
        
        return [RACDisposable disposableWithBlock:^{
            [assetImageGenerator cancelAllCGImageGeneration];
        }];
    }];
}

@end
