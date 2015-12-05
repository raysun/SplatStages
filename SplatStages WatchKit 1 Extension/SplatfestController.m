//
//  SplatfestController.m
//  SplatStages
//
//  Created by mac on 2015-11-28.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import "NSAttributedString+CCLFormat.h"

#import <SplatStagesFramework/SplatDataFetcher.h>
#import <SplatStagesFramework/SplatUtilities.h>

#import "SplatfestController.h"

@interface SplatfestController ()

@end

@implementation SplatfestController

- (void) awakeWithContext:(id) context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void) willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    // Check if setup is finished before attempting to fetch data.
    if ([SplatUtilities getSetupFinished]) {
        [SplatDataFetcher requestFestivalDataWithCallback:^() {
            [self setupView];
        } errorHandler:^(NSError* error, NSString* when) {
            // TODO show error view controller
            NSLog(@"error! %@", when);
        }];
    } else {
        [self.messageLabel setText:NSLocalizedString(@"WATCH_FINISH_SETUP_FIRST", nil)];
    }
}

- (void) didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void) setupView {
    // Get the time period of the Splatfest
    NSDictionary* splatfestData = [[SplatUtilities getUserDefaults] objectForKey:@"splatfestData"];
    NSDate* splatfestStart = [NSDate dateWithTimeIntervalSince1970:[[splatfestData objectForKey:@"startTime"] longLongValue]];
    NSDate* splatfestEnd = [NSDate dateWithTimeIntervalSince1970:[[splatfestData objectForKey:@"endTime"] longLongValue]];
    
    NSArray* teams = [splatfestData objectForKey:@"teams"];
    NSAttributedString* teamA = [SplatUtilities getSplatfestTeamName:[teams objectAtIndex:0]];
    NSAttributedString* teamB = [SplatUtilities getSplatfestTeamName:[teams objectAtIndex:1]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // We need to be on the UI thread to change the layout.
        // Check if a Splatfest is in the future, has started, or has passed.
        if ([splatfestStart timeIntervalSinceNow] > 0.0) { // Splatfest is in the future.
            // Setup visibilities.
            [self.separator setHidden:true];
            [self.stagesGroup setHidden:true];
            
            // Setup the timer.
            self.timer = [[SplatTimer alloc] initFestivalTimerWithDate:splatfestStart label:self.messageLabel textString:NSLocalizedString(@"SPLATFEST_UPCOMING_COUNTDOWN", nil) timeString:NSLocalizedString(@"SPLATFEST_UPCOMING_COUNTDOWN_TIME", nil) teamA:teamA teamB:teamB useThreeNumbers:false timerFinishedHandler:^(NSAttributedString* teamA, NSAttributedString* teamB) {
                [self setupView];
            }];
        } else if ([splatfestStart timeIntervalSinceNow] < 0.0 && [splatfestEnd timeIntervalSinceNow] > 0.0) { // The Splatfest is going on right now!
            // Setup visbilities.
            [self.separator setHidden:false];
            [self.stagesGroup setHidden:false];
            
            // Set the map labels.
            NSArray* maps = [splatfestData objectForKey:@"maps"];
            [SplatUtilities setLabel:self.mapOne nameEN:[maps objectAtIndex:0] nameJP:nil unknownLocalizable:@"UNKNOWN_MAP"];
            [SplatUtilities setLabel:self.mapTwo nameEN:[maps objectAtIndex:1] nameJP:nil unknownLocalizable:@"UNKNOWN_MAP"];
            [SplatUtilities setLabel:self.mapThree nameEN:[maps objectAtIndex:2] nameJP:nil unknownLocalizable:@"UNKNOWN_MAP"];
            
            // Setup the timer.
            self.timer = [[SplatTimer alloc] initFestivalTimerWithDate:splatfestStart label:self.messageLabel textString:NSLocalizedString(@"SPLATFEST_FINISH_COUNTDOWN", nil) timeString:NSLocalizedString(@"SPLATFEST_FINISH_COUNTDOWN_TIME", nil) teamA:teamA teamB:teamB useThreeNumbers:true timerFinishedHandler:^(NSAttributedString* teamA, NSAttributedString* teamB) {
                [self setupView];
            }];
        } else { // The Splatfest has ended.
            // Setup visbilities.
            [self.separator setHidden:true];
            [self.stagesGroup setHidden:true];
            
            // Set the label.
            [self.messageLabel setAttributedText:[NSAttributedString attributedStringWithFormat:NSLocalizedString(@"SPLATFEST_FINISHED", nil), teamA, teamB]];
        }
    });
}

@end



