//
//  MERootViewController.m
//  METhumbnailKit
//
//  Created by William Towe on 10/17/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import "MERootViewController.h"
#import <METhumbnailKit/METhumbnailKit.h>

@interface MERootViewController () <UITableViewDataSource>
@property (strong,nonatomic) UITableView *tableView;

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
    
    UIGraphicsBeginImageContext(CGSizeMake(128, 128));
    
    [[UIColor blackColor] setFill];
    UIRectFill(CGRectMake(0, 0, 128, 128));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [self setImage:image];
    
    [self setTableView:[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain]];
    [self.tableView setRowHeight:128];
    [self.tableView setDataSource:self];
    [self.view addSubview:self.tableView];
}
- (void)viewDidLayoutSubviews {
    [self.tableView setFrame:self.view.bounds];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.urls.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@""];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    }
    
    NSURL *url = self.urls[indexPath.row];
    
    [cell.textLabel setText:url.lastPathComponent];
    [cell.imageView setImage:self.image];
    
    [self.thumbnailManager addThumbnailOperationForURL:url size:CGSizeMake(self.tableView.rowHeight, self.tableView.rowHeight) page:1 time:5.0 completion:^(NSURL *url, UIImage *image,METhumbnailManagerCacheType cacheType) {
        [cell.imageView setImage:image];
    }];
    
    return cell;
}

@end
