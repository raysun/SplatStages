//
//  SplatTimer.m
//  SplatStages
//
//  Created by mac on 2015-09-25.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSAttributedString+CCLFormat.h"

#import "SplatTimer.h"

@implementation SplatTimer

- (id) initWithDate:(NSDate*) date {
    if (self = [super init]) {
        [self setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
        [self setCalendarUnits:NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond];
        [self setCountdownDate:date];
    }
    return self;
}

- (void) start {
    if (!self.internalTimer) {
        self.internalTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick) userInfo:nil repeats:true];
    }
}

- (void) stop {
    if (self.internalTimer) {
        [self.internalTimer invalidate];
        self.internalTimer = nil;
    }
}

- (void) timerTick {
    if ([self.countdownDate timeIntervalSinceNow] > 0) {
        NSDateComponents* components = [self.calendar components:self.calendarUnits fromDate:[NSDate date] toDate:self.countdownDate options:0];
        [self timerTickWithComponents:components];
    } else {
        [self timerFinished];
        [self stop];
    }
}

- (void) timerTickWithComponents:(NSDateComponents*) components {
    // Do nothing, this should be overrided by a subclass.
}

- (void) timerFinished {
    // Do nothing, this should be ovverided by a subclass.
}

@end
