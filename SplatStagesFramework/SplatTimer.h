//
//  SplatTimer.h
//  SplatStages
//
//  Created by mac on 2015-09-25.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UILabel.h>

#import <WatchKit/WKInterfaceLabel.h>

@interface SplatTimer : NSObject

@property NSDate* countdownDate;
#ifdef TARGET_OS_WATCH
@property WKInterfaceLabel* labelOne;
@property WKInterfaceLabel* labelTwo;
// if we ever support OS X in the future:
// #elif !TARGET_OS_IPHONE
#else
@property UILabel* labelOne;
@property UILabel* labelTwo;
#endif
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
- (id) initRotationTimerWithDate:(NSDate*) date labelOne:(id) labelOne labelTwo:(id) labelTwo textString:(NSString*) textString timerFinishedHandler:(void (^)()) timerFinishedHandler;

//! Inits the SplatTimer instance as a Splatfest coundown timer.
- (id) initFestivalTimerWithDate:(NSDate*) date label:(id) label textString:(NSString*) textString timeString:(NSString*) timeString teamA:(NSAttributedString*) teamA teamB:(NSAttributedString*) teamB useThreeNumbers:(BOOL) useThreeNumbers timerFinishedHandler:(void (^)(NSAttributedString* teamA, NSAttributedString* teamB)) timerFinishedHandler;

//! Starts the timer if it has been stopped.
- (void) start;

//! Stops the timer if it has been started.
- (void) invalidate;

@end
