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


@class MPLandmark;
@class PresagePreprocessing;

@protocol PresagePreprocessingDelegate <NSObject>

- (void)frameWillUpdate:(PresagePreprocessing *)tracker
   didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer
              timestamp:(long)timestamp;

- (void)frameDidUpdate:(PresagePreprocessing *)tracker
  didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer;

- (void)statusCodeChanged:(PresagePreprocessing *)tracker
               statusCode:(StatusCode)statusCode;

- (void)timerChanged:(double)timerValue;
- (void)receiveJsonData:(NSDictionary *)jsonData;

@end

@interface PresagePreprocessing : NSObject
- (instancetype)init;

- (void)start:(double)spotDuration;
- (void)stop;
- (void)buttonStateChangedInFramework:(BOOL)isRecording;
- (NSString *)getStatusHint:(StatusCode)statusCode;

@property(weak, nonatomic) id <PresagePreprocessingDelegate> delegate;
@end

@interface MPLandmark : NSObject
@property(nonatomic, readonly) float x;
@property(nonatomic, readonly) float y;
@property(nonatomic, readonly) float z;
@end
