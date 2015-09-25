//
//  SplatDataFetcher.h
//  SplatStages
//
//  Created by mac on 2015-09-25.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

@interface SplatDataFetcher : NSObject

+ (void) downloadFile:(NSString*) urlString completionHandler:(void (^)(NSData* data)) completionHandler errorHandler:(void (^)(NSError* data)) errorHandler;
+ (void) downloadAndParseJson:(NSString*) urlString completionHandler:(void (^)(NSDictionary* dict)) completionHandler errorHandler:(void (^)(NSError* data)) errorHandler;
+ (void) requestStageDataWithCallback:(void (^)(NSNumber* mode)) updateCallback errorHandler:(void (^)(NSError* error)) errorHandler;

@end