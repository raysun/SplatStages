//
//  SplatTimer.h
//  SplatStages
//
//  Created by mac on 2015-09-25.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SplatTimer : NSObject

@property (strong, atomic) NSDate* countdownDate;
@property (strong, atomic) NSCalendar* calendar;
@property (atomic) NSInteger calendarUnits;
@property (strong, atomic) NSDateComponents* dateComponents;
@property (strong, atomic) NSTimer* internalTimer;
@property (copy, nonatomic) void (^completionHandler)();

- (id) init __unavailable;

//! Creates a timer instance with a date to countdown to
- (id) initWithDate:(NSDate*) date;

//! Starts the timer if it has been stopped.
- (void) start;

//! Stops the timer if it has been started.
- (void) stop;

//! Called each second by the internal timer.
- (void) timerTickWithComponents:(NSDateComponents*) components;

//! Called when the timer finishes.
- (void) timerFinished;

@end
