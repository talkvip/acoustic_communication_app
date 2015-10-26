//
//  PlayViewController.m
//  acoustic_communication_app
//
//  Created by YuichiSato on 2015/10/19.
//  Copyright © 2015年 佐藤惟知. All rights reserved.
//

#import "PlayViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface PlayViewController (){
    AudioUnit aU;
    UInt32 bitRate;
}
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (nonatomic) double phase;
@property (nonatomic) Float64 sampleRate;
@property (nonatomic) Float64 frequency;

static OSStatus renderer(void *inRef,
                         AudioUnitRenderActionFlags *ioActionFlags,
                         const AudioTimeStamp* inTimeStamp,
                         UInt32 inBusNumber,
                         UInt32 inNumberFrames,
                         AudioBufferList *ioData);

@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.playButton addTarget:self action:@selector(playStart) forControlEvents:UIControlEventTouchDown];
    [self.playButton addTarget:self action:@selector(playStop) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton addTarget:self action:@selector(playStop) forControlEvents:UIControlEventTouchUpOutside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)playStart{
    NSLog(@"playStart");
    
    //Sampling rate
    _sampleRate = 44100.0f;
    
    //Bit rate
    bitRate = 8;  // 8bit
    
    //周波数（音程）
    _frequency = 261.62;
    
    //AudioComponentDescription
    AudioComponentDescription aCD;
    aCD.componentType = kAudioUnitType_Output;
    aCD.componentSubType = kAudioUnitSubType_RemoteIO;
    aCD.componentManufacturer = kAudioUnitManufacturer_Apple;
    aCD.componentFlags = 0;
    aCD.componentFlagsMask = 0;
    
    //AudioComponent
    AudioComponent aC = AudioComponentFindNext(NULL, &aCD);
    AudioComponentInstanceNew(aC, &aU);
    AudioUnitInitialize(aU);
    
    //コールバック
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = renderer;
    callbackStruct.inputProcRefCon = (__bridge void*)self;
    AudioUnitSetProperty(aU,
                         kAudioUnitProperty_SetRenderCallback,
                         kAudioUnitScope_Input,
                         0,
                         &callbackStruct,
                         sizeof(AURenderCallbackStruct));
    
    //AudioStreamBasicDescription
    AudioStreamBasicDescription aSBD;
    aSBD.mSampleRate = _sampleRate;
    aSBD.mFormatID = kAudioFormatLinearPCM;
    aSBD.mFormatFlags = kAudioFormatFlagsAudioUnitCanonical;
    aSBD.mChannelsPerFrame = 2;
    aSBD.mBytesPerPacket = sizeof(AudioUnitSampleType);
    aSBD.mBytesPerFrame = sizeof(AudioUnitSampleType);
    aSBD.mFramesPerPacket = 1;
    aSBD.mBitsPerChannel = bitRate * sizeof(AudioUnitSampleType);
    aSBD.mReserved = 0;
    
    //AudioUnit
    AudioUnitSetProperty(aU,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Input,
                         0,
                         &aSBD,
                         sizeof(aSBD));
    
    //再生
    AudioOutputUnitStart(aU);
}

- (void)playStop{
    NSLog(@"playStop");
    AudioOutputUnitStop(aU);
}

static OSStatus renderer(void *inRef,
                         AudioUnitRenderActionFlags *ioActionFlags,
                         const AudioTimeStamp* inTimeStamp,
                         UInt32 inBusNumber,
                         UInt32 inNumberFrames,
                         AudioBufferList *ioData) {
    
    //キャスト
    PlayViewController* def = (__bridge PlayViewController*)inRef;
    
    //サイン波
    float freq = def.frequency*2.0*M_PI/def.sampleRate;
    
    //値を書き込むポインタ
    AudioUnitSampleType *outL = ioData->mBuffers[0].mData;
    AudioUnitSampleType *outR = ioData->mBuffers[1].mData;
    
    for (int i = 0; i < inNumberFrames; i++) {
        // 周波数を計算
        float wave = sin(def.phase);
        AudioUnitSampleType sample = wave * (1 << kAudioUnitSampleFractionBits);
        *outL++ = sample;
        *outR++ = sample;
        def.phase += freq;
    }
    
    return noErr;
    
};

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
