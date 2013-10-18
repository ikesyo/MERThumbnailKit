//
//  MERTFThumbnailOperation.m
//  METhumbnailKit
//
//  Created by William Towe on 10/17/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import "MERTFThumbnailOperation.h"
#import "UIImage+METKExtensions.h"

@interface MERTFThumbnailOperation ()
@property (readwrite,strong,nonatomic) NSURL *url;
@property (readwrite,assign,nonatomic) CGSize size;
@property (copy,nonatomic) METhumbnailOperationCompletionBlock completion;
@end

@implementation MERTFThumbnailOperation

- (void)main {
    NSDictionary *attributes;
    NSError *outError;
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithFileURL:self.url options:@{NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType,NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)} documentAttributes:&attributes error:&outError];
    
    if (!attributedString) {
        NSLog(@"%@",outError);
        self.completion(self.url,nil);
        
        return;
    }
    
    CGSize paperSize = [attributes[NSPaperSizeDocumentAttribute] CGSizeValue];
    UIEdgeInsets paperMargin = [attributes[NSPaperMarginDocumentAttribute] UIEdgeInsetsValue];
    
    UIGraphicsBeginImageContextWithOptions(paperSize, YES, 0);
    
    [[UIColor whiteColor] setFill];
    UIRectFill(CGRectMake(0, 0, paperSize.width, paperSize.height));
    
    [attributedString drawWithRect:UIEdgeInsetsInsetRect(CGRectMake(0, 0, paperSize.width, paperSize.height), paperMargin) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
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
