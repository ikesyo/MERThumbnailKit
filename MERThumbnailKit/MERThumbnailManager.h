//
//  MERThumbnailManager.h
//  MERThumbnailKit
//
//  Created by William Towe on 5/1/14.
//  Copyright (c) 2014 Maestro, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

/**
 Enum that describes the cache type that was used, if any, when generating a thumbnail.
 
 - `MERThumbnailManagerCacheTypeNone`, no cache was used
 - `MERThumbnailManagerCacheTypeFile`, the file cache was used
 - `MERThumbnailManagerCacheTypeMemory`, the memory cache was used
 */
typedef NS_ENUM(NSInteger, MERThumbnailManagerCacheType) {
    MERThumbnailManagerCacheTypeNone,
    MERThumbnailManagerCacheTypeFile,
    MERThumbnailManagerCacheTypeMemory
};

/**
 Mask that describes the cache options used when storing a generated thumbnail.
 
 - `MERThumbnailManagerCacheOptionsNone`, thumbnails are never cached
 - `MERThumbnailManagerCacheOptionsFile`, thumbnails are cached on disk
 - `MERThumbnailManagerCacheOptionsMemory`, thumbnails are cached in memory
 - `MERThumbnailManagerCacheOptionsAll`, thumbnails are cached on disk and in memory
 - `MERThumbnailManagerCacheOptionsDefault`, the default caching options
 */
typedef NS_OPTIONS(NSInteger, MERThumbnailManagerCacheOptions) {
    MERThumbnailManagerCacheOptionsNone = 0,
    MERThumbnailManagerCacheOptionsFile = 1 << 0,
    MERThumbnailManagerCacheOptionsMemory = 1 << 1,
    MERThumbnailManagerCacheOptionsAll = MERThumbnailManagerCacheOptionsFile | MERThumbnailManagerCacheOptionsMemory,
    MERThumbnailManagerCacheOptionsDefault = MERThumbnailManagerCacheOptionsAll
};

typedef void(^MERThumbnailManagerDownloadCompletionBlock)(NSData *data, MERThumbnailManagerCacheType cacheType, NSError *error);

@class RACSignal;

/**
 `MERThumbnailManager` is a class for generating thumbnails from urls, both local and remote. The `thumbnailForURL:size:page:time:` method and its variants return a signal that sends `next` with a thumbnail for the provided url, then `completes`. If the thumbnail cannot be generated, which may happen if the url is remote, sends `error`.
 */
@interface MERThumbnailManager : NSObject

/**
 Returns the cache options assigned to the receiver.
 
 @see MERThumbnailManagerCacheOptions
 */
@property (assign,nonatomic) MERThumbnailManagerCacheOptions cacheOptions;
/**
 Returns whether the receiver has file caching enabled.
 
 @see MERThumbnailManagerCacheOptionsFile
 */
@property (readonly,nonatomic,getter = isFileCachingEnabled) BOOL fileCachingEnabled;
/**
 Returns whether the receiver has memory caching enabled.
 
 @see MERThumbnailManagerCacheOptionsMemory
 */
@property (readonly,nonatomic,getter = isMemoryCachingEnabled) BOOL memoryCachingEnabled;

/**
 Returns the directory url used for file caching.
 */
@property (readonly,strong,nonatomic) NSURL *fileCacheDirectoryURL;

/**
 Return the thumbnail size assigned to the receiver. This size is used for any method that does not contain an explicit _size_ parameter.
 
 The default is `CGSizeMake(175, 175)`.
 */
@property (assign,nonatomic) CGSize thumbnailSize;
/**
 Return the thumbnail page assigned to the receiver. This page is used for any method that does not contain an explicit _page_ parameter and is only used for UTIs conforming to `kUTTypePDF`.
 
 The default is 1.
 */
@property (assign,nonatomic) NSInteger thumbnailPage;
/**
 Return the thumbnail time assigned to the receiver. This time is used for any method that does not contain an explicit _time_ parameter and is only used for UTIs conforming to `kUTTypeMovie`.
 
 The default is 1.0.
 */
@property (assign,nonatomic) NSTimeInterval thumbnailTime;

/**
 Returns the shared manager instance.
 
 You can also create your own instance using `[[MERThumbnailManager alloc] init]`.
 */
+ (instancetype)sharedManager;

/**
 Clears the thumbnail file cache.
 */
- (void)clearThumbnailFileCache;
/**
 Clears the thumbnail memory cache.
 */
- (void)clearThumbnailMemoryCache;

/**
 Returns the file cache url for the provided memory cache _key_.
 
 @param key The memory cache key
 @return The file cache url for _key_
 @exception NSException Thrown if _key_ is nil
 */
- (NSURL *)thumbnailFileCacheURLForMemoryCacheKey:(NSString *)key;
/**
 Returns the memory cache key for the provided _url_, _size_, _page_, and _time_.
 
 @param url The url of the asset
 @param size The size of the thumbnail
 @param page The page of the thumbnail
 @param time The time of the thumbnail
 @return The memory cache key for the provided _url_, _size_, _page_, and _time_
 @exception NSException Thrown if _url_ is nil
 */
- (NSString *)memoryCacheKeyForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time;

/**
 Calls `thumbnailForURL:size:page:time:`, passing _url_, `thumbnailSize`, `thumbnailPage`, and `thumbnailTime` respectively.
 
 @param url The url of the asset
 @return The signal
 @exception NSException Thrown if _url_ is nil
 @see thumbnailForURL:size:page:time:
 */
- (RACSignal *)thumbnailForURL:(NSURL *)url;
/**
 Calls `thumbnailForURL:size:page:time:`, passing _url_, _size_, `thumbnailPage`, and `thumbnailTime` respectively.
 
 @param url The url of the asset
 @param size The size of the thumbnail
 @return The signal
 @exception NSException Thrown if _url_ is nil
 @see thumbnailForURL:size:page:time:
 */
- (RACSignal *)thumbnailForURL:(NSURL *)url size:(CGSize)size;
/**
 Calls `thumbnailForURL:size:page:time:`, passing _url_, _url_, _page_, and `thumbnailTime` respectively.
 
 @param url The url of the asset
 @param size The size of the thumbnail
 @param page The page of the thumbnail
 @return The signal
 @exception NSException Thrown if _url_ is nil
 @see thumbnailForURL:size:page:time:
 */
- (RACSignal *)thumbnailForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page;
/**
 Calls `thumbnailForURL:size:page:time:`, passing _url_, _size_, `thumbnailPage`, and _time_ respectively.
 
 @param url The url of the asset
 @param size The size of the thumbnail
 @param time The time of the thumbnail
 @return The signal
 @exception NSException Thrown if _url_ is nil
 @see thumbnailForURL:size:page:time:
 */
- (RACSignal *)thumbnailForURL:(NSURL *)url size:(CGSize)size time:(NSTimeInterval)time;
/**
 Returns a signal that sends `next` with a `RACTuple` containing _url_, the thumbnail image, and the `MERThumbnailManagerCacheType` of the generated thumbnail, then `completes`. If the request cannot be completed, which is possible for remote urls, sends `error`.
 
 @param url The url of the asset
 @param size The size of the thumbnail
 @param page The page of the thumbnail
 @param time The time of the thumbnail
 @return The signal
 @exception NSException Thrown if _url_ is nil
 */
- (RACSignal *)thumbnailForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time;
/**
 Returns a signal that sends `next` with a `RACTuple` containing _url_, the thumbnail image, and the `MERThumbnailManagerCacheType` of the generated thumbnail, then `completes`. If the request cannot be completed, which is possible for remote urls, sends `error`.
 
 @param url The url of the asset
 @param size The size of the thumbnail
 @param page The page of the thumbnail
 @param time The time of the thumbnail
 @param downloadCompletion The block that is invoked when the full asset has finished downloading. If this parameter is nil, the library will attempt to generate the thumbnail without downloading the entire asset. The block takes three parameters, the _data_ of the downloaded asset, the `MERThumbnailManagerCacheType` of the downloaded asset, and an _error_ if the download could not be completed
 @return The signal
 @exception NSException Thrown if _url_ is nil
 */
- (RACSignal *)thumbnailForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time downloadCompletion:(MERThumbnailManagerDownloadCompletionBlock)downloadCompletion;

@end
