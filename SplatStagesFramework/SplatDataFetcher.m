//
//  SplatDataFetcher.m
//  SplatStages
//
//  Created by mac on 2015-09-25.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SplatStagesFramework/SplatDataFetcher.h>
#import <SplatStagesFramework/SplatUtilities.h>

@interface SplatDataFetcher ()

@end

@implementation SplatDataFetcher

+ (void) downloadFile:(NSString*) urlString completionHandler:(void (^)(NSData* data)) completionHandler errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler {
    // We need an NSURLSession instance that has caching turned off.
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData; // Don't cache, get request each time
    configuration.timeoutIntervalForRequest = 15; // Wait 15 seconds before timing out.
    NSURLSession* session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURL* url = [NSURL URLWithString:urlString];
    [[session dataTaskWithURL:url completionHandler:^(NSData* data, NSURLResponse* response, NSError* taskError) {
        // Check for an error first
        if (taskError) {
            errorHandler(taskError, @"ERROR_DOWNLOADING_DATA");
            return;
        }
        
        // Call the completion handler.
        completionHandler(data);
    }] resume];
}

+ (void) downloadAndParseJson:(NSString*) urlString completionHandler:(void (^)(NSMutableDictionary* dict)) completionHandler errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler {
    [self downloadFile:urlString completionHandler:^(NSData* data) {
        // Attempt to parse the data.
        NSError* jsonError;
        NSMutableDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        
        // Check for a error first
        if (jsonError) {
            errorHandler(jsonError, @"ERROR_PARSING_JSON");
            return;
        }
        
        // Call the completion handler.
        completionHandler(jsonDict);
    } errorHandler:^(NSError* error, NSString* when) {
        errorHandler(error, when);
    }];
}

+ (void) requestStageDataWithCallback:(void (^)(NSNumber* mode)) updateCallback errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler {
    NSUserDefaults* storedData = [SplatUtilities getUserDefaults];
    
    // Get the Temporary Stage Mapping, which contains the English names for maps that aren't supported by splatoon.ink yet.
    [self downloadAndParseJson:@"https://oatmealdome.github.io/splatstages/temporary-stage-mapping.json" completionHandler:^(NSMutableDictionary* data) {
        [storedData setObject:data forKey:@"temporaryMappings"];
        [storedData synchronize];
        
        // Now we can request the latest stage data.
        [self downloadAndParseJson:@"https://splatoon.ink/schedule.json" completionHandler:^(NSDictionary* data) {
            // Check if the data is stale, and return if it is.
            NSDate* updateTime = [NSDate dateWithTimeIntervalSince1970:[[data objectForKey:@"updateTime"] longLongValue] / 1000];
            NSDate* storedDataUpdateTime = [storedData objectForKey:@"storedDataUpdateTime"];
            if (!storedDataUpdateTime) {
                storedDataUpdateTime = [NSDate dateWithTimeIntervalSince1970:0];
            }
            if ([updateTime timeIntervalSinceDate:storedDataUpdateTime] <= 0.0) {
                updateCallback(@1);
                return;
            }
            
            // Set all our data variables.
            [storedData setObject:updateTime forKey:@"storedDataUpdateTime"];
            [storedData setObject:[data objectForKey:@"schedule"] forKey:@"schedule"];
            [storedData synchronize];
            
            // Check if there's no schedule (for example, splatoon.ink returns nothing of value during Splatfests)
            NSArray* schedules = [data objectForKey:@"schedule"];
            NSDate* lastUpdateTime = [NSDate dateWithTimeIntervalSince1970:[[[schedules lastObject] objectForKey:@"endTime"] longLongValue] / 1000];
            if ([schedules count] <= 2 || [lastUpdateTime timeIntervalSinceNow] < 0.0) {
                updateCallback(@2);
                return;
            }
            
            updateCallback(@3);
        } errorHandler:^(NSError* error, NSString* when) {
            errorHandler(error, when);
        }];
    } errorHandler:^(NSError* error, NSString* when) {
        errorHandler(error, when);
    }];
}

+ (void) requestFestivalDataWithCallback:(void (^)()) updateCallback errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler {
    NSUserDefaults* storedData = [SplatUtilities getUserDefaults];
    [self downloadAndParseJson:@"https://oatmealdome.github.io/splatstages/splatfest-screenshot.json" completionHandler:^(NSMutableDictionary* data) {
        // set start countdown time
        NSDate* naStartDate = [[NSDate date] dateByAddingTimeInterval:52377];
        [[data objectForKey:@"na"] setObject:[NSNumber numberWithDouble:[naStartDate timeIntervalSince1970]] forKey:@"startTime"];
        
        // set end countdown times
        NSDate* euStartDate = [[NSDate date] dateByAddingTimeInterval:-52377];
        NSDate* euEndDate = [[NSDate date] dateByAddingTimeInterval:52377];
        [[data objectForKey:@"eu"] setObject:[NSNumber numberWithDouble:[euStartDate timeIntervalSince1970]] forKey:@"startTime"];
        [[data objectForKey:@"eu"] setObject:[NSNumber numberWithDouble:[euEndDate timeIntervalSince1970]] forKey:@"endTime"];
        
        // set results time
        [[data objectForKey:@"jp"] setObject:[NSNumber numberWithDouble:[euStartDate timeIntervalSince1970]] forKey:@"startTime"];
        [[data objectForKey:@"jp"] setObject:[NSNumber numberWithDouble:[euStartDate timeIntervalSince1970]] forKey:@"endTime"];
        
        NSDictionary* splatfestData = [data objectForKey:[SplatUtilities getUserRegion]];
        [storedData setObject:splatfestData forKey:@"splatfestData"];
        [storedData synchronize];
        
        updateCallback();
    } errorHandler:^(NSError* error, NSString* when) {
        errorHandler(error, when);
    }];
}




@end