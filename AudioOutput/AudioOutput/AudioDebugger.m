//
//  AudioDebugger.m
//
//  Copyright (c) 2014年 pebble8888. All rights reserved.
//

#import "AudioDebugger.h"
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AudioDebugger ()
{
    enum {
        kSampleRate = 44100,
        kAddLimitFrame = 44100,
    };
    int _channels;
    AudioStreamBasicDescription _asbd_out;
    ExtAudioFileRef _audiofile_out;
    int16_t* _buffer;
    int16_t* _buffer2;
}
@end

@implementation AudioDebugger

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

- (id)init
{
    self = [super init];
    if( self ){
        _audiofile_out = NULL;
        _buffer = malloc( kAddLimitFrame * 2 );
        _buffer2 = malloc( kAddLimitFrame * 2);
    }
    return self;
}

- (void)dealloc
{
    free(_buffer);
    free(_buffer2);
}

- (void)setupChannels:(int)aChannels
{
    assert( _audiofile_out == NULL );
    _channels = aChannels;
    assert(aChannels == 1 || aChannels == 2);
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* kind = (_channels == 1 ? @"mono" : @"stereo");
    NSString* filename = [NSString stringWithFormat:@"%@/%@_%@.wav", path, kind, [[self class] currentDateString]];
    
    NSLog( @"filename[%@]", filename );
    
    OSStatus status;
    CFURLRef urlref_out = (__bridge CFURLRef)[NSURL fileURLWithPath:filename];
    
    AudioStreamBasicDescription asbd_out;
    asbd_out = (_channels == 1 ? [[self class] monoWaveASBD] : [[self class] stereoWaveASBD]);
    status = ExtAudioFileCreateWithURL(urlref_out,
                                       kAudioFileWAVEType,
                                       &asbd_out,
                                       NULL,
                                       kAudioFileFlags_EraseFile,
                                       &_audiofile_out);
    assert( status == noErr );
}

- (void)addMonoShortData:(int16_t*)buf Length:(int64_t)aFrameLength
{
    assert( aFrameLength <= kAddLimitFrame );
    assert( _channels == 1 );
    
    AudioBufferList buflist;
    buflist.mNumberBuffers = 1;
    buflist.mBuffers[0].mNumberChannels = _channels;
    buflist.mBuffers[0].mDataByteSize = (UInt32)( sizeof(int16_t) * aFrameLength * _channels);
    buflist.mBuffers[0].mData = buf;
   
    OSStatus status;
    status = ExtAudioFileWriteAsync(_audiofile_out, (UInt32)aFrameLength, &buflist);
    assert( status == noErr);
}

- (void)addStereoShortData:(int16_t*)buf Length:(int64_t)aFrameLength
{
    assert( aFrameLength <= kAddLimitFrame );
    assert( _channels == 2 );
    OSStatus status;
    
    AudioBufferList buflist;
    buflist.mNumberBuffers = 1;
    buflist.mBuffers[0].mNumberChannels = 2;
    buflist.mBuffers[0].mDataByteSize = (UInt32)( sizeof(int16_t) * aFrameLength * _channels );
    buflist.mBuffers[0].mData = buf;
    
    UInt32 flen = (UInt32)aFrameLength;
    // ***IMPORTANT***
    // ExtAudioFileWriteAsync() is capable for MONO AudioBufferList, so use ExtAudioFileWrite()
    status = ExtAudioFileWrite(_audiofile_out, flen, &buflist);
    
    assert( status == noErr);
}

- (void)dispose
{
    OSStatus status;
    status = ExtAudioFileDispose(_audiofile_out);
    assert( status == noErr );
}

+ (NSString *)currentDateString
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
    [df setDateFormat:@"yyyyMMdd_HHmmss"];

    NSDate *now = [NSDate date];
    return [df stringFromDate:now];
}

@end
