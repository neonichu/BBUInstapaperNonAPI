//
//  BBUAppDelegate.m
//  BBUInstapaperNonAPI
//
//  Created by Boris Bügling on 26.01.14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import "BBUAppDelegate.h"
#import "BBUArticlesViewController.h"

@interface BBUAppDelegate ()

@property BBUArticlesViewController* articles;


@end

#pragma mark -

@implementation BBUAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.articles = [BBUArticlesViewController new];
    [self.articles refresh];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:self.articles];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
