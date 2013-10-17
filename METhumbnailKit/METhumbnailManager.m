//
//  METhumbnailManager.m
//  METhumbnailKit
//
//  Created by William Towe on 10/16/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import "METhumbnailManager.h"
#import "MEImageThumbnailOperation.h"

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

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
    
    NSURL *cachesDirectoryURL = [[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask].lastObject;
    NSURL *fileCacheDirectoryURL = [cachesDirectoryURL URLByAppendingPathComponent:@"com.maestro.methumbnailkit.cache" isDirectory:YES];
    
    if (![fileCacheDirectoryURL checkResourceIsReachableAndReturnError:NULL]) {
        NSError *outError;
        if (![[NSFileManager defaultManager] createDirectoryAtURL:fileCacheDirectoryURL withIntermediateDirectories:YES attributes:nil error:&outError])
            NSLog(@"%@",outError);
    }
    
    [self setFileCacheDirectoryURL:fileCacheDirectoryURL];
    
    return self;
}

- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    NSLog(@"%@ %@",cache,obj);
}

- (void)clearFileCache; {
    [self.memoryCache removeAllObjects];
}
- (void)clearMemoryCache; {
    [[NSFileManager defaultManager] removeItemAtURL:self.fileCacheDirectoryURL error:NULL];
}

- (NSURL *)fileCacheURLForMemoryCacheKey:(NSString *)key; {
    return [self.fileCacheDirectoryURL URLByAppendingPathComponent:key isDirectory:NO];
}
- (NSString *)memoryCacheKeyForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time; {
    return [[NSString stringWithFormat:@"%@%@%@%@",url.lastPathComponent.stringByDeletingPathExtension,NSStringFromCGSize(size),@(page),@(time)] stringByAppendingPathExtension:url.lastPathComponent.pathExtension];
}

- (void)cancelAllThumbnailOperations; {
    [self.operationQueue cancelAllOperations];
}

- (NSOperation<METhumbnailOperation> *)addThumbnailOperationForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time completion:(METhumbnailManagerCompletionBlock)completion; {
    NSString *key = [self memoryCacheKeyForURL:url size:size page:page time:time];
    UIImage *memoryImage = [self.memoryCache objectForKey:key];
    
    if (memoryImage) {
        completion(url,memoryImage,METhumbnailManagerCacheTypeMemory);
        
        return nil;
    }
    
    NSURL *fileCacheURL = [self fileCacheURLForMemoryCacheKey:key];
    UIImage *fileImage = [UIImage imageWithContentsOfFile:fileCacheURL.path];
    
    if (fileImage) {
        [self.memoryCache setObject:fileImage forKey:key cost:(fileImage.size.width * fileImage.size.height * fileImage.scale)];
        
        completion(url,fileImage,METhumbnailManagerCacheTypeFile);
         
        return nil;
    }
    
    NSString *uti = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)url.lastPathComponent.pathExtension, NULL);

    if (UTTypeConformsTo((__bridge CFStringRef)uti, kUTTypeImage)) {
        MEImageThumbnailOperation *operation = [[MEImageThumbnailOperation alloc] initWithURL:url size:size completion:^(NSURL *url, UIImage *image) {
            dispatch_async(self.fileCacheQueue, ^{
                NSData *data = UIImageJPEGRepresentation(image, 1.0);
                
                [data writeToURL:fileCacheURL options:NSDataWritingAtomic error:NULL];
            });
            
            [self.memoryCache setObject:image forKey:key cost:(image.size.width * image.size.height * image.scale)];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completion(url,image,METhumbnailManagerCacheTypeNone);
            }];
        }];
        
        [self.operationQueue addOperation:operation];
        
        return operation;
    }
    return nil;
}

- (void)_applicationDidReceiveMemoryWarning:(NSNotification *)note {
    [self.memoryCache removeAllObjects];
}

@end
