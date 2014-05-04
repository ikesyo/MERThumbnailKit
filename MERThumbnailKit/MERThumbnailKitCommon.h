//
//  MERThumbnailKitCommon.h
//  MERThumbnailKit
//
//  Created by William Towe on 5/4/14.
//  Copyright (c) 2014 Maestro, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const MERThumbnailKitBundleIdentifier;

extern const struct MERThumbnailKitVersion {
    NSInteger major;
    NSInteger minor;
    NSInteger patch;
} MERThumbnailKitVersion;

@interface MERThumbnailKitCommon : NSObject

+ (NSString *)versionString;

@end
