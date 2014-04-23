//
//  MERRootViewController.m
//  MERThumbnailKit
//
//  Created by William Towe on 4/23/14.
//  Copyright (c) 2014 Maestro, LLC. All rights reserved.
//

#import "MERRootViewController.h"
#import "MERRootCollectionViewCell.h"
#import <MERThumbnailKit/MERThumbnailKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <libextobjc/EXTScope.h>

@interface MERRootViewController () <UICollectionViewDataSource>
@property (strong,nonatomic) UICollectionView *collectionView;

@property (copy,nonatomic) NSArray *urls;
@end

@implementation MERRootViewController

- (id)init {
    if (!(self = [super init]))
        return nil;
    
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:[[NSBundle mainBundle] URLForResource:@"Files" withExtension:nil] includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsPackageDescendants|NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:^BOOL(NSURL *url, NSError *error) {
        NSLog(@"%@",error);
        return YES;
    }];
    
    [self setUrls:[@[[NSURL URLWithString:@"http://www.lolcats.com/images/u/12/52/allforme.jpg"],[NSURL URLWithString:@"http://download.wavetlan.com/SVV/Media/HTTP/H264/Talkinghead_Media/H264_test1_Talkinghead_mp4_480x360.mp4"]] arrayByAddingObjectsFromArray:enumerator.allObjects]];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    [layout setSectionInset:UIEdgeInsetsMake(20, 20, 20, 20)];
    [layout setMinimumInteritemSpacing:8];
    [layout setMinimumLineSpacing:8];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [layout setItemSize:CGSizeMake(150, 150)];
    else
        [layout setItemSize:CGSizeMake(72, 72)];
    
    [self setCollectionView:[[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout]];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView registerClass:[MERRootCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([MERRootCollectionViewCell class])];
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
    MERRootCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MERRootCollectionViewCell class]) forIndexPath:indexPath];
    
    @weakify(cell);
    
    [[[[MERThumbnailManager sharedManager] thumbnailForURL:self.urls[indexPath.row]]
      takeUntil:[cell rac_prepareForReuseSignal]]
     subscribeNext:^(RACTuple *value) {
         @strongify(cell);
         
         RACTupleUnpack(__unused NSURL *url, UIImage *image, __unused NSNumber *cacheType) = value;
         
         [cell.imageView setImage:image];
    }];
    
    return cell;
}

@end
