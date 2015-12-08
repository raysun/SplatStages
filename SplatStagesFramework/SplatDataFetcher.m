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

+ (void) requestStageDataWithCallback:(void (^)(NSNumber* mode)) updateCallback errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler {
    NSUserDefaults* storedData = [SplatUtilities getUserDefaults];
    
    [self downloadAndParseJson:@"https://oatmealdome.github.io/splatstages/temporary-stage-mapping.json" completionHandler:^(id mappingJson, NSError* mappingError) {
        if (mappingError) {
            errorHandler(mappingError, @""); // TODO
        }
        
        [storedData setObject:mappingJson forKey:@"temporaryMappings"];
        [storedData synchronize];
        
        [self downloadAndParseJson:@"https://splatoon.ink/schedule.json" completionHandler:^(id scheduleJson, NSError* scheduleError) {
            if (scheduleError) {
                errorHandler(scheduleError, @""); // TODO
            }
            
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
            
            BOOL splatfest = [[scheduleJson objectForKey:@"splatfest"] boolValue];
            
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
        }];
    }];
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
    static NSURLSession *session = nil;
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