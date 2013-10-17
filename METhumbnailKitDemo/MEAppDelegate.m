//
//  MEAppDelegate.m
//  METhumbnailKitDemo
//
//  Created by William Towe on 10/16/13.
//  Copyright (c) 2013 Maestro, LLC. All rights reserved.
//

#import "MEAppDelegate.h"
#import "MERootViewController.h"

@implementation MEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setWindow:[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]];;
    [self.window setRootViewController:[[MERootViewController alloc] init]];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
