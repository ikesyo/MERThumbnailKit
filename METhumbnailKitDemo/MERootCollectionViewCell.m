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
@property (readwrite,strong,nonatomic) UILabel *titleLabel;
@end

@implementation MERootCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    [self setImageView:[[UIImageView alloc] initWithFrame:CGRectZero]];
    [self.contentView addSubview:self.imageView];
    
    [self setTitleLabel:[[UILabel alloc] initWithFrame:CGRectZero]];
    [self.titleLabel setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    [self.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.contentView addSubview:self.titleLabel];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.imageView setFrame:self.contentView.bounds];
    [self.titleLabel setFrame:CGRectMake(0, CGRectGetMaxY(self.contentView.bounds) - self.titleLabel.font.lineHeight, CGRectGetWidth(self.contentView.bounds), self.titleLabel.font.lineHeight)];
}

@end
