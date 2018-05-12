//
//  WFDisplaySoundPlayer.m
//  WFConnector
//
//  Created by Murray Hughes on 25/08/13.
//  Copyright (c) 2013 Wahoo Fitness. All rights reserved.
//

#import "WFDisplaySoundPlayer.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <WFConnector/WFDisplaySound.h>

@interface WFDisplaySoundPlayer ()

@property (nonatomic, strong) dispatch_queue_t backgroundQueue;

@end


@implementation WFDisplaySoundPlayer
{
@public
    BOOL shouldStop;
	double frequency;
	double sampleRate;
	double theta;
	AudioComponentInstance toneUnit;

}

#pragma mark -
#pragma mark - Public


- (id)init
{
    self = [super init];
    if (self) {

        frequency = 0;
        sampleRate = 44100;
        
        self.backgroundQueue = dispatch_queue_create("com.wahoofitness.WFConnector.soundPlayer", NULL);

        
        [self createToneAudioUnit];
    }
    return self;
}

- (void) playSoundValue:(NSString*) soundValue
{
    WFDisplaySound* sound = [[WFDisplaySound alloc] init];
    sound.value = soundValue;
    [self playSound:sound];
}


- (void) playSound:(WFDisplaySound*) sound
{
    [self stop];

    dispatch_async(self.backgroundQueue, ^(void) {
        
        _playing = YES;
        
        NSArray* tones = [sound tones];
        
        for (NSArray* tone in tones) {
            
            frequency = [tone[0] integerValue];
            [NSThread sleepForTimeInterval:[tone[1] doubleValue]/1000.0];
            
            if(self.isPlaying==NO)
            {
                break;
            }
        }
        
        frequency = 0;
        _playing = NO;
        
    });

}




- (void) stop
{
    frequency = 0;
    _playing = NO;
}



- (void) createToneAudioUnit
{
	// Configure the search parameters to find the default playback output unit
	// (called the kAudioUnitSubType_RemoteIO on iOS but
	// kAudioUnitSubType_DefaultOutput on Mac OS X)
	AudioComponentDescription defaultOutputDescription;
	defaultOutputDescription.componentType = kAudioUnitType_Output;
	defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	defaultOutputDescription.componentFlags = 0;
	defaultOutputDescription.componentFlagsMask = 0;

#ifdef TARGET_OS_MAC
    defaultOutputDescription.componentSubType = kAudioUnitSubType_DefaultOutput;
#else
    defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
#endif

    
	// Get the default playback output unit
	AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
	NSAssert(defaultOutput, @"Can't find default output");
	
	// Create a new unit based on this that we'll use for output
	OSErr err = AudioComponentInstanceNew(defaultOutput, &toneUnit);
	NSAssert(toneUnit, @"Error creating unit: %ld", (long)err);
	
    
	// Set our tone rendering function on the unit
	AURenderCallbackStruct input;
	input.inputProc = RenderTone;
	input.inputProcRefCon = (__bridge void*)self;
	err = AudioUnitSetProperty(toneUnit,
                               kAudioUnitProperty_SetRenderCallback,
                               kAudioUnitScope_Input,
                               0,
                               &input,
                               sizeof(input));
	NSAssert1(err == noErr, @"Error setting callback: %ld", (long)err);
	
	// Set the format to 32 bit, single channel, floating point, linear PCM
	const int four_bytes_per_float = 4;
	const int eight_bits_per_byte = 8;
	AudioStreamBasicDescription streamFormat;
	streamFormat.mSampleRate = sampleRate;
	streamFormat.mFormatID = kAudioFormatLinearPCM;
	streamFormat.mFormatFlags =
    kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
	streamFormat.mBytesPerPacket = four_bytes_per_float;
	streamFormat.mFramesPerPacket = 1;
	streamFormat.mBytesPerFrame = four_bytes_per_float;
	streamFormat.mChannelsPerFrame = 1;
	streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
	err = AudioUnitSetProperty (toneUnit,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Input,
                                0,
                                &streamFormat,
                                sizeof(AudioStreamBasicDescription));
	NSAssert1(err == noErr, @"Error setting stream format: %ld", (long)err);

    // Stop changing parameters on the unit
    err = AudioUnitInitialize(toneUnit);
    NSAssert(err == noErr, @"Error initializing unit: %ld", (long)err);
    
    
    // Start playback
    AudioOutputUnitStart(toneUnit);

}






OSStatus RenderTone(void *inRefCon,
                    AudioUnitRenderActionFlags 	*ioActionFlags,
                    const AudioTimeStamp 		*inTimeStamp,
                    UInt32 						inBusNumber,
                    UInt32 						inNumberFrames,
                    AudioBufferList 			*ioData)

{
	// Fixed amplitude is good enough for our purposes
	const double amplitude = 0.25;
    
	// Get the tone parameters out of the view controller
	WFDisplaySoundPlayer *soundPlayer =  (__bridge WFDisplaySoundPlayer *)inRefCon;
	double theta = soundPlayer->theta;
	double theta_increment = 2.0 * M_PI * soundPlayer->frequency / soundPlayer->sampleRate;
    
	// This is a mono tone generator so we only need the first buffer
	const int channel = 0;
	Float32 *buffer = (Float32 *)ioData->mBuffers[channel].mData;
	
	// Generate the samples
	for (UInt32 frame = 0; frame < inNumberFrames; frame++)
	{
		buffer[frame] = sin(theta) * amplitude;
		
		theta += theta_increment;
		if (theta > 2.0 * M_PI)
		{
			theta -= 2.0 * M_PI;
		}
	}
	
	// Store the theta back in the view controller
	soundPlayer->theta = theta;
    
	return noErr;
}

void ToneInterruptionListener(void *inClientData, UInt32 inInterruptionState)
{
	WFDisplaySoundPlayer *soundPLayer =  (__bridge WFDisplaySoundPlayer *)inClientData;
	
    [soundPLayer stop];
}





@end
