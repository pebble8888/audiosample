//
//  AppDelegate.m
//  AudioOutput
//
//  Created by pebble8888 on 2014/07/26.
//  Copyright (c) 2014年 pebble8888. All rights reserved.
//

#import "AppDelegate.h"
#import "AudioObject.h"
#import "AudioDebugger.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    {
        AudioObject* obj = [[AudioObject alloc] init];
        [obj process];
    }
    // mono
    {
        AudioDebugger* ad = [[AudioDebugger alloc] init];
        [ad setupChannels:1];
        
        int16_t buffer[44100];
        // 440Hz
        
        for( int i = 0; i < 44100; ++i ){
            double dval = sin( 2 * M_PI * i * 440 / 44100);
            int16_t ival = (int16_t)(dval * 32767);
            buffer[i] = ival;
        }
        // 2sec
        [ad addMonoShortData:buffer Length:44100];
        [ad addMonoShortData:buffer Length:44100];
        
        [ad dispose];
    }
    // stereo
    {
        AudioDebugger* ad = [[AudioDebugger alloc] init];
        [ad setupChannels:2];
        
        //int16_t buffer[44100*2];
        int16_t* buffer = malloc( 44100 * 2);
        // 440Hz
        
        for( int ch = 0; ch < 2; ++ch ){
            for( int i = 0; i < 44100; ++i ){
                double dval = sin( 2 * M_PI * i * 440 / 44100);
                int16_t ival = (int16_t)(dval * 32767);
                buffer[2*i+ch] = ival;
            }
        }
        // 2sec
        [ad addStereoShortData:buffer Length:44100];
        [ad addStereoShortData:buffer Length:44100];
        
        free( buffer );
        
        [ad dispose];
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {}
- (void)applicationDidEnterBackground:(UIApplication *)application {}
- (void)applicationWillEnterForeground:(UIApplication *)application {}
- (void)applicationDidBecomeActive:(UIApplication *)application {}
- (void)applicationWillTerminate:(UIApplication *)application {}

@end
