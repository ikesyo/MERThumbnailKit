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

typedef NS_OPTIONS(NSInteger, METhumbnailManagerCacheOptions) {
    METhumbnailManagerCacheOptionNone = 0,
    METhumbnailManagerCacheOptionFile = 1 << 0,
    METhumbnailManagerCacheOptionMemory = 1 << 1,
    METhumbnailManagerCacheOptionAll = METhumbnailManagerCacheOptionFile|METhumbnailManagerCacheOptionMemory,
    METhumbnailManagerCacheOptionDefault = METhumbnailManagerCacheOptionAll
};

typedef void(^METhumbnailManagerCompletionBlock)(NSURL *url,UIImage *image,METhumbnailManagerCacheType cacheType);

@interface METhumbnailManager : NSObject

+ (instancetype)sharedManager;

@property (assign,nonatomic) METhumbnailManagerCacheOptions cacheOptions;
@property (readonly,nonatomic,getter = isFileCachingEnabled) BOOL fileCachingEnabled;
@property (readonly,nonatomic,getter = isMemoryCachingEnabled) BOOL memoryCachingEnabled;

@property (readonly,strong,nonatomic) NSURL *fileCacheDirectoryURL;

- (void)clearFileCache;
- (void)clearMemoryCache;

- (NSURL *)fileCacheURLForMemoryCacheKey:(NSString *)key;
- (NSString *)memoryCacheKeyForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time;

- (void)cancelAllThumbnailOperations;

- (NSOperation<METhumbnailOperation> *)addThumbnailOperationForURL:(NSURL *)url size:(CGSize)size completion:(METhumbnailManagerCompletionBlock)completion;
- (NSOperation<METhumbnailOperation> *)addThumbnailOperationForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page completion:(METhumbnailManagerCompletionBlock)completion;
- (NSOperation<METhumbnailOperation> *)addThumbnailOperationForURL:(NSURL *)url size:(CGSize)size time:(NSTimeInterval)time completion:(METhumbnailManagerCompletionBlock)completion;
- (NSOperation<METhumbnailOperation> *)addThumbnailOperationForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time completion:(METhumbnailManagerCompletionBlock)completion;

@end
