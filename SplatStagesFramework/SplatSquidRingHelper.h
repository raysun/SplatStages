//
//  SplatOAuthHelper.h
//  SplatStages
//
//  Created by mac on 2015-11-21.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

@interface SplatSquidRingHelper : NSObject

+ (void) loginToSplatNet:(void (^)()) completionHandler errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler;

+ (void) getOnlineFriends:(void (^)(NSDictionary* onlineFriends)) completionHandler errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler;

+ (void) checkIfLoggedIn:(void (^)(BOOL)) completionHandler errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler;

@end