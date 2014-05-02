//
//  MERThumbnailManager.m
//  MERThumbnailKit
//
//  Created by William Towe on 5/1/14.
//  Copyright (c) 2014 Maestro, LLC. All rights reserved.
//

#import "MERThumbnailManager.h"
#import "MERThumbnailKitFunctions.h"
#import <MEFoundation/MEFoundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACDelegateProxy.h>
#import <libextobjc/EXTScope.h>
#import <AVFoundation/AVFoundation.h>

#if (TARGET_OS_IPHONE)
#import <MobileCoreServices/MobileCoreServices.h>
#import <UIKit/UIApplication.h>

#import "UIImage+MERThumbnailKitExtensions.h"
#import "UIWebView+MERThumbnailKitExtensions.h"

#define MERThumbnailKitImageClass UIImage
#else
#import <QuickLook/QuickLook.h>

#import "NSImage+MERThumbnailKitExtensions.h"

#define MERThumbnailKitImageClass NSImage
#endif

#if !__has_feature(objc_arc)
#error MERThumbnailKit requires ARC
#endif

static CGSize const kMERThumbnailManagerDefaultThumbnailSize = {.width=175, .height=175};
static NSInteger const kMERThumbnailManagerDefaultThumbnailPage = 1;
static NSTimeInterval const kMERThumbnailManagerDefaultThumbnailTime = 1.0;

#if (TARGET_OS_IPHONE)
@interface MERThumbnailManager () <UIWebViewDelegate,NSCacheDelegate,NSURLConnectionDataDelegate>
#else
@interface MERThumbnailManager () <NSCacheDelegate>
#endif

@property (readwrite,strong,nonatomic) NSURL *fileCacheDirectoryURL;

@property (strong,nonatomic) NSCache *memoryCache;
@property (strong,nonatomic) dispatch_queue_t fileCacheQueue;

#if (TARGET_OS_IPHONE)
@property (strong,nonatomic) dispatch_queue_t webViewThumbnailQueue;
@property (strong,nonatomic) dispatch_semaphore_t webViewThumbnailSemaphore;
#endif

- (void)_cacheImageToFile:(MERThumbnailKitImageClass *)image url:(NSURL *)url;
- (void)_cacheImageToMemory:(MERThumbnailKitImageClass *)image key:(NSString *)key;

- (RACSignal *)_imageThumbnailForURL:(NSURL *)url size:(CGSize)size;
- (RACSignal *)_movieThumbnailForURL:(NSURL *)url size:(CGSize)size time:(NSTimeInterval)time;
- (RACSignal *)_pdfThumbnailForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page;
- (RACSignal *)_rtfThumbnailForURL:(NSURL *)url size:(CGSize)size;
- (RACSignal *)_textThumbnailForURL:(NSURL *)url size:(CGSize)size;

#if (TARGET_OS_IPHONE)
- (RACSignal *)_webViewThumbnailForURL:(NSURL *)url size:(CGSize)size;
#else
- (RACSignal *)_quickLookThumbnailForURL:(NSURL *)url size:(CGSize)size;
#endif

- (RACSignal *)_remoteThumbnailForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time;
- (RACSignal *)_remoteImageThumbnailForURL:(NSURL *)url size:(CGSize)size;
- (RACSignal *)_remoteMovieThumbnailForURL:(NSURL *)url size:(CGSize)size time:(NSTimeInterval)time;
@end

@implementation MERThumbnailManager
#pragma mark *** Subclass Overrides ***
- (id)init {
    if (!(self = [super init]))
        return nil;
    
    [self setMemoryCache:[[NSCache alloc] init]];
    [self.memoryCache setName:[NSString stringWithFormat:@"com.maestro.merthumbnailkit.memorycache.%p",self]];
    [self.memoryCache setDelegate:self];
    
    [self setFileCacheQueue:dispatch_queue_create([NSString stringWithFormat:@"com.maestro.merthumbnailkit.filecache.%p",self].UTF8String, DISPATCH_QUEUE_SERIAL)];
    
#if (TARGET_OS_IPHONE)
    long const kWebViewThumbnailMaxConcurrent = [NSProcessInfo processInfo].activeProcessorCount;
    
    [self setWebViewThumbnailSemaphore:dispatch_semaphore_create(kWebViewThumbnailMaxConcurrent)];
    [self setWebViewThumbnailQueue:dispatch_queue_create([NSString stringWithFormat:@"com.maestro.merthumbnailkit.webview.%p",self].UTF8String, DISPATCH_QUEUE_CONCURRENT)];
#endif
    
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
    
#if (TARGET_OS_IPHONE)
    @weakify(self);
    
    [[[[NSNotificationCenter defaultCenter]
       rac_addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil]
      takeUntil:[self rac_willDeallocSignal]]
     subscribeNext:^(id _) {
         @strongify(self);
         
         [self clearThumbnailMemoryCache];
    }];
#endif
    
    return self;
}
#pragma mark NSCacheDelegate
- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    MELog(@"%@ %@",cache,obj);
}
#pragma mark UIWebViewDelegate

#if (TARGET_OS_IPHONE)
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
#endif

#pragma mark *** Public Methods ***
+ (instancetype)sharedManager; {
    static id retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[MERThumbnailManager alloc] init];
    });
    return retval;
}

- (void)clearThumbnailFileCache; {
    NSError *outError;
    if (![[NSFileManager defaultManager] removeItemAtURL:self.fileCacheDirectoryURL error:&outError])
        MELogObject(outError);
}
- (void)clearThumbnailMemoryCache; {
    [self.memoryCache removeAllObjects];
}

- (NSURL *)thumbnailFileCacheURLForMemoryCacheKey:(NSString *)key; {
    NSParameterAssert(key);
    
    return [self.fileCacheDirectoryURL URLByAppendingPathComponent:key isDirectory:NO];
}
- (NSString *)memoryCacheKeyForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time; {
    NSParameterAssert(url);
    
#if (TARGET_OS_IPHONE)
    return [[NSString stringWithFormat:@"%@%@%@%@",url.lastPathComponent.stringByDeletingPathExtension,NSStringFromCGSize(size),@(page),@(time)] stringByAppendingPathExtension:url.lastPathComponent.pathExtension];
#else
    return [[NSString stringWithFormat:@"%@%@%@%@",url.lastPathComponent.stringByDeletingPathExtension,NSStringFromSize(NSSizeFromCGSize(size)),@(page),@(time)] stringByAppendingPathExtension:url.lastPathComponent.pathExtension];
#endif
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
    return [self thumbnailForURL:url size:size page:page time:time downloadCompletion:nil];
}
- (RACSignal *)thumbnailForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time downloadCompletion:(MERThumbnailManagerDownloadCompletionBlock)downloadCompletion; {
    NSParameterAssert(url);
    
    @weakify(self);
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        
        MERThumbnailKitImageClass *retval = nil;
        NSString *key = [self memoryCacheKeyForURL:url size:size page:page time:time];
        
        if (self.isMemoryCachingEnabled) {
            retval = [self.memoryCache objectForKey:key];
            
            if (retval) {
                [subscriber sendNext:RACTuplePack(url,retval,@(MERThumbnailManagerCacheTypeMemory))];
                [subscriber sendCompleted];
            }
        }
        
        if (!retval) {
            if (self.isFileCachingEnabled) {
                NSURL *fileCacheURL = [self thumbnailFileCacheURLForMemoryCacheKey:key];
                
                if ([fileCacheURL checkResourceIsReachableAndReturnError:NULL]) {
                    retval = [[MERThumbnailKitImageClass alloc] initWithContentsOfFile:fileCacheURL.path];
                    
                    if (retval) {
                        [subscriber sendNext:RACTuplePack(url,retval,@(MERThumbnailManagerCacheTypeFile))];
                        [subscriber sendCompleted];
                    }
                }
            }
        }
        
        if (!retval) {
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
#if (TARGET_OS_IPHONE)
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
#endif
                else {
#if (TARGET_OS_IPHONE)
                    [subscriber sendNext:RACTuplePack(url,nil,@(MERThumbnailManagerCacheTypeNone))];
                    [subscriber sendCompleted];
#else
                    [[self _quickLookThumbnailForURL:url size:size] subscribe:subscriber];
#endif
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
        
        return nil;
    }] flattenMap:^RACStream *(RACTuple *value) {
        @strongify(self);
        
        RACTupleUnpack(NSURL *url, MERThumbnailKitImageClass *image, NSNumber *cacheType) = value;
        
        if (image) {
            NSString *key = [self memoryCacheKeyForURL:url size:size page:page time:time];
            NSURL *fileCacheURL = [self thumbnailFileCacheURLForMemoryCacheKey:key];
            MERThumbnailManagerCacheType cacheTypeValue = cacheType.integerValue;
            
            switch (cacheTypeValue) {
                case MERThumbnailManagerCacheTypeNone:
                    if (self.isFileCachingEnabled)
                        [self _cacheImageToFile:image url:fileCacheURL];
                case MERThumbnailManagerCacheTypeFile:
                    if (self.isMemoryCachingEnabled)
                        [self _cacheImageToMemory:image key:key];
                    break;
                default:
                    break;
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
- (void)_cacheImageToFile:(MERThumbnailKitImageClass *)image url:(NSURL *)url; {
    NSParameterAssert(image);
    NSParameterAssert(url);
    
    dispatch_async(self.fileCacheQueue, ^{
#if (TARGET_OS_IPHONE)
        CGImageRef imageRef = image.CGImage;
#else
        CGImageRef imageRef = [image CGImageForProposedRect:NULL context:NULL hints:nil];
#endif

        CGDataProviderRef dataProviderRef = CGImageGetDataProvider(imageRef);
        NSData *data = (__bridge_transfer NSData *)CGDataProviderCopyData(dataProviderRef);
        NSError *outError;
        
        if (![data writeToURL:url options:0 error:&outError])
            MELogObject(outError);
    });
}
- (void)_cacheImageToMemory:(MERThumbnailKitImageClass *)image key:(NSString *)key; {
    NSParameterAssert(image);
    NSParameterAssert(key);
    
    [self.memoryCache setObject:image forKey:key cost:(image.size.width * image.size.height)];
}
#pragma mark Signals
- (RACSignal *)_imageThumbnailForURL:(NSURL *)url size:(CGSize)size; {
    NSParameterAssert(url);
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        MERThumbnailKitImageClass *image = [[MERThumbnailKitImageClass alloc] initWithContentsOfFile:url.path];
        MERThumbnailKitImageClass *retval = [image MER_thumbnailOfSize:size];
        
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
        CGImageRef sourceImageRef = MERThumbnailKitCreateCGImageThumbnailWithSize(imageRef, size);
#if (TARGET_OS_IPHONE)
        MERThumbnailKitImageClass *retval = [[MERThumbnailKitImageClass alloc] initWithCGImage:sourceImageRef];
#else
        MERThumbnailKitImageClass *retval = [[MERThumbnailKitImageClass alloc] initWithCGImage:sourceImageRef size:NSZeroSize];
#endif
        
        CGImageRelease(imageRef);
        CGImageRelease(sourceImageRef);
        
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
        
#if (TARGET_OS_IPHONE)
        UIGraphicsBeginImageContextWithOptions(pageSize, NO, 0);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
        CGContextTranslateCTM(context, 0, pageSize.height);
        CGContextScaleCTM(context, 1, -1);
        CGContextDrawPDFPage(context, pageRef);
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        UIImage *retval = [image MER_thumbnailOfSize:size];
#else
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL, pageSize.width, pageSize.height, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
        
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
        CGContextDrawPDFPage(context, pageRef);
        
        CGImageRef sourceImageRef = CGBitmapContextCreateImage(context);
        CGImageRef imageRef = MERThumbnailKitCreateCGImageThumbnailWithSize(sourceImageRef, size);
        NSImage *retval = [[NSImage alloc] initWithCGImage:imageRef size:NSZeroSize];
        
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpaceRef);
        CGImageRelease(sourceImageRef);
        CGImageRelease(imageRef);
#endif
        
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
#if (TARGET_OS_IPHONE)
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithFileURL:url options:@{NSDocumentTypeDocumentAttribute: ([url.lastPathComponent.pathExtension isEqualToString:@"rtf"]) ? NSRTFTextDocumentType : NSRTFDTextDocumentType} documentAttributes:&attributes error:&outError];
#else
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithURL:url options:@{NSDocumentTypeDocumentAttribute: ([url.lastPathComponent.pathExtension isEqualToString:@"rtf"]) ? NSRTFTextDocumentType : NSRTFDTextDocumentType} documentAttributes:&attributes error:&outError];
#endif
        
        if (attributedString) {
#if (TARGET_OS_IPHONE)
            CGSize const kSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
            
            UIGraphicsBeginImageContextWithOptions(kSize, YES, 0);
            
            UIColor *backgroundColor = ([attributedString attribute:NSBackgroundColorAttributeName atIndex:0 effectiveRange:NULL]) ?: [UIColor whiteColor];
            
            [backgroundColor setFill];
            UIRectFill(CGRectMake(0, 0, kSize.width, kSize.height));
            
            [attributedString drawWithRect:CGRectMake(0, 0, kSize.width, kSize.height) options:NSStringDrawingUsesLineFragmentOrigin context:NULL];
            
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            
            UIImage *retval = [image MER_thumbnailOfSize:size];
#else
            NSImage *retval = [[NSImage alloc] initWithSize:size];
            
            [retval lockFocus];
            
            [attributedString drawAtPoint:NSZeroPoint];
            
            [retval unlockFocus];
#endif
            
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
#if (TARGET_OS_IPHONE)
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithFileURL:url options:@{NSDocumentTypeDocumentAttribute: NSPlainTextDocumentType,NSDefaultAttributesDocumentAttribute: @{NSForegroundColorAttributeName: [UIColor blackColor],NSBackgroundColorAttributeName: [UIColor whiteColor],NSFontAttributeName: [UIFont systemFontOfSize:17]}} documentAttributes:&attributes error:&outError];
#else
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithURL:url options:@{NSDocumentTypeDocumentAttribute: NSPlainTextDocumentType,NSDefaultAttributesDocumentOption: @{NSForegroundColorAttributeName: [NSColor blackColor],NSBackgroundColorAttributeName: [NSColor whiteColor],NSFontAttributeName: [NSFont systemFontOfSize:17]}} documentAttributes:&attributes error:&outError];
#endif
        
        if (attributedString) {
#if (TARGET_OS_IPHONE)
            CGSize const kSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
            
            UIGraphicsBeginImageContextWithOptions(kSize, YES, 0);
            
            UIColor *backgroundColor = ([attributedString attribute:NSBackgroundColorAttributeName atIndex:0 effectiveRange:NULL]) ?: [UIColor whiteColor];
            
            [backgroundColor setFill];
            UIRectFill(CGRectMake(0, 0, kSize.width, kSize.height));
            
            [attributedString drawWithRect:CGRectMake(0, 0, kSize.width, kSize.height) options:NSStringDrawingUsesLineFragmentOrigin context:NULL];
            
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            
            UIImage *retval = [image MER_thumbnailOfSize:size];
#else
            NSImage *retval = [[NSImage alloc] initWithSize:size];
            
            [retval lockFocus];
            
            [attributedString drawWithRect:NSMakeRect(0, 0, size.width, size.height) options:NSStringDrawingUsesLineFragmentOrigin];
            
            [retval unlockFocus];
#endif
            
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

#if (TARGET_OS_IPHONE)
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
#else
- (RACSignal *)_quickLookThumbnailForURL:(NSURL *)url size:(CGSize)size; {
    NSParameterAssert(url);
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        CGImageRef imageRef = QLThumbnailImageCreate(kCFAllocatorDefault, (__bridge CFURLRef)url, size, NULL);
        NSImage *retval = [[NSImage alloc] initWithCGImage:imageRef size:NSZeroSize];
        
        CGImageRelease(imageRef);
        
        [subscriber sendNext:RACTuplePack(url,retval,@(MERThumbnailManagerCacheTypeNone))];
        [subscriber sendCompleted];
        
        return nil;
    }];
}
#endif

- (RACSignal *)_remoteThumbnailForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time; {
    NSParameterAssert(url);
    // TODO: finish this!
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        __block NSMutableData *data = nil;
        __block BOOL supportedUTI = NO;
        __block NSString *uti = nil;
        RACDelegateProxy *proxy = [[RACDelegateProxy alloc] initWithProtocol:@protocol(NSURLConnectionDataDelegate)];
        
        [[proxy signalForSelector:@selector(connection:didFailWithError:)] subscribeNext:^(id x) {
            [subscriber sendNext:RACTuplePack(url,nil,@(MERThumbnailManagerCacheTypeNone))];
            [subscriber sendCompleted];
        }];
        
        [[proxy signalForSelector:@selector(connection:didReceiveResponse:)] subscribeNext:^(RACTuple *value) {
            RACTupleUnpack(NSURLConnection *connection, NSURLResponse *response) = value;
            
            uti = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)response.MIMEType, NULL);
            
            if (UTTypeConformsTo((__bridge CFStringRef)uti, kUTTypeImage) ||
                UTTypeConformsTo((__bridge CFStringRef)uti, kUTTypeMovie)) {
                
                supportedUTI = YES;
            }
            
            if (supportedUTI) {
                data = [[NSMutableData alloc] init];
            }
            else {
                [connection cancel];
            }
        }];
        
        [[proxy signalForSelector:@selector(connection:didReceiveData:)] subscribeNext:^(RACTuple *value) {
            [data appendData:value.second];
        }];
        
        [[proxy signalForSelector:@selector(connectionDidFinishLoading:)] subscribeNext:^(id _) {
            if (UTTypeConformsTo((__bridge CFStringRef)uti, kUTTypeImage)) {
                
            }
            else if (UTTypeConformsTo((__bridge CFStringRef)uti, kUTTypeMovie)) {
                
            }
        }];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url] delegate:proxy startImmediately:NO];
        
        [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [connection start];
        
        return [RACDisposable disposableWithBlock:^{
            [connection cancel];
        }];
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
                MERThumbnailKitImageClass *image = [[MERThumbnailKitImageClass alloc] initWithData:data];
                MERThumbnailKitImageClass *retval = [image MER_thumbnailOfSize:size];
                
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
#if (TARGET_OS_IPHONE)
                MERThumbnailKitImageClass *image = [[MERThumbnailKitImageClass alloc] initWithCGImage:imageRef];
#else
                MERThumbnailKitImageClass *image = [[MERThumbnailKitImageClass alloc] initWithCGImage:imageRef size:NSZeroSize];
#endif
                MERThumbnailKitImageClass *retval = [image MER_thumbnailOfSize:size];
                
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
