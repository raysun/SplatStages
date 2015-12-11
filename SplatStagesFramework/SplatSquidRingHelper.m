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

+ (void) loginToSplatNet:(void (^)()) completionHandler errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler {
    // Check if we're logged in first
    [self checkIfLoggedIn:^(BOOL loggedIn) {
        
        // We're already logged in, so let's not log in again.
        if (loggedIn) {
            NSLog(@"logged in already");
            completionHandler();
            return;
        }
        
        // Get a Valet instance and check if it can access the keychain
        VALValet* valet = [SplatUtilities getValet];
        if (![valet canAccessKeychain]) {
            NSDictionary* userInfo = @{
                                       NSLocalizedDescriptionKey : NSLocalizedString(@"ERROR_KEYCHAIN_ACCESS_DESCRIPTION", nil)
                                       };
            NSError* error = [[NSError alloc] initWithDomain:@"me.oatmealdome.ios.SplatStages" code:1 userInfo:userInfo];
            errorHandler(error, NSLocalizedString(@"ERROR_SPLATNET_LOG_IN", nil));
            return;
        }
        
        // Check if the user has an NNID set
        if ([valet stringForKey:@"username"] == nil || [valet stringForKey:@"password"] == nil) {
            NSDictionary* userInfo = @{
                                       NSLocalizedDescriptionKey : NSLocalizedString(@"ERROR_CREDENTIALS_NOT_SET", nil)
                                       };
            NSError* error = [[NSError alloc] initWithDomain:@"me.oatmealdome.ios.SplatStages" code:3 userInfo:userInfo];
            errorHandler(error, NSLocalizedString(@"ERROR_SPLATNET_LOG_IN", nil));
            return;
        }
        
        NSURL* url = [NSURL URLWithString:@"https://id.nintendo.net/oauth/authorize"];
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
        NSString* requestParameters = [NSString stringWithFormat:@"client_id=12af3d0a3a1f441eb900411bb50a835a&redirect_uri=https://splatoon.nintendo.net/users/auth/nintendo/callback&response_type=code&username=%@&password=%@", [valet stringForKey:@"username"], [valet stringForKey:@"password"]];
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[requestParameters dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLSession* session = [SplatDataFetcher dataSession];
        [[session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* taskError) {
            // Check for an error first
            if (taskError) {
                errorHandler(taskError, @"ERROR_SPLATNET_LOG_IN");
                return;
            }
            
            // Check if the log in was successful by looking for "ika_swim" in the page contents
            NSString* pageContents = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSRange range = [pageContents rangeOfString:@"ika_swim" options:NSCaseInsensitiveSearch];
            
            if (range.location == NSNotFound) {
                NSDictionary* userInfo = @{
                                           NSLocalizedDescriptionKey : NSLocalizedString(@"ERROR_LOG_IN_FAILED", nil)
                                           };
                NSError* error = [[NSError alloc] initWithDomain:@"me.oatmealdome.ios.SplatStages" code:2 userInfo:userInfo];
                errorHandler(error, NSLocalizedString(@"ERROR_SPLATNET_LOG_IN", nil));
                return;
            }
            
            // Log in successful.
            completionHandler();
        }] resume];
        
    } errorHandler:^(NSError* error, NSString* when) {
        errorHandler(error, when);
    }];
}

+ (void) getOnlineFriends:(void (^)(NSDictionary* onlineFriends)) completionHandler errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler {
    [SplatDataFetcher downloadAndParseJson:@"https://splatoon.nintendo.net/friend_list/index.json" completionHandler:^(id onlineFriends, NSError* error) {
        if (error) {
            errorHandler(error, @""); // TODO
            return;
        }
        
        completionHandler(onlineFriends);
    }];
}

+ (void) checkIfLoggedIn:(void (^)(BOOL)) completionHandler errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler {
    [SplatDataFetcher downloadAndParseJson:@"https://splatoon.nintendo.net/friend_list/index.json" completionHandler:^(id json, NSError* error) {
        if (error) {
            errorHandler(error, @""); // TODO
            return;
        }
        
        // If an error is encountered, the server returns a dictionary
        completionHandler([json isKindOfClass:[NSArray class]]);
    }];

}

+ (BOOL) splatNetCredentialsSet {
    VALValet* valet = [SplatUtilities getValet];
    return ([valet stringForKey:@"username"] != nil && [valet stringForKey:@"password"] != nil);
}

@end