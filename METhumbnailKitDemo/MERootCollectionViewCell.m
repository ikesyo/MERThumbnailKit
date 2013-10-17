//
//  MERootCollectionViewCell.m
//  METhumbnailKit
//
//  Created by William Towe on 10/17/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import "MERootCollectionViewCell.h"

@interface MERootCollectionViewCell ()
@property (readwrite,strong,nonatomic) UIImageView *imageView;
@end

@implementation MERootCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    [self setImageView:[[UIImageView alloc] initWithFrame:CGRectZero]];
    [self.contentView addSubview:self.imageView];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.imageView setFrame:self.contentView.bounds];
}

@end
