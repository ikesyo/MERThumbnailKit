//
//  MERThumbnailKitFunctions.h
//  MERThumbnailKit
//
//  Created by William Towe on 5/1/14.
//  Copyright (c) 2014 Maestro, LLC. All rights reserved.
//

#import <CoreGraphics/CGImage.h>

extern BOOL MERThumbnailKitCGImageHasAlpha(CGImageRef imageRef);
extern CGImageRef MERThumbnailKitCreateCGImageThumbnailWithSize(CGImageRef imageRef, CGSize size);
