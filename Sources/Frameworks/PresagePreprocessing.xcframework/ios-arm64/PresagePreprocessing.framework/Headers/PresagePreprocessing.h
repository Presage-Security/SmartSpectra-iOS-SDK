//
//  PresagePreprocessing.h
//  PresagePreprocessing Objective C++ Binding Layer
//
//  Credits:
//  Inspired by MPIrisTracker / MPIrisTrackerDelegate code by Yuki Yamato on 2021/05/05.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#ifdef PRESAGE_PREPROCESSING_BUILD
#import "modules/messages/Status.pbobjc.h"
#else
#import "Status.pbobjc.h"
#endif

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
- (instancetype)init:(NSString* _Nonnull)apiKey;

- (void)start:(double)spotDuration;
- (void)stop;
- (void)buttonStateChangedInFramework:(BOOL)isRecording;
- (NSString * _Nonnull)getStatusHint:(StatusCode)statusCode;

@property(weak, nonatomic) id <PresagePreprocessingDelegate> delegate;
@end
