//
//  MERThumbnailKit.h
//  MERThumbnailKit
//
//  Created by William Towe on 5/1/14.
//  Copyright (c) 2014 Maestro, LLC. All rights reserved.
//

#ifndef _MER_THUMBNAIL_KIT_
#define _MER_THUMBNAIL_KIT_

#import <TargetConditionals.h>

#import <MERThumbnailKit/MERThumbnailKitCommon.h>
#import <MERThumbnailKit/MERThumbnailManager.h>

#if (TARGET_OS_IPHONE)
#import <MERThumbnailKit/UIImage+MERThumbnailKitExtensions.h>
#else
#import <MERThumbnailKit/NSImage+MERThumbnailKitExtensions.h>
#endif

#endif
