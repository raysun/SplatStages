//
//  ScheduleController.m
//  SplatStages
//
//  Created by mac on 2015-11-21.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <SplatStagesFramework/SplatDataFetcher.h>
#import <SplatStagesFramework/SplatUtilities.h>

#import "ScheduleController.h"

@interface ScheduleController ()

@end

@implementation ScheduleController

- (void) awakeWithContext:(id) context {
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
                [self setStages];
            });
        } errorHandler:^(NSError* error, NSString* when) {
            // TODO: display error view controller
        }];
    } else {
        [self setStages];
    }
}

- (void) didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void) setStages {
    NSUserDefaults* userDefaults = [SplatUtilities getUserDefaults];
    NSDictionary* schedule = [[userDefaults objectForKey:@"schedule"] objectAtIndex:self.selectedRotation];
    
    NSArray* regularMaps = [[schedule objectForKey:@"regular"] objectForKey:@"maps"];
    [SplatUtilities setLabel:self.regularMapOne nameEN:[[regularMaps objectAtIndex:0] objectForKey:@"nameEN"] nameJP:[[regularMaps objectAtIndex:0] objectForKey:@"nameJP"] unknownLocalizable:@"UNKNOWN_MAP"];
    [SplatUtilities setLabel:self.regularMapTwo nameEN:[[regularMaps objectAtIndex:1] objectForKey:@"nameEN"] nameJP:[[regularMaps objectAtIndex:1] objectForKey:@"nameJP"] unknownLocalizable:@"UNKNOWN_MAP"];
    
    NSDictionary* ranked = [schedule objectForKey:@"ranked"];
    NSArray* rankedMaps = [ranked objectForKey:@"maps"];
    [SplatUtilities setLabel:self.rankedGamemode nameEN:[ranked objectForKey:@"rulesEN"] nameJP:[ranked objectForKey:@"rulesJP"] unknownLocalizable:@"UNKNOWN_GAMEMODE"];
    [SplatUtilities setLabel:self.rankedMapOne nameEN:[[rankedMaps objectAtIndex:0] objectForKey:@"nameEN"] nameJP:[[rankedMaps objectAtIndex:0] objectForKey:@"nameJP"] unknownLocalizable:@"UNKNOWN_MAP"];
    [SplatUtilities setLabel:self.rankedMapTwo nameEN:[[rankedMaps objectAtIndex:1] objectForKey:@"nameEN"] nameJP:[[rankedMaps objectAtIndex:1] objectForKey:@"nameJP"] unknownLocalizable:@"UNKNOWN_MAP"];
}

- (IBAction) nowPressed {
}

- (IBAction) nextPressed {
}

- (IBAction) laterPressed {
}

@end



