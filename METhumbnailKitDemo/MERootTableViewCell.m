//
//  MERootTableViewCell.m
//  METhumbnailKit
//
//  Created by William Towe on 10/17/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import "MERootTableViewCell.h"

@implementation MERootTableViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.imageView setFrame:CGRectMake(CGRectGetMinX(self.imageView.frame), 0, 128, 128)];
    [self.textLabel setFrame:CGRectMake(CGRectGetMaxX(self.imageView.frame), CGRectGetMinY(self.textLabel.frame), CGRectGetWidth(self.contentView.bounds) - CGRectGetMaxX(self.imageView.frame), CGRectGetHeight(self.textLabel.frame))];
}

@end
