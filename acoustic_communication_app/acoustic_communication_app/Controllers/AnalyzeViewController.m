//
//  AnalyzeViewController.m
//  acoustic_communication_app
//
//  Created by YuichiSato on 2015/10/19.
//  Copyright © 2015年 佐藤惟知. All rights reserved.
//

#import "AnalyzeViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MyFFT.h"


@interface AnalyzeViewController ()
- (IBAction)analyzeStart:(id)sender;

@end

@implementation AnalyzeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)process
{
    
    NSString *dir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *soundPath = [dir stringByAppendingPathComponent:@"test.caf"];// さっき録音したファイル
    CFURLRef cfurl = (__bridge CFURLRef)[NSURL fileURLWithPath:soundPath];
    
    ExtAudioFileRef audioFile;
    OSStatus status;
    
    status = ExtAudioFileOpenURL(cfurl, &audioFile);
    
    const UInt32 frameCount = 1024;
    const int channelCountPerFrame = 1;
    
    AudioStreamBasicDescription clientFormat;
    clientFormat.mChannelsPerFrame =  channelCountPerFrame;
    clientFormat.mSampleRate = 44100;
    
    clientFormat.mFormatID = kAudioFormatLinearPCM;
    clientFormat.mFormatFlags = kAudioFormatFlagIsFloat | kAudioFormatFlagIsNonInterleaved;
    int cmpSize = sizeof(float);
    int frameSize = cmpSize*channelCountPerFrame;
    clientFormat.mBitsPerChannel = cmpSize*8;
    clientFormat.mBytesPerPacket = frameSize;
    clientFormat.mFramesPerPacket = 1;
    clientFormat.mBytesPerFrame = frameSize;
    
    status = ExtAudioFileSetProperty(audioFile, kExtAudioFileProperty_ClientDataFormat, sizeof(clientFormat), &clientFormat);
    
    // 後述するMyFFTクラスを使用
    MyFFT* fft = [[MyFFT alloc] initWithCapacity:frameCount];
    
    while(true) {
        float buf[channelCountPerFrame*frameCount];
        AudioBuffer ab = { channelCountPerFrame, sizeof(buf), buf };
        AudioBufferList audioBufferList;
        audioBufferList.mNumberBuffers = 1;
        audioBufferList.mBuffers[0] = ab;
        
        UInt32 processedFrameCount = frameCount;
        status = ExtAudioFileRead(audioFile, &processedFrameCount, &audioBufferList);
        
        if(processedFrameCount == 0){
            break;
        } else {
            [fft process:buf];
        }
        
        [fft process:buf];
        int NumFrames = 64;
        float vdist[NumFrames];
        vDSP_vdist([fft realp], 1, [fft imagp], 1, vdist, 1, NumFrames);
        
        // vdist[0] 〜vdist[NumFrames-1]が周波数特性
        for(int i = 1;i < NumFrames; i++){
            NSLog(@"%d %f", i, vdist[i]);
        }
    }
    
    status = ExtAudioFileDispose(audioFile);
   
}

- (IBAction)analyzeStart:(id)sender {
    [self process];
}
@end
