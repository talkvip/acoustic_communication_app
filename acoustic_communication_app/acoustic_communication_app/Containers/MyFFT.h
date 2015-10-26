//
//  MyFFT.h
//  acoustic_communication_app
//
//  Created by YuichiSato on 2015/10/21.
//  Copyright © 2015年 佐藤惟知. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Accelerate;

@interface MyFFT : NSObject {
    DSPSplitComplex splitComplex;
    FFTSetup fftSetup;
    unsigned int capacity;
    unsigned int capacityN;	//capacityが2の何乗であるかを保持
    float* window;
    float* windowedInput;
}
@property (assign) unsigned int capacity;
@property (readonly) float* realp;
@property (readonly) float* imagp;
- (id)initWithCapacity:(unsigned int)aCapacity;
- (void)process:(float*)input;

@end
