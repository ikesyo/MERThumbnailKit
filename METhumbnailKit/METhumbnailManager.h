//
//  METhumbnailManager.h
//  METhumbnailKit
//
//  Created by William Towe on 10/16/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "METhumbnailOperation.h"

typedef NS_ENUM(NSInteger, METhumbnailManagerCacheType) {
    METhumbnailManagerCacheTypeNone,
    METhumbnailManagerCacheTypeFile,
    METhumbnailManagerCacheTypeMemory
};

typedef void(^METhumbnailManagerCompletionBlock)(NSURL *url,UIImage *image,METhumbnailManagerCacheType cacheType);

@interface METhumbnailManager : NSObject

+ (instancetype)sharedManager;

@property (readonly,strong,nonatomic) NSURL *fileCacheDirectoryURL;

- (void)clearFileCache;
- (void)clearMemoryCache;

- (NSURL *)fileCacheURLForMemoryCacheKey:(NSString *)key;
- (NSString *)memoryCacheKeyForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time;

- (void)cancelAllThumbnailOperations;

- (NSOperation<METhumbnailOperation> *)addThumbnailOperationForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page completion:(METhumbnailManagerCompletionBlock)completion;
- (NSOperation<METhumbnailOperation> *)addThumbnailOperationForURL:(NSURL *)url size:(CGSize)size time:(NSTimeInterval)time completion:(METhumbnailManagerCompletionBlock)completion;
- (NSOperation<METhumbnailOperation> *)addThumbnailOperationForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time completion:(METhumbnailManagerCompletionBlock)completion;

@end
