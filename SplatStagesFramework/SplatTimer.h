//
//  SplatTimer.h
//  SplatStages
//
//  Created by mac on 2015-09-25.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SplatStagesFramework/SplatLabel.h>

@interface SplatTimer : NSObject

@property NSDate* countdownDate;
@property PLATFORM_SPECIFIC_LABEL* labelOne;
@property PLATFORM_SPECIFIC_LABEL* labelTwo;
@property NSString* textString;
@property NSString* timeString;
@property NSAttributedString* teamA;
@property NSAttributedString* teamB;
@property BOOL useThreeNumbers;
@property (nonatomic, copy) void (^timerFinishedHandler)();
@property (nonatomic, copy) void (^festivalTimerFinishedHandler)(NSAttributedString* teamA, NSAttributedString* teamB);

// Internals
@property NSCalendar* calendar;
@property int calendarUnits;
@property SEL selector;
@property NSTimer* internalTimer;

//! Inits the SplatTimer instance as a rotation timer.
- (id) initRotationTimerWithDate:(NSDate*) date labelOne:(PLATFORM_SPECIFIC_LABEL*) labelOne labelTwo:(PLATFORM_SPECIFIC_LABEL*) labelTwo textString:(NSString*) textString timerFinishedHandler:(void (^)()) timerFinishedHandler;

//! Inits the SplatTimer instance as a Splatfest coundown timer.
- (id) initFestivalTimerWithDate:(NSDate*) date label:(PLATFORM_SPECIFIC_LABEL*) label textString:(NSString*) textString timeString:(NSString*) timeString teamA:(NSAttributedString*) teamA teamB:(NSAttributedString*) teamB useThreeNumbers:(BOOL) useThreeNumbers timerFinishedHandler:(void (^)(NSAttributedString* teamA, NSAttributedString* teamB)) timerFinishedHandler;

//! Starts the timer if it has been stopped.
- (void) start;

//! Stops the timer if it has been started.
- (void) invalidate;

@end
