//
//  MERRootCollectionViewCell.m
//  MERThumbnailKit
//
//  Created by William Towe on 4/23/14.
//  Copyright (c) 2014 Maestro, LLC. All rights reserved.
//

#import "MERRootCollectionViewCell.h"

@interface MERRootCollectionViewCell ()
@property (readwrite,strong,nonatomic) UIImageView *imageView;
@end

@implementation MERRootCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    [self setImageView:[[UIImageView alloc] initWithFrame:CGRectZero]];
    [self.imageView setClipsToBounds:YES];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.contentView addSubview:self.imageView];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.imageView setFrame:self.contentView.bounds];
}

@end
