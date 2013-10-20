//
//  METhumbnailManager.h
//  METhumbnailKit
//
//  Created by William Towe on 10/16/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "METhumbnailOperation.h"

/**
 `METhumbnailManagerCacheType` describes the cache that the thumbnail was retrieved from.
 
 - `METhumbnailManagerCacheTypeNone`, the thumbnail was just created and not retrieved from any cache
 - `METhumbnailManagerCacheTypeFile`, the thumbnail was retrieved from the file cache
 - `METhumbnailManagerCacheTypeMemory`, the thumbnail was retrieved from the memory cache
 */
typedef NS_ENUM(NSInteger, METhumbnailManagerCacheType) {
    METhumbnailManagerCacheTypeNone,
    METhumbnailManagerCacheTypeFile,
    METhumbnailManagerCacheTypeMemory
};

/**
 `METhumbnailManagerCacheOptions` describes the caching options that can be applied after a thumbnail is created.
 
 - `METhumbnailManagerCacheOptionNone`, no caching is performed; the thumbnail will be recreated each time it is requested
 - `METhumbnailManagerCacheOptionFile`, the thumbnail will be written out to a file within the "Caches" directory
 - `METhumbnailManagerCacheOptionMemory`, the thumbnail will be stored in an instance of `NSCache` in memory
 - `METhumbnailManagerCacheOptionAll`, all the available caching mechanisms will apply
 - `METhumbnailManagerCacheOptionDefault`, currently equal to `METhumbnailManagerCacheOptionAll`
 */
typedef NS_OPTIONS(NSInteger, METhumbnailManagerCacheOptions) {
    METhumbnailManagerCacheOptionNone = 0,
    METhumbnailManagerCacheOptionFile = 1 << 0,
    METhumbnailManagerCacheOptionMemory = 1 << 1,
    METhumbnailManagerCacheOptionAll = METhumbnailManagerCacheOptionFile|METhumbnailManagerCacheOptionMemory,
    METhumbnailManagerCacheOptionDefault = METhumbnailManagerCacheOptionAll
};

/**
 `METhumbnailManagerCompletionBlock` corresponds to the completion block that is called when a thumbnail operation completes.
 
 @param url The url of the file for which the thumbnail was requested
 @param image The thumbnail image, or nil or none could be created
 @param cacheType The cache from where the thumbnail image was retrieved
 @see METhumbnailManagerCacheType
 */
typedef void(^METhumbnailManagerCompletionBlock)(NSURL *url,UIImage *image,METhumbnailManagerCacheType cacheType);

/**
 `METhumbnailManagerDefaultThumbnailSize` is the default thumbnail size used when a method does not provide a size parameter.
 
 The default is `CGSizeMake(175,175)`.
 */
extern CGSize const METhumbnailManagerDefaultThumbnailSize;
/**
 `METhumbnailManagerDefaultThumbnailPage` is the default thumbnail page used when a method does not provide a page parameter.
 
 The default is 0.
 */
extern NSInteger const METhumbnailManagerDefaultThumbnailPage;
/**
 `METhumbnailManagerDefaultThumbnailTime` is the default thumbnail time used when a method does not provide a time parameter.
 
 The default is 1.0.
 */
extern NSTimeInterval const METhumbnailManagerDefaultThumbnailTime;

/**
 `METhumbnailManager` creates and manages `NSOperation` subclasses that conform the the `METhumbnailOperation` protocol.
 
 A client should either create and hold onto a single instance of `METhumbnailManager` or used the `sharedManager` instance.
 */
@interface METhumbnailManager : NSObject

/**
 The shared instance of the receiver.
 
 @return The shared instance
 */
+ (instancetype)sharedManager;

/**
 Returns the current cache options used by the receiver.
 
 When setting these options, the constants within `METhumbnailManagerCacheOptions` should be used.
 */
@property (assign,nonatomic) METhumbnailManagerCacheOptions cacheOptions;
/**
 Returns whether file caching is enabled.
 */
@property (readonly,nonatomic,getter = isFileCachingEnabled) BOOL fileCachingEnabled;
/**
 Returns whether memory caching is enabled.
 */
@property (readonly,nonatomic,getter = isMemoryCachingEnabled) BOOL memoryCachingEnabled;

/**
 Returns the url of the directory used for file caching.
 */
@property (readonly,strong,nonatomic) NSURL *fileCacheDirectoryURL;

/**
 Clears the file cache.
 
 This method is synchronous and removes the entire directory located at the return value from `fileCacheDirectoryURL`.
 */
- (void)clearFileCache;
/**
 Clears the memory cache.
 
 This method is synchronous, but because of the implementation of the underlying `NSCache`, some values may not be removed from the instance immediately.
 */
- (void)clearMemoryCache;

/**
 Creates and returns the file cache url for the provided memory cache key.
 
 @param key The memory cache key for which to create and return a file cache url
 @return The file cache url for the provided memory cache key
 @exception NSException Thrown if _key_ is nil
 */
- (NSURL *)fileCacheURLForMemoryCacheKey:(NSString *)key;
/**
 Creates and returns the memory cache key for the provided _url_, _size_, _page_ and _time_.
 
 @param url The url of the file
 @param size The size of the thumbnail
 @param page The page of the thumbnail
 @param time The time of the thumbnail
 @return The memory cache key for the provided url, size, page and time
 @exception NSException Thrown if _url_ is nil
 */
- (NSString *)memoryCacheKeyForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time;

/**
 Returns the thumbnail size that is used when a method does not a size parameter.
 
 The default is `METhumbnailManagerDefaultThumbnailSize`.
 
 @see METhumbnailManagerDefaultThumbnailSize
 */
@property (assign,nonatomic) CGSize thumbnailSize;
/**
 Returns the thumbnail page that is used when a method does not provide a page parameter.
 
 The default is `METhumbnailManagerDefaultThumbnailPage`.
 
 @see METhumbnailManagerDefaultThumbnailPage
 */
@property (assign,nonatomic) NSInteger thumbnailPage;
/**
 Returns the thumbnail time that is used when a method does not provide a time parameter.
 
 The default is `METhumbnailManagerDefaultThumbnailTime`.
 
 @see METhumbnailManagerDefaultThumbnailTime
 */
@property (assign,nonatomic) NSTimeInterval thumbnailTime;

/**
 Cancels all pending thumbnail operations.
 
 The calls `cancelAllOperations` on the `NSOperationQueue` managed by the receiver.
 */
- (void)cancelAllThumbnailOperations;

/**
 Calls `addThumbnailOperationForURL:size:page:time:completion:`, passing _url_, `self.thumbnailSize`, `self.thumbnailPage` and `self.thumbnailTime` respectively.
 
 @see addThumbnailOperationForURL:size:page:time:completion:
 */
- (NSOperation<METhumbnailOperation> *)addThumbnailOperationForURL:(NSURL *)url completion:(METhumbnailManagerCompletionBlock)completion;
/**
 Calls `addThumbnailOperationForURL:size:page:time:completion:`, passing _url_, _size_, `self.thumbnailPage` and `self.thumbnailTime` respectively.
 
 @see addThumbnailOperationForURL:size:page:time:completion:
 */
- (NSOperation<METhumbnailOperation> *)addThumbnailOperationForURL:(NSURL *)url size:(CGSize)size completion:(METhumbnailManagerCompletionBlock)completion;
/**
 Calls `addThumbnailOperationForURL:size:page:time:completion:`, passing _url_, _size_, _page_ and `self.thumbnailTime` respectively.
 
 @see addThumbnailOperationForURL:size:page:time:completion:
 */
- (NSOperation<METhumbnailOperation> *)addThumbnailOperationForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page completion:(METhumbnailManagerCompletionBlock)completion;
/**
 Calls `addThumbnailOperationForURL:size:page:time:completion:`, passing _url_, _size_, `self.thumbnailPage` and _time_ respectively.
 
 @see addThumbnailOperationForURL:size:page:time:completion:
 */
- (NSOperation<METhumbnailOperation> *)addThumbnailOperationForURL:(NSURL *)url size:(CGSize)size time:(NSTimeInterval)time completion:(METhumbnailManagerCompletionBlock)completion;
/**
 Creates and adds the operation to the `NSOperationQueue` managed by receiver, then returns it.
 
 @param url The url of the file for which the thumbnail should be created
 @param size The size of the thumbnail
 @param page The page from which to create the thumbnail
 @param time The time from which to create the thumbnail
 @param completion The completion block that is invoked when the operation is finished
 @warning *NOTE:* If _url_ is nil, this method immediately calls the completion handler passing `nil`, `nil` and `METhumbnailManagerCacheTypeNone` respectively
 */
- (NSOperation<METhumbnailOperation> *)addThumbnailOperationForURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time completion:(METhumbnailManagerCompletionBlock)completion;

@end
