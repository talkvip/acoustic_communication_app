//
//  RecordViewController.h
//  acoustic_communication_app
//
//  Created by YuichiSato on 2015/10/19.
//  Copyright © 2015年 佐藤惟知. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
@import AVFoundation;

@interface RecordViewController : UIViewController

@property (nonatomic)AVAudioRecorder *recorder;
@property (nonatomic)AVAudioSession *session;
@property (nonatomic)AVAudioPlayer *player;

@property (weak, nonatomic) IBOutlet UIButton *RecordButton;
- (IBAction)recordPushed:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *PlayButton;
- (IBAction)playPushed:(id)sender;


@end
