//
//  SplatDataFetcher.m
//  SplatStages
//
//  Created by mac on 2015-09-25.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SplatStagesFramework/SplatDataFetcher.h>
#import <SplatStagesFramework/SSFRotation.h>
#import <SplatStagesFramework/SplatSquidRingHelper.h>
#import <SplatStagesFramework/SplatUtilities.h>

@interface SplatDataFetcher ()

@end

@implementation SplatDataFetcher

+ (void) downloadFile:(NSString *) urlString completionHandler:(void (^)(NSData* data, NSError* error)) completionHandler {
    NSURLSession* session = [self dataSession];
    NSURL* url = [NSURL URLWithString:urlString];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData* data, NSURLResponse* response, NSError* taskError) {
        completionHandler(data, taskError);
    }] resume];
}

+ (void) downloadAndParseJson:(NSString*) urlString completionHandler:(void (^)(id parsedJson, NSError* error)) completionHandler {
    [self downloadFile:urlString completionHandler:^(NSData* data, NSError* error) {
        if (error) {
            completionHandler(nil, error);
            return;
        }
        
        NSError* jsonError;
        id parsedJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
        
        // Check for a error first
        if (jsonError) {
            completionHandler(nil, error);
            return;
        }
        
        // Call the completion handler.
        completionHandler(parsedJson, nil);
    }];
}

// DEPRECATED
+ (void) requestStageDataWithCallback:(void (^)(NSNumber* mode)) updateCallback errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler {
    [self getSchedule:^{
        updateCallback(@3);
    } errorHandler:^(NSError* error, NSString* when) {
        errorHandler(error, when);
    }];
}

+ (void) getSchedule:(void (^)()) completionHandler errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler {
    NSUserDefaults* userDefaults = [SplatUtilities getUserDefaults];
    
    [self downloadAndParseJson:@"https://oatmealdome.github.io/splatstages/temporary-stage-mapping.json" completionHandler:^(id mappingJson, NSError* mappingError) {
        if (mappingError) {
            errorHandler(mappingError, @""); // TODO
        }
        
        [userDefaults setObject:mappingJson forKey:@"temporaryMappings"];
        [userDefaults synchronize];
        
        [self downloadAndParseJson:@"https://splatoon.ink/schedule.json" completionHandler:^(id scheduleJson, NSError* scheduleError) {
            if (scheduleError) {
                errorHandler(scheduleError, @""); // TODO
                return;
            }
            
            NSMutableArray* schedules = [[NSMutableArray alloc] init];
            BOOL splatfest = [[scheduleJson objectForKey:@"splatfest"] boolValue];
            
            if (!splatfest) {
                NSArray* schedulesRaw = [scheduleJson objectForKey:@"schedule"];
                NSDate* lastRotationEndTime = [NSDate dateWithTimeIntervalSince1970:[[[schedulesRaw lastObject] objectForKey:@"endTime"] longLongValue] / 1000];
                if ([lastRotationEndTime timeIntervalSinceNow] <= 0) {
                    // Schedule is unusable, fallback
                    [self fallbackToSplatNetSchedule:schedules completionHandler:completionHandler errorHandler:^(NSError* error, NSString* when) {
                        errorHandler(error, when);
                    }];
                    return;
                } else {
                    for (NSDictionary* rotationData in [scheduleJson objectForKey:@"schedule"]) {
                        NSDate* startTime = [NSDate dateWithTimeIntervalSince1970:[[rotationData objectForKey:@"startTime"] longLongValue] / 1000];
                        NSDate* endTime = [NSDate dateWithTimeIntervalSince1970:[[rotationData objectForKey:@"endTime"] longLongValue] / 1000];
                        NSString* rankedGamemode = [[rotationData objectForKey:@"ranked"] objectForKey:@"rulesEN"];
                        NSArray* regularStages = [[rotationData objectForKey:@"regular"] objectForKey:@"maps"];
                        NSArray* rankedStages = [[rotationData objectForKey:@"ranked"] objectForKey:@"maps"];
                        NSArray* stages = @[
                                            [[regularStages objectAtIndex:0] objectForKey:@"nameEN"],
                                            [[regularStages objectAtIndex:1] objectForKey:@"nameEN"],
                                            [[rankedStages objectAtIndex:0] objectForKey:@"nameEN"],
                                            [[rankedStages objectAtIndex:1] objectForKey:@"nameEN"]
                                            ];
                        
                        [schedules addObject:[[SSFRotation alloc] initWithStages:stages rankedMode:rankedGamemode startTime:startTime endTime:endTime]];
                    }
                    
                    if ([schedules count] < 3) {
                        // Schedule is incomplete, fallback
                        [self fallbackToSplatNetSchedule:schedules completionHandler:completionHandler errorHandler:^(NSError* error, NSString* when) {
                            errorHandler(error, when);
                        }];
                        return;
                    }
                    
                    [self saveSchedule:schedules];
                    completionHandler();
                }
            } else {
                // TODO handle Splatfest
                
                // We have no schedule, fallback
                [self fallbackToSplatNetSchedule:schedules completionHandler:completionHandler errorHandler:^(NSError* error, NSString* when) {
                    errorHandler(error, when);
                }];
                return;
            }
        }];
    }];
}

+ (void) fallbackToSplatNetSchedule:(NSMutableArray*) schedule completionHandler:(void (^)()) completionHandler errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler {
    // Fill empty spaces with NSNull
    while ([schedule count] < 3) {
        [schedule addObject:[NSNull null]];
    }
    
    if (![SplatSquidRingHelper splatNetCredentialsSet]) {
        // We can't fallback to SplatNet if the user hasn't provided us with a login.
        NSMutableArray* unknownSchedule = [SplatUtilities createUnknownSchedule];
        [SplatUtilities mergeScheduleArray:schedule withArray:unknownSchedule];
        
        [self saveSchedule:schedule];
        completionHandler();
    } else {
        // Request schedule from SplatNet
        [SplatSquidRingHelper getSchedule:^(NSMutableArray* splatNetSchedule) {
            [SplatUtilities mergeScheduleArray:schedule withArray:splatNetSchedule];
            [self saveSchedule:schedule];
            completionHandler();
        } errorHandler:^(NSError* error, NSString* when) {
            errorHandler(error, when);
        }];
    }
}

+ (void) saveSchedule:(NSMutableArray*) array {
    NSUserDefaults* userDefaults = [SplatUtilities getUserDefaults];
    NSData* encodedArray = [NSKeyedArchiver archivedDataWithRootObject:array];
    [userDefaults setObject:encodedArray forKey:@"schedule"];
    [userDefaults synchronize];
}

+ (void) requestFestivalDataWithCallback:(void (^)()) updateCallback errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler {
    [self downloadAndParseJson:@"https://oatmealdome.github.io/splatstages/splatfest.json" completionHandler:^(id splatfestJson, NSError* error) {
        if (error) {
            errorHandler(error, @""); // TODO
        }
        
        NSDictionary* splatfestData = [splatfestJson objectForKey:[SplatUtilities getUserRegion]];
        NSUserDefaults* storedData = [SplatUtilities getUserDefaults];
        [storedData setObject:splatfestData forKey:@"splatfestData"];
        [storedData synchronize];
        
        updateCallback();
    }];
}

+ (NSURLSession*) dataSession {
    static NSURLSession* session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData; // Don't cache, get request each time
        configuration.timeoutIntervalForRequest = 15; // Wait 15 seconds before timing out.
        
        session = [NSURLSession sessionWithConfiguration:configuration];
    });
    
    return session;
}

@end