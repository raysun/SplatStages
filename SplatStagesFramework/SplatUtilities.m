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
    NSMutableCharacterSet* charactersToKeep = [NSMutableCharacterSet alphanumericCharacterSet];
    [charactersToKeep addCharactersInString:@"_"];
    NSCharacterSet* charactersToRemove = [charactersToKeep invertedSet];
    
    NSString* withUnderscore = [[string stringByReplacingOccurrencesOfString:@" " withString:@"_"] uppercaseString];
    return [[withUnderscore componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
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
    return [[NSUserDefaults alloc] initWithSuiteName:@"group.me.oatmealdome.ios.SplatStages"];
}

+ (VALValet*) getValet {
    return [[VALValet alloc] initWithSharedAccessGroupIdentifier:@"me.oatmealdome.ios.SplatStages" accessibility:VALAccessibilityWhenUnlocked];
}

+ (NSAttributedString*) getSplatfestTeamName:(NSDictionary*) teamData {
    UIColor* teamColour = [self colorWithHexString:[teamData objectForKey:@"colour"]];
    NSAttributedString* string = [[NSAttributedString alloc] initWithString:[teamData objectForKey:@"name"] attributes:@{NSForegroundColorAttributeName : teamColour}];
    return string;
}

+ (BOOL) isScheduleOutdated {
    NSArray* schedule = [[self getUserDefaults] objectForKey:@"schedule"];
    NSDate* nextRotation = [NSDate dateWithTimeIntervalSince1970:[[[schedule objectAtIndex:0] objectForKey:@"endTime"] longLongValue] / 1000];
    return [nextRotation timeIntervalSinceNow] <= 0;
}

- (void) setLabel:(PLATFORM_SPECIFIC_LABEL*) label nameEN:(NSString*) nameEN nameJP:(NSString*) nameJP unknownLocalizable:(NSString*) unknownLocalizable {
    NSString* localizable = [SplatUtilities toLocalizable:nameEN];
    NSString* localizedString = NSLocalizedString(localizable, nil);
    
    if ([localizedString isEqualToString:localizable]) {
        // We don't have data for this stage!
        if ([SplatUtilities isDeviceLangaugeJapanese]) {
            // The device language is Japanese, so use nameJP.
            [label setText:nameJP];
        } else if ([nameEN canBeConvertedToEncoding:NSISOLatin1StringEncoding]) {
            // nameEN is an English string, so let's use that.
            [label setText:nameEN];
        } else {
            // The device language is not Japanese and we have no English string, so just display the unknown string,
            [label setText:NSLocalizedString(unknownLocalizable, nil)];
        }
    } else {
        [label setText:localizedString];
    }
}

+ (UIColor*) colorWithHexString:(NSString*) hex {
    NSString* cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6)
        return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6)
        return [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString* rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString* gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString* bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

+ (NSURLSession*) getNSURLSession {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData; // Don't cache, get request each time
    configuration.timeoutIntervalForRequest = 15; // Wait 15 seconds before timing out.
    
    return [NSURLSession sessionWithConfiguration:configuration];
}

@end
