//
//  AppDelegate.m
//  AudioOutput
//
//  Created by pebble8888 on 2014/07/26.
//  Copyright (c) 2014年 pebble8888. All rights reserved.
//

#import "AppDelegate.h"
#import "AudioObject.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    AudioObject* obj = [[AudioObject alloc] init];
    [obj process];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {}
- (void)applicationDidEnterBackground:(UIApplication *)application {}
- (void)applicationWillEnterForeground:(UIApplication *)application {}
- (void)applicationDidBecomeActive:(UIApplication *)application {}
- (void)applicationWillTerminate:(UIApplication *)application {}

@end
