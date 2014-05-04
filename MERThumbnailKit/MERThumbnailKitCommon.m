//
//  MERThumbnailKitCommon.m
//  MERThumbnailKit
//
//  Created by William Towe on 5/4/14.
//  Copyright (c) 2014 Maestro, LLC. All rights reserved.
//

#import "MERThumbnailKitCommon.h"
#import <MEFoundation/MEFoundation.h>

NSString *const MERThumbnailKitBundleIdentifier = @"com.maestro.merthumbnailkit";
NSString *const MERThumbnailKitThumbnailsDirectoryName = @"thumbnails";
NSString *const MERThumbnailKitDownloadsDirectoryName = @"downloads";

const struct MERThumbnailKitVersion MERThumbnailKitVersion = {
    .major = 2,
    .minor = 2,
    .patch = 0
};

@implementation MERThumbnailKitCommon

+ (void)load {
    MELogObject([self versionString]);
}

+ (NSString *)versionString; {
    return [NSString stringWithFormat:@"%@ %@.%@.%@",MERThumbnailKitBundleIdentifier,@(MERThumbnailKitVersion.major),@(MERThumbnailKitVersion.minor),@(MERThumbnailKitVersion.patch)];
}

@end
