//
//  StagesCell.m
//  SplatStages
//
//  Created by mac on 2015-09-27.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <SplatStagesFramework/SplatUtilities.h>

#import "StagesCell.h"

@implementation StagesCell

- (void) setupWithRotation:(SSFRotation*) rotation timePeriod:(NSString*) timePeriod {
    [self.rankedGamemodeLabel setHidden:false];
    [self.rankedStageTwoLabel setHidden:false];
    
    [self setLabel:self.regularStageOneLabel string:[rotation regularStageOne] unknownFallback:@"UNKNOWN_MAP"];
    [self setLabel:self.regularStageTwoLabel string:[rotation regularStageTwo] unknownFallback:@"UNKNOWN_MAP"];
    [self setLabel:self.rankedGamemodeLabel string:[rotation rankedGamemode] unknownFallback:@"UNKNOWN_GAMEMODE"];
    [self setLabel:self.rankedStageOneLabel string:[rotation rankedStageOne] unknownFallback:@"UNKNOWN_MAP"];
    [self setLabel:self.rankedStageTwoLabel string:[rotation rankedStageTwo] unknownFallback:@"UNKNOWN_MAP"];
    [self.timePeriod setText:NSLocalizedString(timePeriod, nil)];
}

- (void) setupWithSplatfestStages:(NSArray *) stages {
    [self.rankedGamemodeLabel setHidden:true];
    [self.rankedStageTwoLabel setHidden:true];
    
    [self setLabel:self.regularStageOneLabel string:[stages objectAtIndex:0] unknownFallback:@"UNKNOWN_MAP"];
    [self setLabel:self.regularStageTwoLabel string:[stages objectAtIndex:1] unknownFallback:@"UNKNOWN_MAP"];
    [self setLabel:self.rankedStageOneLabel string:[stages objectAtIndex:2] unknownFallback:@"UNKNOWN_MAP"];
    
    [self.timePeriod setText:NSLocalizedString(@"TODAY_TIME_PERIOD_1", nil)];
}
- (void) setLabel:(UILabel*) label string:(NSString*) string unknownFallback:(NSString*) unknownFallback {
    NSString* localizable = [SplatUtilities toLocalizable:string];
    NSString* localizedText = NSLocalizedString(localizable, nil);
    if ([localizedText isEqualToString:localizable]) {
        [label setText:NSLocalizedString(unknownFallback, nil)];
        NSLog(@"No localizable string for \"%@\"!", string);
    } else {
        // Alright, we have data for this stage!
        label.text = localizedText;
    }
}

@end
