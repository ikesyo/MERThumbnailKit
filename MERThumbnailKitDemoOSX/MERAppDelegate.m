//
//  MERAppDelegate.m
//  MERThumbnailKitDemoOSX
//
//  Created by William Towe on 5/1/14.
//  Copyright (c) 2014 Maestro, LLC. All rights reserved.
//

#import "MERAppDelegate.h"
#import <MEFoundation/MEFoundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <libextobjc/EXTScope.h>
#import <MERThumbnailKit/MERThumbnailKit.h>

@interface MERAppDelegate () <NSTableViewDataSource,NSTableViewDelegate>
@property (weak,nonatomic) IBOutlet NSTableView *tableView;

@property (copy,nonatomic) NSArray *urls;
@end

@implementation MERAppDelegate

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[MERThumbnailManager sharedManager] setThumbnailTime:3.0];
    
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    
    NSDirectoryEnumerator *directoryEnum = [[NSFileManager defaultManager] enumeratorAtURL:[[NSBundle mainBundle] URLForResource:@"Files" withExtension:nil] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants|NSDirectoryEnumerationSkipsPackageDescendants|NSDirectoryEnumerationSkipsHiddenFiles errorHandler:^BOOL(NSURL *url, NSError *error) {
        MELogObject(error);
        return YES;
    }];
    
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    
    for (NSString *urlString in [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"RemoteURLs" withExtension:@"plist"]])
        [urls addObject:[NSURL URLWithString:urlString]];
    
    [self setUrls:[urls arrayByAddingObjectsFromArray:directoryEnum.allObjects]];
    
    [self.tableView reloadData];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.urls.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:nil];
    
    @weakify(view);
    
    [[[[MERThumbnailManager sharedManager]
       thumbnailForURL:self.urls[row]]
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(RACTuple *value) {
         @strongify(view);
         
         RACTupleUnpack(NSURL *url, NSImage *image, NSNumber *cacheType) = value;
         
         MELog(@"%@ %@",url,cacheType);
         
         NSTableCellView *localView = [tableView viewAtColumn:[tableView columnForView:view] row:[tableView rowForView:view] makeIfNecessary:NO];
         
         [localView.imageView setImage:image];
    }];
    
    return view;
}

@end
