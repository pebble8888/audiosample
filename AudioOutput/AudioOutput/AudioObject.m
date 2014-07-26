//
//  AudioObject.m
//
//  Copyright (c) 2014年 pebble8888. All rights reserved.
//

#import "AudioObject.h"
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AudioObject ()
{
    enum {
        kSampleRate = 44100,
    };
}
@end

@implementation AudioObject

+ (AudioStreamBasicDescription)monoWaveASBD
{
    AudioStreamBasicDescription asbd;
	asbd.mSampleRate = kSampleRate;
	asbd.mFormatID = kAudioFormatLinearPCM;
	asbd.mFormatFlags = kAudioFormatFlagsCanonical;
	asbd.mChannelsPerFrame = 1;
	asbd.mFramesPerPacket = 1;
	asbd.mBitsPerChannel = 16;
	asbd.mBytesPerFrame = asbd.mBitsPerChannel / 8 * asbd.mChannelsPerFrame;
	asbd.mBytesPerPacket = asbd.mBytesPerFrame * asbd.mFramesPerPacket;
    return asbd;
}
+ (AudioStreamBasicDescription)stereoWaveASBD
{
    AudioStreamBasicDescription asbd;
	asbd.mSampleRate = kSampleRate;
	asbd.mFormatID = kAudioFormatLinearPCM;
	asbd.mFormatFlags = kAudioFormatFlagsCanonical;
	asbd.mChannelsPerFrame = 2;
	asbd.mFramesPerPacket = 1;
	asbd.mBitsPerChannel = 16;
	asbd.mBytesPerFrame = asbd.mBitsPerChannel / 8 * asbd.mChannelsPerFrame;
	asbd.mBytesPerPacket = asbd.mBytesPerFrame * asbd.mFramesPerPacket;
    return asbd;
}

- (void)process
{
    [self process_mono];
    [self process_stereo];
}

/**
 * @brief output mono wav file (Microsoft)
 */
- (void)process_mono
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* filename = [NSString stringWithFormat:@"%@/mono.wav", path];
    
    NSLog( @"filename[%@]", filename );
    
    OSStatus status;
    CFURLRef urlref_out = (__bridge CFURLRef)[NSURL fileURLWithPath:filename];
    
    AudioStreamBasicDescription asbd_out = [[self class] monoWaveASBD];
    ExtAudioFileRef audiofile_out = NULL;
    status = ExtAudioFileCreateWithURL(urlref_out,
                                       kAudioFileWAVEType,
                                       &asbd_out,
                                       NULL,
                                       kAudioFileFlags_EraseFile,
                                       &audiofile_out);
    assert( status == noErr );
   
    int framelen = kSampleRate; // 1sec
    int16_t buffer[framelen];
    memset( buffer, 0, sizeof(buffer) );
    
    // 440Hz
    for( int i = 0; i < framelen; ++i ){
        double val = sin( 2 * M_PI * i * 440 / kSampleRate );
        buffer[i] = (int16_t)(val * 32767);
    }
    
    AudioBufferList buflist;
    buflist.mNumberBuffers = 1;
    buflist.mBuffers[0].mNumberChannels = 1;
    buflist.mBuffers[0].mDataByteSize = sizeof(int16_t) * framelen;
    buflist.mBuffers[0].mData = buffer;
    
    status = ExtAudioFileWrite(audiofile_out, framelen, &buflist);
    assert( status == noErr );
    
    status = ExtAudioFileDispose(audiofile_out);
    assert( status == noErr );
}

/**
 * @brief output stereo wav file (Microsoft)
 */
- (void)process_stereo
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* filename = [NSString stringWithFormat:@"%@/stereo.wav", path];
    
    NSLog( @"filename[%@]", filename );
    
    OSStatus status;
    CFURLRef urlref_out = (__bridge CFURLRef)[NSURL fileURLWithPath:filename];
    
    AudioStreamBasicDescription asbd_out = [[self class] stereoWaveASBD];
    ExtAudioFileRef audiofile_out = NULL;
    status = ExtAudioFileCreateWithURL(urlref_out,
                                       kAudioFileWAVEType,
                                       &asbd_out,
                                       NULL,
                                       kAudioFileFlags_EraseFile,
                                       &audiofile_out);
    assert( status == noErr );
   
    int channels = 2;
    int framelen = kSampleRate; // 1sec
    int buflen = framelen * channels;
    int16_t* buffer = malloc( sizeof(int16_t) * buflen );
    
    // 440Hz
    for( int ch = 0; ch < channels; ++ch ){
        for( int i = 0; i < framelen; ++i ){
            double dval = sin( 2 * M_PI * i * 440 / kSampleRate );
            int16_t ival = (int16_t)(dval * 32767);
            buffer[i*2+ch] = ival;
        }
    }
    
    AudioBufferList buflist;
    buflist.mNumberBuffers = 1;
    buflist.mBuffers[0].mNumberChannels = 2;
    buflist.mBuffers[0].mDataByteSize = sizeof(int16_t) * buflen;
    buflist.mBuffers[0].mData = buffer;
    
    status = ExtAudioFileWrite(audiofile_out, framelen, &buflist);
    assert( status == noErr );
    
    status = ExtAudioFileDispose(audiofile_out);
    assert( status == noErr );
    
    free( buffer );
}

@end
