//
//  InterfaceController.m
//  SplatStages WatchKit 1 Extension
//
//  Created by mac on 2015-11-21.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <SplatStagesFramework/SplatDataFetcher.h>
#import <SplatStagesFramework/SplatUtilities.h>

#import "InterfaceController.h"

@interface InterfaceController ()

@end


@implementation InterfaceController

- (void) awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
}

- (void) willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    // Check if we need to update the schedule.
    if ([SplatUtilities isScheduleOutdated]) {
        [SplatDataFetcher requestStageDataWithCallback:^(NSNumber* mode) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self setTimer];
            });
        } errorHandler:^(NSError* error, NSString* when) {
            // TODO: display error view controller
        }];
    } else {
        if (self.rotationTimer) {
            [self.rotationTimer start];
        } else {
            [self setTimer];
        }
    }
}

- (void) didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    
    // Stop the timer
    if (self.rotationTimer) {
        [self.rotationTimer invalidate];
    }
}

- (void) setTimer {
    NSArray* schedule = [[SplatUtilities getUserDefaults] objectForKey:@"schedule"];
    NSDate* nextRotation = [NSDate dateWithTimeIntervalSince1970:[[[schedule objectAtIndex:0] objectForKey:@"endTime"] longLongValue] / 1000];
    
    self.rotationTimer = [[SplatTimer alloc] initRotationTimerWithDate:nextRotation labelOne:self.rotationLabel labelTwo:nil textString:NSLocalizedString(@"ROTATION_COUNTDOWN", nil) timerFinishedHandler:^{
        [self.rotationLabel setText:NSLocalizedString(@"ROTATION_NOW", nil)];
    }];
    [self.rotationTimer start];
}

@end



