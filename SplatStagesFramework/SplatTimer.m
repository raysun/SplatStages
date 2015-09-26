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

- (id) initRotationTimerWithDate:(NSDate*) date labelOne:(UILabel*) labelOne labelTwo:(UILabel*) labelTwo textString:(NSString*) textString timeString:(NSString*) timeString timerFinishedHandler:(void (^)()) timerFinishedHandler {
    if (self = [super init]) {
        // Initialize variables
        self.countdownDate = date;
        self.labelOne = labelOne;
        self.labelTwo = labelTwo;
        self.textString = textString;
        self.timeString = timeString;
        self.timerFinishedHandler = timerFinishedHandler;
        
        // Setup internals
        self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        self.calendarUnits = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        self.selector = @selector(runRotationTimer);
        self.internalTimer = [self createTimer];
    }
    return self;
}

- (id) initFestivalTimerWithDate:(NSDate*) date label:(UILabel*) label textString:(NSString*) textString timeString:(NSString*) timeString teamA:(NSAttributedString*) teamA teamB:(NSAttributedString*) teamB useThreeNumbers:(BOOL) useThreeNumbers timerFinishedHandler:(void (^)()) timerFinishedHandler {
    if (self = [super init]) {
        // Initialize variables
        self.countdownDate = date;
        self.labelOne = label;
        self.textString = textString;
        self.timeString = timeString;
        self.teamA = teamA;
        self.teamB = teamB;
        self.useThreeNumbers = useThreeNumbers;
        self.timerFinishedHandler = timerFinishedHandler;
        
        // Setup internals
        self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        self.calendarUnits = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        if (!useThreeNumbers) {
            self.calendarUnits = self.calendarUnits | NSCalendarUnitDay;
        }
        self.selector = @selector(runFestivalTimer);
        self.internalTimer = [self createTimer];
    }
    return self;
}

- (void) runRotationTimer {
    if ([self.countdownDate timeIntervalSinceNow] <= 0.0) {
        self.timerFinishedHandler();
        [self invalidate];
    } else {
        NSDateComponents* components = [self.calendar components:self.calendarUnits fromDate:[NSDate date] toDate:self.countdownDate options:0];
        NSString* rotationCountdownText = [NSString stringWithFormat:self.textString, [components hour], [components minute], [components second]];;
        [self.labelOne setText:rotationCountdownText];
        if (self.labelTwo) {
            [self.labelTwo setText:rotationCountdownText];
        }
    }
}

- (void) runFestivalTimer {
    if ([self.countdownDate timeIntervalSinceNow] <= 0.0) {
        self.timerFinishedHandler();
        [self invalidate];
    } else {
        NSDateComponents* components = [self.calendar components:self.calendarUnits fromDate:[NSDate date] toDate:self.countdownDate options:0];
        NSString* countdownTime;
        if (self.useThreeNumbers) {
            countdownTime = [NSString stringWithFormat:self.timeString, [components hour], [components minute], [components second]];
        } else {
            countdownTime = [NSString stringWithFormat:self.timeString, [components day], [components hour], [components minute], [components second]];
        }
        NSAttributedString* countdownText = [NSAttributedString attributedStringWithFormat:self.textString, self.teamA, self.teamB, countdownTime];
        [self.labelOne setAttributedText:countdownText];
    }
}

- (NSTimer*) createTimer {
    return [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:self.selector userInfo:nil repeats:true];
}

- (void) pause {
    [self invalidate];
}

- (void) start {
    if (!self.internalTimer) {
        self.internalTimer = [self createTimer];
    }
}

- (void) invalidate {
    if (self.internalTimer) {
        [self.internalTimer invalidate];
        self.internalTimer = nil;
    }
}

@end
