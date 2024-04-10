//
//  PresagePreprocessing.h
//  PresagePreprocessing
//
//  Created by Yuki Yamato on 2021/05/05 in form of MPIrisTracker / MPIrisTrackerDelegate.
//
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

@class MPLandmark;
@class PresagePreprocessing;

@protocol PresagePreprocessingDelegate <NSObject>

- (void)frameWillUpdate:(PresagePreprocessing *)tracker
   didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer
              timestamp:(long)timestamp;

- (void)frameDidUpdate:(PresagePreprocessing *)tracker
  didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer;

- (void)errorHappened:(int)errorCode;
- (void)timerChanged:(double)timerValue;
- (void)receiveJsonData:(NSDictionary *)jsonData;

@end

@interface PresagePreprocessing : NSObject
- (instancetype)init;

- (void)start;
- (void)stop;
- (void)buttonStateChangedInFramework:(BOOL)isRecording;

@property(weak, nonatomic) id <PresagePreprocessingDelegate> delegate;
@end

@interface MPLandmark : NSObject
@property(nonatomic, readonly) float x;
@property(nonatomic, readonly) float y;
@property(nonatomic, readonly) float z;
@end
