//
//  SplatOAuthHelper.m
//  SplatStages
//
//  Created by mac on 2015-11-21.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SplatStagesFramework/SplatDataFetcher.h>
#import <SplatStagesFramework/SplatSquidRingHelper.h>
#import <SplatStagesFramework/SplatUtilities.h>

@interface SplatSquidRingHelper ()

@end

@implementation SplatSquidRingHelper

// url: https://id.nintendo.net/oauth/authorize
// client_id: 12af3d0a3a1f441eb900411bb50a835a
// redirect_uri: https://splatoon.nintendo.net/users/auth/nintendo/callback
// response_type: code
// https://id.nintendo.net/oauth/authorize?client_id=12af3d0a3a1f441eb900411bb50a835a&redirect_uri=https%3A%2F%2Fsplatoon.nintendo.net%2Fusers%2Fauth%2Fnintendo%2Fcallback&response_type=code&state=affc0e17abc5b5af65b9c6a592e5151081771b405be9530e

+ (void) loginToSplatNet:(void (^)(NSError* error, NSString* when)) errorHandler {
    VALValet* valet = [SplatUtilities getValet];
    if (![valet canAccessKeychain]) {
        NSDictionary* userInfo = @{
                                   NSLocalizedDescriptionKey : NSLocalizedString(@"ERROR_KEYCHAIN_ACCESS_DESCRIPTION", nil)
                                   };
        NSError* error = [[NSError alloc] initWithDomain:@"me.oatmealdome.ios.SplatStages" code:1 userInfo:userInfo];
        errorHandler(error, NSLocalizedString(@"ERROR_SPLATNET_LOG_IN", nil));
    }
    
    NSURL* url = [NSURL URLWithString:@"https://id.nintendo.net/oauth/authorize"];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSDictionary* requestParametersDict = @{
                                        @"client_id" : @"12af3d0a3a1f441eb900411bb50a835a",
                                        @"redirect_uri" : @"https://splatoon.nintendo.net/users/auth/nintendo/callback",
                                        @"response_type" : @"code",
                                        @"username" : [valet stringForKey:@"username"],
                                        @"password" : [valet stringForKey:@"password"]
                                        };
    NSError* jsonError = nil;
    NSData* requestParameters = [NSJSONSerialization dataWithJSONObject:requestParametersDict options:kNilOptions error:&jsonError];
    
    if (jsonError) {
        errorHandler(jsonError, @"ERROR_SPLATNET_LOG_IN");
        return;
    }
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestParameters];
    
    NSURLSession* session = [SplatUtilities getNSURLSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* taskError) {
        // Check for an error first
        if (taskError) {
            errorHandler(taskError, @"ERROR_SPLATNET_LOG_IN");
            return;
        }
        
        
    }] resume];
    
}

@end