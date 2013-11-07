//
//  METhumbnailManager.m
//  METhumbnailKit
//
//  Created by William Towe on 10/16/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import "METhumbnailManager.h"
#import "MEImageThumbnailOperation.h"
#import "MEMovieThumbnailOperation.h"
#import "MEPDFThumbnailOperation.h"
#import "MEWebViewThumbnailOperation.h"
#import "MERTFThumbnailOperation.h"
#import "METextThumbnailOperation.h"
#import <MEFoundation/MEDebugging.h>

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

CGSize const METhumbnailManagerDefaultThumbnailSize = {.width=175, .height=175};
NSInteger const METhumbnailManagerDefaultThumbnailPage = 0;
NSTimeInterval const METhumbnailManagerDefaultThumbnailTime = 1.0;

@interface METhumbnailManager () <NSCacheDelegate>
@property (readwrite,strong,nonatomic) NSURL *fileCacheDirectoryURL;

@property (strong,nonatomic) NSOperationQueue *operationQueue;
@property (strong,nonatomic) NSCache *memoryCache;
@property (strong,nonatomic) dispatch_queue_t fileCacheQueue;
@end

@implementation METhumbnailManager

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init {
    if (!(self = [super init]))
        return nil;
    
    [self setOperationQueue:[[NSOperationQueue alloc] init]];
    [self.operationQueue setName:[NSString stringWithFormat:@"com.maestro.methumbnailkit.%p",self]];
    [self.operationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    
    [self setMemoryCache:[[NSCache alloc] init]];
    [self.memoryCache setName:[NSString stringWithFormat:@"com.maestro.methumbnailkit.%p",self]];
    [self.memoryCache setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
    [self setFileCacheQueue:dispatch_queue_create([NSString stringWithFormat:@"com.maestro.methumbnailkit.%p",self].UTF8String, DISPATCH_QUEUE_SERIAL)];
    
    [self setCacheOptions:METhumbnailManagerCacheOptionDefault];
    
    NSURL *cachesDirectoryURL = [[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask].lastObject;
    NSURL *fileCacheDirectoryURL = [cachesDirectoryURL URLByAppendingPathComponent:@"com.maestro.methumbnailkit.cache" isDirectory:YES];
    
    if (![fileCacheDirectoryURL checkResourceIsReachableAndReturnError:NULL]) {
        NSError *outError;
        if (![[NSFileManager defaultManager] createDirectoryAtURL:fileCacheDirectoryURL withIntermediateDirectories:YES attributes:nil error:&outError])
            MELogObject(outError);
    }
    
    [self setFileCacheDirectoryURL:fileCacheDirectoryURL];
    
    [self setThumbnailSize:METhumbnailManagerDefaultThumbnailSize];
    [self setThumbnailPage:METhumbnailManagerDefaultThumbnailPage];
    [self setThumbnailTime:METhumbnailManagerDefaultThumbnailTime];
    
    return self;
}

- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    MELog(@"%@ %@ %p",cache,[obj class],obj);
}

+ (instancetype)sharedManager; {
    static METhumbnailManager *retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[METhumbnailManager alloc] init];
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

- (void)cancelAllThumbnailOperations; {
    [self.operationQueue cancelAllOperations];
}

- (NSOperation<METhumbnailOperation> *)addThumbnailOperationForURL:(NSURL *)url completion:(METhumbnailManagerCompletionBlock)completion; {
    return [self addThumbnailOperationForURL:url size:self.thumbnailSize page:self.thumbnailPage time:self.thumbnailTime completion:completion];
}
- (NSOperation<METhumbnailOperation> *)addThumbnailOperationForURL:(NSURL *)url size:(CGSize)size completion:(METhumbnailManagerCompletionBlock)completion; {
    return [self addThumbnailOperationForURL:url size:size page:self.thumbnailPage time:self.thumbnailTime completion:completion];
}
- (NSOperation<METhumbnailOperation> *)addThumbnailOperationForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page completion:(METhumbnailManagerCompletionBlock)completion; {
    return [self addThumbnailOperationForURL:url size:size page:page time:self.thumbnailTime completion:completion];
}
- (NSOperation<METhumbnailOperation> *)addThumbnailOperationForURL:(NSURL *)url size:(CGSize)size time:(NSTimeInterval)time completion:(METhumbnailManagerCompletionBlock)completion; {
    return [self addThumbnailOperationForURL:url size:size page:self.thumbnailPage time:time completion:completion];
}
- (NSOperation<METhumbnailOperation> *)addThumbnailOperationForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time completion:(METhumbnailManagerCompletionBlock)completion; {
    if (!url) {
        completion(nil,nil,METhumbnailManagerCacheTypeNone);
        return nil;
    }
    
    NSString *key = [self memoryCacheKeyForURL:url size:size page:page time:time];
    NSPurgeableData *memoryData = [self.memoryCache objectForKey:key];
    
    if (memoryData && [memoryData beginContentAccess]) {
        UIImage *memoryImage = [UIImage imageWithData:memoryData];
        
        [memoryData endContentAccess];
        
        completion(url,memoryImage,METhumbnailManagerCacheTypeMemory);
        
        return nil;
    }
    
    NSURL *fileCacheURL = [self fileCacheURLForMemoryCacheKey:key];
    UIImage *fileImage = [UIImage imageWithContentsOfFile:fileCacheURL.path];
    
    if (fileImage) {
        if (self.isMemoryCachingEnabled && fileImage) {
            NSPurgeableData *purgeableData = [NSPurgeableData dataWithData:UIImageJPEGRepresentation(fileImage, 1.0)];
            
            [self.memoryCache setObject:purgeableData forKey:key cost:purgeableData.length];
        }
        
        completion(url,fileImage,METhumbnailManagerCacheTypeFile);
         
        return nil;
    }
    
    NSString *uti = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)url.lastPathComponent.pathExtension, NULL);
    NSOperation<METhumbnailOperation> *operation = nil;
    Class operationClass = Nil;
    
    if (UTTypeConformsTo((__bridge CFStringRef)uti, kUTTypeImage))
        operationClass = [MEImageThumbnailOperation class];
    else if (UTTypeConformsTo((__bridge CFStringRef)uti, kUTTypeMovie))
        operationClass = [MEMovieThumbnailOperation class];
    else if (UTTypeConformsTo((__bridge CFStringRef)uti, kUTTypePDF))
        operationClass = [MEPDFThumbnailOperation class];
    else if (UTTypeConformsTo((__bridge CFStringRef)uti, kUTTypeRTF) ||
             UTTypeConformsTo((__bridge CFStringRef)uti, kUTTypeRTFD))
        operationClass = [MERTFThumbnailOperation class];
    else if (UTTypeConformsTo((__bridge CFStringRef)uti, kUTTypePlainText))
        operationClass = [METextThumbnailOperation class];
    else if (UTTypeConformsTo((__bridge CFStringRef)uti, kUTTypeHTML))
        operationClass = [MEWebViewThumbnailOperation class];
    else if ([[NSSet setWithArray:@[@"doc",@"docx",@"ppt",@"pptx",@"xls",@"xlsx"]] containsObject:url.lastPathComponent.pathExtension.lowercaseString])
        operationClass = [MEWebViewThumbnailOperation class];
    else {
        MELog(@"unsupported uti %@ for url %@",uti,url);
    }
    
    if (operationClass) {
        operation = [[operationClass alloc] initWithURL:url size:size page:page time:time completion:^(NSURL *url, UIImage *image) {
            NSData *data = UIImageJPEGRepresentation(image, 1.0);
            
            if (self.isFileCachingEnabled && image) {
                dispatch_async(self.fileCacheQueue, ^{
                    [data writeToURL:fileCacheURL options:NSDataWritingAtomic error:NULL];
                });
            }
            
            if (self.isMemoryCachingEnabled && image) {
                NSPurgeableData *purgeableData = [NSPurgeableData dataWithData:data];
                
                [self.memoryCache setObject:purgeableData forKey:key cost:purgeableData.length];
            }
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completion(url,image,METhumbnailManagerCacheTypeNone);
            }];
        }];
        
        [self.operationQueue addOperation:operation];
    }
    return operation;
}

- (BOOL)isFileCachingEnabled {
    return ((self.cacheOptions & METhumbnailManagerCacheOptionFile) != 0);
}
- (BOOL)isMemoryCachingEnabled {
    return ((self.cacheOptions & METhumbnailManagerCacheOptionMemory) != 0);
}

- (void)setThumbnailSize:(CGSize)thumbnailSize {
    _thumbnailSize = (CGSizeEqualToSize(CGSizeZero, thumbnailSize)) ? METhumbnailManagerDefaultThumbnailSize : thumbnailSize;
}

- (void)_applicationDidReceiveMemoryWarning:(NSNotification *)note {
    [self.memoryCache removeAllObjects];
}

@end
