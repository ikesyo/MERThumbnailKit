//
//  MERTFThumbnailOperation.m
//  METhumbnailKit
//
//  Created by William Towe on 10/17/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import "MERTFThumbnailOperation.h"
#import "UIImage+METKExtensions.h"
#import <MEFoundation/MEDebugging.h>

@interface MERTFThumbnailOperation ()
@property (readwrite,strong,nonatomic) NSURL *url;
@property (readwrite,assign,nonatomic) CGSize size;
@property (copy,nonatomic) METhumbnailOperationCompletionBlock completion;
@end

@implementation MERTFThumbnailOperation

- (void)main {
    NSDictionary *attributes;
    NSError *outError;
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithFileURL:self.url options:@{NSDocumentTypeDocumentAttribute: ([self.url.lastPathComponent.pathExtension isEqualToString:@"rtf"]) ? NSRTFTextDocumentType : NSRTFDTextDocumentType} documentAttributes:&attributes error:&outError];
    
    if (!attributedString) {
        MELogObject(outError);
        self.completion(self.url,nil);
        
        return;
    }
    
    CGSize const imageSize = METhumbnailOperationDefaultSize;
    
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedString];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:imageSize];
    
    [textStorage addLayoutManager:layoutManager];
    [layoutManager addTextContainer:textContainer];
    
    [layoutManager ensureLayoutForCharacterRange:NSMakeRange(0, textStorage.length)];
    
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0);
    
    UIColor *backgroundColor = ([textStorage attribute:NSBackgroundColorAttributeName atIndex:0 effectiveRange:NULL]) ?: [UIColor whiteColor];
    
    [backgroundColor setFill];
    UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
    
    [layoutManager drawGlyphsForGlyphRange:[layoutManager glyphRangeForCharacterRange:NSMakeRange(0, textStorage.length) actualCharacterRange:NULL] atPoint:CGPointZero];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImage *retval = [image METK_thumbnailOfSize:self.size];
    
    self.completion(self.url,(self.isCancelled) ? nil : retval);
}

- (instancetype)initWithURL:(NSURL *)url size:(CGSize)size page:(NSInteger)page time:(NSTimeInterval)time completion:(METhumbnailOperationCompletionBlock)completion; {
    if (!(self = [super init]))
        return nil;
    
    NSParameterAssert(url);
    NSParameterAssert(!CGSizeEqualToSize(size, CGSizeZero));
    NSParameterAssert(completion);
    
    [self setUrl:url];
    [self setSize:size];
    [self setCompletion:completion];
    
    return self;
}

@end
