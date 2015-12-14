//
//  SSFRotationTimer.m
//  SplatStages
//
//  Created by mac on 2015-12-13.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <SplatStagesFramework/SSFRotationTimer.h>
#import <SplatStagesFramework/SplatUtilities.h>

@implementation SSFRotationTimer

- (void) timerTickWithComponents:(NSDateComponents*) components {
    NSDictionary* userInfo = @{
                               @"countdownString" : [NSString stringWithFormat:[SplatUtilities localizeString:@"ROTATION_COUNTDOWN"], [components hour], [components minute], [components second]]
                               };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"rotationTimerTick" object:nil userInfo:userInfo];
}

- (void) timerFinished {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"rotationTimerFinished" object:nil];
}

@end
