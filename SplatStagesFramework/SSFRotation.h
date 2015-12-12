//
//  SSFRotation.h
//  SplatStages
//
//  Created by mac on 2015-12-10.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSFRotation : NSObject

@property (strong, atomic) NSDate* startTime;
@property (strong, atomic) NSDate* endTime;
@property (strong, atomic) NSString* regularStageOne;
@property (strong, atomic) NSString* regularStageTwo;
@property (strong, atomic) NSString* rankedGamemode;
@property (strong, atomic) NSString* rankedStageOne;
@property (strong, atomic) NSString* rankedStageTwo;

- (id) initWithStages:(NSArray*) stages rankedMode:(NSString*) rankedMode startTime:(NSDate*) start endTime:(NSDate*) end;

@end
