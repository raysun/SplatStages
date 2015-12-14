//
//  SSFSplatfestTimer.h
//  SplatStages
//
//  Created by mac on 2015-12-13.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <SplatStagesFramework/SplatTimer.h>

@interface SSFSplatfestTimer : SplatTimer

@property (strong, atomic) NSAttributedString* teamA;
@property (strong, atomic) NSAttributedString* teamB;
@property (atomic) BOOL showDays;

- (id) initWithDate:(NSDate*) date __unavailable;

//! Initializes a Splatfest timer.
- (id) initWithDate:(NSDate*) date teamA:(NSAttributedString*) teamA teamB:(NSAttributedString*) teamB showDays:(BOOL) showDays;

@end
