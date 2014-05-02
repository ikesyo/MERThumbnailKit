//
//  MERAppDelegate.m
//  MERThumbnailKitDemoiOS
//
//  Created by William Towe on 5/1/14.
//  Copyright (c) 2014 Maestro, LLC. All rights reserved.
//

#import "MERAppDelegate.h"
#import "MERViewController.h"
#import <MERThumbnailKit/MERThumbnailKit.h>

@implementation MERAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[MERThumbnailManager sharedManager] setThumbnailTime:3.0];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[MERViewController alloc] init]];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
