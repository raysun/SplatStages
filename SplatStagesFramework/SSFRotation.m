//
//  SSFRotation.m
//  SplatStages
//
//  Created by mac on 2015-12-10.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import "SSFRotation.h"

@implementation SSFRotation

- (id) init {
    if (self = [super init]) {
        self.startTime = [NSDate dateWithTimeIntervalSince1970:0];
        self.endTime = [NSDate dateWithTimeIntervalSince1970:0];
        self.regularStageOne = @"UNKNOWN_MAP";
        self.regularStageTwo = @"UNKNOWN_MAP";
        self.rankedGamemode = @"UNKNOWN_GAMEMODE";
        self.rankedStageOne = @"UNKNOWN_MAP";
        self.rankedStageTwo = @"UNKNOWN_MAP";
    }
    return self;
}

- (id) initWithStages:(NSArray*) stages rankedMode:(NSString*) rankedMode startTime:(NSDate*) start endTime:(NSDate*) end {
    if (self = [super init]) {
        self.startTime = start;
        self.endTime = end;
        self.regularStageOne = [stages objectAtIndex:0];
        self.regularStageTwo = [stages objectAtIndex:2];
        self.rankedGamemode = rankedMode;
        self.rankedStageOne = [stages objectAtIndex:1];
        self.rankedStageTwo = [stages objectAtIndex:3];
    }
    return self;
}

- (id) initWithCoder:(NSCoder*) decoder {
    if (self = [super init]) {
        self.startTime = [decoder decodeObjectForKey:@"startTime"];
        self.endTime = [decoder decodeObjectForKey:@"endTime"];
        self.regularStageOne = [decoder decodeObjectForKey:@"regularStageOne"];
        self.regularStageTwo = [decoder decodeObjectForKey:@"regularStageTwo"];
        self.rankedGamemode = [decoder decodeObjectForKey:@"rankedGamemode"];
        self.rankedStageOne = [decoder decodeObjectForKey:@"rankedStageOne"];
        self.rankedStageTwo = [decoder decodeObjectForKey:@"rankedStageTwo"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*) encoder {
    [encoder encodeObject:self.startTime forKey:@"startTime"];
    [encoder encodeObject:self.endTime forKey:@"endTime"];
    [encoder encodeObject:self.regularStageOne forKey:@"regularStageOne"];
    [encoder encodeObject:self.regularStageTwo forKey:@"regularStageTwo"];
    [encoder encodeObject:self.rankedGamemode forKey:@"rankedGamemode"];
    [encoder encodeObject:self.rankedStageOne forKey:@"rankedStageOne"];
    [encoder encodeObject:self.rankedStageTwo forKey:@"rankedStageTwo"];
}

/*
 - (void)saveCustomObject:(MyObject *)object key:(NSString *)key {
 NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
 [defaults setObject:encodedObject forKey:key];
 [defaults synchronize];
 
 }
 
 - (MyObject *)loadCustomObjectWithKey:(NSString *)key {
 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
 NSData *encodedObject = [defaults objectForKey:key];
 MyObject *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
 return object;
 }
 */

@end
