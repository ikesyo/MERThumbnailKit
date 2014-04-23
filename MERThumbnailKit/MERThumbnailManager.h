//
//  MERThumbnailManager.h
//  MERThumbnailKit
//
//  Created by William Towe on 4/23/14.
//  Copyright (c) 2014 Maestro, LLC. All rights reserved.
//

#import <UIKit/UIImage.h>

typedef NS_ENUM(NSInteger, MERThumbnailManagerCacheType) {
    MERThumbnailManagerCacheTypeNone,
    MERThumbnailManagerCacheTypeFile,
    MERThumbnailManagerCacheTypeMemory
};

typedef NS_OPTIONS(NSInteger, MERThumbnailManagerCacheOptions) {
    MERThumbnailManagerCacheOptionsNone = 0,
    MERThumbnailManagerCacheOptionsFile = 1 << 0,
    MERThumbnailManagerCacheOptionsMemory = 1 << 1,
    MERThumbnailManagerCacheOptionsAll = MERThumbnailManagerCacheOptionsFile | MERThumbnailManagerCacheOptionsMemory,
    MERThumbnailManagerCacheOptionsDefault = MERThumbnailManagerCacheOptionsAll
};

@class RACSignal;

@interface MERThumbnailManager : NSObject

@property (assign,nonatomic) MERThumbnailManagerCacheOptions cacheOptions;
@property (readonly,nonatomic,getter = isFileCachingEnabled) BOOL fileCachingEnabled;
@property (readonly,nonatomic,getter = isMemoryCachingEnabled) BOOL memoryCachingEnabled;

@property (readonly,strong,nonatomic) NSURL *fileCacheDirectoryURL;

@property (assign,nonatomic) CGSize thumbnailSize;
@property (assign,nonatomic) NSInteger thumbnailPage;
@property (assign,nonatomic) NSTimeInterval thumbnailTime;

+ (instancetype)sharedManager;

- (void)clearFileCache;
- (void)clearMemoryCache;

- (NSURL *)fileCacheURLForMemoryCacheKey:(NSString *)key;
- (NSString *)memoryCacheKeyForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time;

- (RACSignal *)thumbnailForURL:(NSURL *)url;
- (RACSignal *)thumbnailForURL:(NSURL *)url size:(CGSize)size;
- (RACSignal *)thumbnailForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page;
- (RACSignal *)thumbnailForURL:(NSURL *)url size:(CGSize)size time:(NSTimeInterval)time;
- (RACSignal *)thumbnailForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time;

@end
