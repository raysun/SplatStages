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
    NSURLSession* session = [SplatUtilities getNSURLSession];
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

+ (void) downloadAndParseJson:(NSString*) urlString completionHandler:(void (^)(id parsedJson)) completionHandler errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler {
    [self downloadFile:urlString completionHandler:^(NSData* data) {
        // Attempt to parse the data.
        NSError* jsonError;
        id parsedJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
        
        // Check for a error first
        if (jsonError) {
            errorHandler(jsonError, @"ERROR_PARSING_JSON");
            return;
        }
        
        // Call the completion handler.
        completionHandler(parsedJson);
    } errorHandler:^(NSError* error, NSString* when) {
        errorHandler(error, when);
    }];
}

+ (void) requestStageDataWithCallback:(void (^)(NSNumber* mode)) updateCallback errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler {
    NSUserDefaults* storedData = [SplatUtilities getUserDefaults];
    
    // Get the Temporary Stage Mapping, which contains the English names for maps that aren't supported by splatoon.ink yet.
    [self downloadAndParseJson:@"https://oatmealdome.github.io/splatstages/temporary-stage-mapping.json" completionHandler:^(id mappingJson) {
        [storedData setObject:mappingJson forKey:@"temporaryMappings"];
        [storedData synchronize];
        
        // Now we can request the latest stage data.
        [self downloadAndParseJson:@"https://splatoon.ink/schedule.json" completionHandler:^(id scheduleJson) {
            // Check if the data is stale, and return if it is.
            NSDate* updateTime = [NSDate dateWithTimeIntervalSince1970:[[scheduleJson objectForKey:@"updateTime"] longLongValue] / 1000];
            NSDate* storedDataUpdateTime = [storedData objectForKey:@"storedDataUpdateTime"];
            if (!storedDataUpdateTime) {
                storedDataUpdateTime = [NSDate dateWithTimeIntervalSince1970:0];
            }
            if ([updateTime timeIntervalSinceDate:storedDataUpdateTime] <= 0.0) {
                updateCallback(@1);
                return;
            }
            
            BOOL splatfest = [scheduleJson objectForKey:@"splatfest"];
            
            // Set all our data variables.
            [storedData setObject:updateTime forKey:@"storedDataUpdateTime"];
            [storedData setObject:[scheduleJson objectForKey:@"schedule"] forKey:@"schedule"];
            [storedData setBool:splatfest forKey:@"scheduleHasSplatfestData"];
            [storedData synchronize];
            
            // Check if the schedule is outdated
            if (![SplatUtilities isScheduleUsable]) {
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
    [self downloadAndParseJson:@"https://oatmealdome.github.io/splatstages/splatfest.json" completionHandler:^(id splatfestJson) {
        NSDictionary* splatfestData = [splatfestJson objectForKey:[SplatUtilities getUserRegion]];
        [storedData setObject:splatfestData forKey:@"splatfestData"];
        [storedData synchronize];
        
        updateCallback();
    } errorHandler:^(NSError* error, NSString* when) {
        errorHandler(error, when);
    }];
}




@end