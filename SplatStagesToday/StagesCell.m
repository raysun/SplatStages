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

- (void) setupWithSchedule:(NSDictionary*) schedule timePeriod:(NSString*) timePeriod {
    [self.rankedGamemodeLabel setHidden:false];
    [self.rankedStageTwoLabel setHidden:false];
    
    [self setupStageLabelsWithStages:[[schedule objectForKey:@"regular"] objectForKey:@"maps"] labelOne:self.regularStageOneLabel labelTwo:self.regularStageTwoLabel];
    
    NSDictionary* rankedInfo = [schedule objectForKey:@"ranked"];
    [self setupStageLabelsWithStages:[rankedInfo objectForKey:@"maps"] labelOne:self.rankedStageOneLabel labelTwo:self.rankedStageTwoLabel];
    [self setLabel:self.rankedGamemodeLabel nameEN:[rankedInfo objectForKey:@"rulesEN"] nameJP:[rankedInfo objectForKey:@"rulesJP"] unknownFallback:NSLocalizedString(@"UNKNOWN_GAMEMODE", nil)];
    
    [self.timePeriod setText:timePeriod];
}

- (void) setupWithSplatfestStages:(NSArray *) stages {
    [self.rankedGamemodeLabel setHidden:true];
    [self.rankedStageTwoLabel setHidden:true];
    
    [self setLabel:self.regularStageOneLabel nameEN:[stages objectAtIndex:0] nameJP:nil unknownFallback:NSLocalizedString(@"UNKNOWN_MAP", nil)];
    [self setLabel:self.regularStageTwoLabel nameEN:[stages objectAtIndex:1] nameJP:nil unknownFallback:NSLocalizedString(@"UNKNOWN_MAP", nil)];
    [self setLabel:self.rankedStageOneLabel nameEN:[stages objectAtIndex:2] nameJP:nil unknownFallback:NSLocalizedString(@"UNKNOWN_MAP", nil)];
    
    [self.timePeriod setText:NSLocalizedString(@"TODAY_TIME_PERIOD_1", nil)];
}

- (void) setupWithUnknownStages:(NSString*) timePeriod {
    NSArray* unknownStages = @[
                         @{
                             @"nameEN" : @"UNKNOWN_MAP"
                         },
                         @{
                             @"nameEN" : @"UNKNOWN_MAP"
                         }
                         ];
    
    [self.rankedGamemodeLabel setHidden:false];
    [self.rankedStageTwoLabel setHidden:false];
    
    [self setupStageLabelsWithStages:unknownStages labelOne:self.regularStageOneLabel labelTwo:self.regularStageTwoLabel];
    [self setupStageLabelsWithStages:unknownStages labelOne:self.rankedStageOneLabel labelTwo:self.rankedStageTwoLabel];
    [self.rankedGamemodeLabel setText:NSLocalizedString(@"UNKNOWN_GAMEMODE", nil)];
    
    [self.timePeriod setText:NSLocalizedString(timePeriod, nil)];
}

- (void) setupStageLabelsWithStages:(NSArray*) stages labelOne:(UILabel*) labelOne labelTwo:(UILabel*) labelTwo {
    [self setLabel:labelOne nameEN:[[stages objectAtIndex:0] objectForKey:@"nameEN"] nameJP:[[stages objectAtIndex:0] objectForKey:@"nameJP"] unknownFallback:NSLocalizedString(@"UNKNOWN_MAP", nil)];
    [self setLabel:labelTwo nameEN:[[stages objectAtIndex:1] objectForKey:@"nameEN"] nameJP:[[stages objectAtIndex:0] objectForKey:@"nameJP"] unknownFallback:NSLocalizedString(@"UNKNOWN_MAP", nil)];
}

- (void) setLabel:(UILabel*) label nameEN:(NSString*) nameEN nameJP:(NSString*) nameJP unknownFallback:(NSString*) unknownFallback {
    NSString* localizable = [SplatUtilities toLocalizable:nameEN];
    NSString* localizedText = NSLocalizedString(localizable, nil);
    if ([localizedText isEqualToString:localizable]) {
        // We don't have data for this string! We have the Japanese (and maybe English)
        // localization(s) for this string. If the user's language is Japanese, great!
        // If not, we'll try to use the English localization.
        if (![nameEN canBeConvertedToEncoding:NSISOLatin1StringEncoding]) {
            // Uh-oh, splatoon.ink hasn't provided an English string and has instead repeated nameJP.
            // Check our temporary mapping data to see if we can find an English localization.
            // If there is no temporary mapping, then we just use unknownFallback.
            NSDictionary* temporaryMappings = [[SplatUtilities getUserDefaults] objectForKey:@"temporaryMappings"];
            NSString* temporaryMapping = [temporaryMappings objectForKey:nameEN];
            nameEN = (temporaryMapping == nil) ? unknownFallback: temporaryMapping;
        }
        
        [label setText:([SplatUtilities isDeviceLangaugeJapanese]) ? nameJP : nameEN];
        
        NSLog(@"No localizable string for (en) \"%@\" (jp) \"%@\"!", nameEN, nameJP);
    } else {
        // Alright, we have data for this stage!
        label.text = localizedText;
    }
}

@end
