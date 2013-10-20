//
//  UIImageView+METKExtensions.h
//  METhumbnailKit
//
//  Created by William Towe on 10/17/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (METKExtensions)

/**
 Calls `METK_setImageForThumbnailFromURL:size:page:time:placeholder:`, passing _url_, `self.bounds.size`, `[METhumbnailManager sharedManager].thumbnailPage`, `[METhumbnailManager sharedManager].thumbnailTime` and `nil` respectively.
 
 @see METK_setImageForThumbnailFromURL:size:page:time:placeholder:
 */
- (void)METK_setImageForThumbnailFromURL:(NSURL *)url;
/**
 Calls `METK_setImageForThumbnailFromURL:size:page:time:placeholder:`, passing _url_, `self.bounds.size`, `[METhumbnailManager sharedManager].thumbnailPage`, `[METhumbnailManager sharedManager].thumbnailTime` and _placeholder_ respectively.
 
 @see METK_setImageForThumbnailFromURL:size:page:time:placeholder:
 */
- (void)METK_setImageForThumbnailFromURL:(NSURL *)url placeholder:(UIImage *)placeholder;
/**
 Calls `METK_setImageForThumbnailFromURL:size:page:time:placeholder:`, passing _url_, `self.bounds.size`, _page_, `[METhumbnailManager sharedManager].thumbnailTime` and _placeholder_ respectively.
 
 @see METK_setImageForThumbnailFromURL:size:page:time:placeholder:
 */
- (void)METK_setImageForThumbnailFromURL:(NSURL *)url page:(NSInteger)page placeholder:(UIImage *)placeholder;
/**
 Calls `METK_setImageForThumbnailFromURL:size:page:time:placeholder:`, passing _url_, `self.bounds.size`, `[METhumbnailManager sharedManager].thumbnailPage`, _time_ and _placeholder_ respectively.
 
 @see METK_setImageForThumbnailFromURL:size:page:time:placeholder:
 */
- (void)METK_setImageForThumbnailFromURL:(NSURL *)url time:(NSTimeInterval)time placeholder:(UIImage *)placeholder;

/**
 Calls `METK_setImageForThumbnailFromURL:size:page:time:placeholder:`, passing _url_, _size_, `[METhumbnailManager sharedManager].thumbnailPage`, `[METhumbnailManager sharedManager].thumbnailTime` and _placeholder_ respectively.
 
 @see METK_setImageForThumbnailFromURL:size:page:time:placeholder:
 */
- (void)METK_setImageForThumbnailFromURL:(NSURL *)url size:(CGSize)size placeholder:(UIImage *)placeholder;
/**
 Calls `METK_setImageForThumbnailFromURL:size:page:time:placeholder:`, passing _url_, _size_, `[METhumbnailManager sharedManager].thumbnailPage`, `[METhumbnailManager sharedManager].thumbnailTime` and _placeholder_ respectively.
 
 @see METK_setImageForThumbnailFromURL:size:page:time:placeholder:
 */
- (void)METK_setImageForThumbnailFromURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page placeholder:(UIImage *)placeholder;
/**
 Calls `METK_setImageForThumbnailFromURL:size:page:time:placeholder:`, passing _url_, _size_, `[METhumbnailManager sharedManager].thumbnailPage`, _time_ and _placeholder_ respectively.
 
 @see METK_setImageForThumbnailFromURL:size:page:time:placeholder:
 */
- (void)METK_setImageForThumbnailFromURL:(NSURL *)url size:(CGSize)size time:(NSTimeInterval)time placeholder:(UIImage *)placeholder;

/**
 Clears any existing thumbnail operation before adding a new one via `addThumbnailOperationForURL:size:page:time:completion:`. Sets the resulting thumbnail as the receiver's `image` property if non-nil, otherwise sets the provided _placeholder_ as the receiver's `image` property.
 
 @param url The url of the file for which to request a thumbnail
 @param size The size of the thumbnail
 @param page The page of the thumbnail
 @param time The time of the thumbnail
 @param placeholder The image to use until the thumbnail operation completes or if the resulting thumbnail is nil
 */
- (void)METK_setImageForThumbnailFromURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time placeholder:(UIImage *)placeholder;

@end
