//
//  SplatDataFetcher.m
//  SplatStages
//
//  Created by mac on 2015-09-25.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SplatStagesFramework/SplatDataFetcher.h>

@interface SplatDataFetcher ()

@end

@implementation SplatDataFetcher

+ (void) downloadFile:(NSString*) urlString completionHandler:(void (^)(NSData* data)) completionHandler errorHandler:(void (^)(NSError* data)) errorHandler {
    // We need an NSURLSession instance that has caching turned off.
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    NSURLSession* session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURL* url = [NSURL URLWithString:urlString];
    [[session dataTaskWithURL:url completionHandler:^(NSData* data, NSURLResponse* response, NSError* taskError) {
        // Check for an error first
        if (taskError) {
            errorHandler(taskError);
            return;
        }
        
        // Call the completion handler.
        completionHandler(data);
    }] resume];
}

+ (void) downloadAndParseJson:(NSString*) urlString completionHandler:(void (^)(NSDictionary* dict)) completionHandler errorHandler:(void (^)(NSError* error)) errorHandler {
    
    [self downloadFile:urlString completionHandler:^(NSData* data) {
        // Attempt to parse the data.
        NSError* jsonError;
        NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
        
        // Check for a error first
        if (jsonError) {
            errorHandler(jsonError);
            return;
        }
        
        // Call the completion handler.
        completionHandler(jsonDict);
    } errorHandler:^(NSError* error) {
        errorHandler(error);
    }];
}

+ (void) requestStageDataWithCallback:(void (^)(NSNumber* mode)) updateCallback errorHandler:(void (^)(NSError* error)) errorHandler {
    NSUserDefaults* storedData = [[NSUserDefaults alloc] initWithSuiteName:@"group.me.atmealdome.SplatStagesData"];
    
    // Get the Temporary Stage Mapping, which contains the English names for maps that aren't supported by splatoon.ink yet.
    [self downloadAndParseJson:@"https://oatmealdome.github.io/splatstages/temporary-stage-mapping.json" completionHandler:^(NSDictionary* data) {
        [storedData setObject:data forKey:@"temporaryMappings"];
        [storedData synchronize];
        
        // Now we can request the latest stage data.
        [self downloadAndParseJson:@"https://splatoon.ink/schedule.json" completionHandler:^(NSDictionary* data) {
            // Check if the data is stale, and return if it is.
            NSDate* updateTime = [NSDate dateWithTimeIntervalSince1970:[[data objectForKey:@"updateTime"] longLongValue] / 1000];
            NSDate* storedDataUpdateTime = [storedData objectForKey:@"storedDataUpdateTime"];
            if ([updateTime timeIntervalSinceDate:storedDataUpdateTime] <= 0.0) {
                updateCallback(@1);
                return;
            }
            
            // Set all our data variables.
            [storedData setObject:updateTime forKey:@"storedDataUpdateTime"];
            [storedData setObject:[data objectForKey:@"schedule"] forKey:@"schedule"];
            [storedData synchronize];
            
            // Check if there's no schedule (for example, splatoon.ink returns nothing of value during Splatfests)
            if ([[data objectForKey:@"schedule"] count] <= 1) {
                updateCallback(@2);
                return;
            }
            
            updateCallback(@3);
        } errorHandler:^(NSError* error) {
            errorHandler(error);
        }];
    } errorHandler:^(NSError* error) {
        errorHandler(error);
    }];
}




@end