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

const struct MERThumbnailKitVersion MERThumbnailKitVersion = {
    .major = 2,
    .minor = 2,
    .patch = 3
};

NSString *const MERThumbnailKitResourcesBundleName = @"MERThumbnailKitResources.bundle";
NSBundle *MERThumbnailKitResourcesBundle() {
    return [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:MERThumbnailKitResourcesBundleName.stringByDeletingPathExtension withExtension:MERThumbnailKitResourcesBundleName.pathExtension]];
}

@implementation MERThumbnailKitCommon

+ (void)load {
    MELogObject([self versionString]);
}

+ (NSString *)versionString; {
    return [NSString stringWithFormat:@"%@ %@.%@.%@",MERThumbnailKitBundleIdentifier,@(MERThumbnailKitVersion.major),@(MERThumbnailKitVersion.minor),@(MERThumbnailKitVersion.patch)];
}

@end
