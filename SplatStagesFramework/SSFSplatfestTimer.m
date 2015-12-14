//
//  SSFSplatfestTimer.m
//  SplatStages
//
//  Created by mac on 2015-12-13.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import "NSAttributedString+CCLFormat.h"

#import <SplatStagesFramework/SSFSplatfestTimer.h>
#import <SplatStagesFramework/SplatUtilities.h>

@implementation SSFSplatfestTimer

- (id) initWithDate:(NSDate*) date teamA:(NSAttributedString*) teamA teamB:(NSAttributedString*) teamB showDays:(BOOL) showDays {
    if (self = [super initWithDate:date]) {
        [self setTeamA:teamA];
        [self setTeamB:teamB];
        [self setShowDays:showDays];
    }
    return self;
}

- (void) timerTickWithComponents:(NSDateComponents*) components {
    NSDictionary* userInfo;
    if (self.showDays) {
        userInfo = @{
                     @"countdownString" : [NSAttributedString attributedStringWithFormat:[SplatUtilities localizeString:@"SPLATFEST_UPCOMING_COUNTDOWN"], self.teamA, self.teamB, [NSString stringWithFormat:[SplatUtilities localizeString:@"SPLATFEST_UPCOMING_COUNTDOWN_TIME"], [components day], [components hour], [components minute], [components second]]],
                     @"showDays" : @(true)
                     };
    } else {
        userInfo = @{
                     @"countdownString" : [NSAttributedString attributedStringWithFormat:[SplatUtilities localizeString:@"SPLATFEST_FINISH_COUNTDOWN"], self.teamA, self.teamB, [NSString stringWithFormat:[SplatUtilities localizeString:@"SPLATFEST_FINISH_COUNTDOWN_TIME"], [components hour], [components minute], [components second]]],
                     @"showDays" : @(false)
                     };
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"splatfestTimerTick" object:nil userInfo:userInfo];
}

- (void) timerFinished {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"splatfestTimerFinished" object:nil];
    [self stop];
}

@end
