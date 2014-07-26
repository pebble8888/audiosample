//
//  AudioDebugger.h
//
//  Copyright (c) 2014年 pebble8888. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioDebugger : NSObject

- (void)setupChannels:(int)aChannels;
- (void)addMonoShortData:(int16_t*)buf FrameLength:(int64_t)aFrameLength;
- (void)addStereoShortData:(int16_t*)buf FrameLength:(int64_t)aFrameLength;
- (void)dispose;

@end
