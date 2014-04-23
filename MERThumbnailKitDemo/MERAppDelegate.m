//
//  MERAppDelegate.m
//  MERThumbnailKitDemo
//
//  Created by William Towe on 4/23/14.
//  Copyright (c) 2014 Maestro, LLC. All rights reserved.
//

#import "MERAppDelegate.h"
#import "MERRootViewController.h"
#import <MERThumbnailKit/MERThumbnailKit.h>

@implementation MERAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [[MERThumbnailManager sharedManager] setThumbnailTime:2.0];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[MERRootViewController alloc] init];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
