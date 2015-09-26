//
//  SplatUtilities.m
//  SplatStages
//
//  Created by mac on 2015-09-26.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import "SplatUtilities.h"

@implementation SplatUtilities

+ (NSString*) toLocalizable:(NSString*) string {
    return [[string stringByReplacingOccurrencesOfString:@" " withString:@"_"] uppercaseString];
}

+ (BOOL) isDeviceLangaugeJapanese {
    NSString* deviceLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    return [deviceLanguage isEqualToString:@"ja"];
}

+ (NSString*) getUserRegion {
    return [[self getUserDefaults] objectForKey:@"region"];
}

+ (BOOL) getSetupFinished {
    return [[self getUserDefaults] objectForKey:@"setupFinished"] != nil;
}

+ (NSUserDefaults*) getUserDefaults {
    return [[NSUserDefaults alloc] initWithSuiteName:@"group.me.oatmealdome.SplatStages"];
}

@end
