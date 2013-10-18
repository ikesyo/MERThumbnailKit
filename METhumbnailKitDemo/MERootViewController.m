//
//  MERootViewController.m
//  METhumbnailKit
//
//  Created by William Towe on 10/17/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import "MERootViewController.h"
#import <METhumbnailKit/METhumbnailKit.h>
#import "MERootCollectionViewCell.h"

@interface MERootViewController () <UICollectionViewDataSource>
@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) UICollectionView *collectionView;

@property (strong,nonatomic) NSArray *urls;
@property (strong,nonatomic) METhumbnailManager *thumbnailManager;
@property (strong,nonatomic) UIImage *image;
@end

@implementation MERootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUrls:[[NSFileManager defaultManager] contentsOfDirectoryAtURL:[[NSBundle mainBundle] URLForResource:@"Files" withExtension:nil] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants|NSDirectoryEnumerationSkipsPackageDescendants|NSDirectoryEnumerationSkipsHiddenFiles error:NULL]];
    
    [self setThumbnailManager:[[METhumbnailManager alloc] init]];
    [self.thumbnailManager clearFileCache];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    [layout setSectionInset:UIEdgeInsetsMake(20, 20, 20, 20)];
    [layout setItemSize:CGSizeMake(128, 128)];
    [layout setMinimumInteritemSpacing:8];
    [layout setMinimumLineSpacing:8];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    [self setCollectionView:[[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout]];
    [self.collectionView registerClass:[MERootCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([MERootCollectionViewCell class])];
    [self.collectionView setDataSource:self];
    [self.view addSubview:self.collectionView];
}
- (void)viewDidLayoutSubviews {
    [self.collectionView setFrame:self.view.bounds];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.urls.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MERootCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MERootCollectionViewCell class]) forIndexPath:indexPath];
    NSURL *url = self.urls[indexPath.row];
    
    [cell.titleLabel setText:url.lastPathComponent.pathExtension];
    [cell.imageView METK_setImageForThumbnailFromURL:url size:[(UICollectionViewFlowLayout *)collectionView.collectionViewLayout itemSize] time:2.0 placeholderImage:nil];
    
    return cell;
}

@end
