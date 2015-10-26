//
//  MyFFT.m
//  acoustic_communication_app
//
//  Created by YuichiSato on 2015/10/21.
//  Copyright © 2015年 佐藤惟知. All rights reserved.
//

#import "MyFFT.h"

@implementation MyFFT

@synthesize capacity;
- (float*)realp
{
    return splitComplex.realp;
}
- (float*)imagp
{
    return splitComplex.imagp;
}

- (id)initWithCapacity:(unsigned int)aCapacity
{
    if (self = [super init]) {
        
        // aCapacityが2のn乗になっているか調べます
        // aCapacityが2のn乗になっていない場合は、
        // 2のn乗になるように調整します。
        // (厳密にやりたい場合は0のチェック等も行ってください)
        capacityN = log(aCapacity) / log(2);
        capacity = 1 << capacityN;
        
        NSLog(@"capacity: %d n: %d", capacity, capacityN);
        
        // FFTの設定をします
        fftSetup = vDSP_create_fftsetup(capacityN+1, FFT_RADIX2);
        
        // FFTに使う配列を用意します
        splitComplex.realp = calloc(capacity, sizeof(float));
        splitComplex.imagp = calloc(capacity, sizeof(float));
        
        // 窓用の配列を用意します
        window = calloc(capacity, sizeof(float));
        windowedInput = calloc(capacity, sizeof(float));
        
        // 窓を作ります
        vDSP_hann_window(window, capacity, 0);
    }
    return self;
}

- (void)process:(float*)input
{
    // 窓をかけます
    vDSP_vmul(input, 1, window, 1, windowedInput, 1, capacity);
    
    // 複素数に変換します
    for (int i=0; i<capacity; i++) {
        splitComplex.realp[i] = windowedInput[i];
        splitComplex.imagp[i] = 0.0f;
    }
    
    // フーリエ変換します
    vDSP_fft_zrip(fftSetup, &splitComplex, 1, capacityN+1, FFT_FORWARD);
}

- (void)dealloc
{
    // FFTに使う配列を解放します
    free(splitComplex.realp);
    free(splitComplex.imagp);
    
    // 窓用の配列を解放します
    free(window);
    free(windowedInput);
    
    // FFTの設定を削除します
    vDSP_destroy_fftsetup(fftSetup);
    //[super dealloc];
}

@end
