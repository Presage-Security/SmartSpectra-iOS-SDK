//
//  PresagePreprocessing.h
//  PresagePreprocessing Objective C++ Binding Layer
//
//  Credits:
//  Inspired by MPIrisTracker / MPIrisTrackerDelegate code by Yuki Yamato on 2021/05/05.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <AVFoundation/AVFoundation.h>
#ifdef PRESAGE_PREPROCESSING_BUILD
#import "modules/messages/Status.pbobjc.h"
#else
#import "Status.pbobjc.h"
#endif

typedef NS_ENUM(NSInteger, PresageMode) {
    PresageModeSpot,
    PresageModeContinuous
};

@class PresagePreprocessing;

@protocol PresagePreprocessingDelegate <NSObject>

- (void)frameWillUpdate:(PresagePreprocessing *)tracker
   didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer
              timestamp:(long)timestamp;

- (void)frameDidUpdate:(PresagePreprocessing *)tracker
  didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer;

- (void)statusCodeChanged:(PresagePreprocessing *)tracker
               statusCode:(StatusCode)statusCode;

- (void)metricsBufferChanged:(PresagePreprocessing *)tracker
               serializedBytes:(NSData *)data;

- (void)timerChanged:(double)timerValue;

- (void)receiveDenseFacemeshPoints:(NSArray<NSNumber *> *)points;

@end

@interface PresagePreprocessing : NSObject

@property(nonatomic, weak) id <PresagePreprocessingDelegate> delegate;
@property(nonatomic, assign) PresageMode mode;
@property(nonatomic, copy) NSString *apiKey;
@property(nonatomic, copy) NSString *graphName;
@property(nonatomic, assign) AVCaptureDevicePosition cameraPosition;

- (instancetype)init:(NSString* _Nonnull)apiKey mode:(PresageMode)mode withCameraPosition:(AVCaptureDevicePosition)cameraPosition;

- (void)start:(double)spotDuration;
- (void)stop;
- (void)buttonStateChangedInFramework:(BOOL)isRecording;
- (NSString * _Nonnull)getStatusHint:(StatusCode)statusCode;
- (void)setCameraPosition:(AVCaptureDevicePosition)cameraPosition;
- (void)setMode:(PresageMode)mode;

@end
