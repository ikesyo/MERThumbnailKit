//
//  METextThumbnailOperation.m
//  METhumbnailKit
//
//  Created by William Towe on 10/18/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import "METextThumbnailOperation.h"
#import "UIImage+METKExtensions.h"

@interface METextThumbnailOperation ()
@property (readwrite,strong,nonatomic) NSURL *url;
@property (readwrite,assign,nonatomic) CGSize size;
@property (copy,nonatomic) METhumbnailOperationCompletionBlock completion;
@end

@implementation METextThumbnailOperation

- (void)main {
    NSDictionary *attributes;
    NSError *outError;
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithFileURL:self.url options:@{NSDocumentTypeDocumentAttribute: NSPlainTextDocumentType,NSDefaultAttributesDocumentAttribute: @{NSForegroundColorAttributeName: [UIColor blackColor],NSBackgroundColorAttributeName: [UIColor whiteColor],NSFontAttributeName: [UIFont systemFontOfSize:17]}} documentAttributes:&attributes error:&outError];
    
    if (!attributedString) {
        NSLog(@"%@",outError);
        self.completion(self.url,nil);
        
        return;
    }
    
    __block CGSize imageSize = CGSizeZero;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        imageSize = [UIApplication sharedApplication].keyWindow.bounds.size;
    });
    
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
    
    self.completion(self.url,retval);
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
