//
//  SplatUtilities.m
//  SplatStages
//
//  Created by mac on 2015-09-26.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <SplatStagesFramework/SSFRotation.h>

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
    static NSUserDefaults* userDefaults = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.me.oatmealdome.ios.SplatStages"];
    });
    
    return userDefaults;
}

+ (VALValet*) getValet {
    static VALValet* valet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        valet = [[VALValet alloc] initWithSharedAccessGroupIdentifier:@"me.oatmealdome.ios.SplatStages" accessibility:VALAccessibilityWhenUnlocked];
    });
    
    return valet;
}

+ (NSDate*) parseSplatNetDate:(NSString*) string {
    static NSDateFormatter* dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    });
    return [dateFormatter dateFromString:string];
}

+ (NSAttributedString*) getSplatfestTeamName:(NSDictionary*) teamData {
    UIColor* teamColour = [self colorWithHexString:[teamData objectForKey:@"colour"]];
    NSAttributedString* string = [[NSAttributedString alloc] initWithString:[teamData objectForKey:@"name"] attributes:@{NSForegroundColorAttributeName : teamColour}];
    return string;
}

+ (NSString*) localizeString:(NSString*) string {
    NSString* localized = NSLocalizedStringFromTableInBundle(string, nil, [NSBundle bundleForClass:[self class]], nil);
    if ([localized isEqualToString:string]) {
        localized = NSLocalizedStringFromTableInBundle(string, nil, [NSBundle mainBundle], nil);
    }
    return localized;
}

+ (BOOL) isScheduleUsable {
    NSUserDefaults* userDefaults = [SplatUtilities getUserDefaults];
    NSArray* schedule = [userDefaults objectForKey:@"schedule"];
    NSDate* lastRotationEndTime = [NSDate dateWithTimeIntervalSince1970:[[[schedule lastObject] objectForKey:@"endTime"] longLongValue] / 1000];
    
    // Check if the data is usable
    if (schedule == nil || [userDefaults boolForKey:@"scheduleHasSplatfestData"] || [lastRotationEndTime timeIntervalSinceNow] < 0.0) {
        return false;
    }
    
    return true;
}

+ (NSDate*) getNextRotation {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [dateFormatter setDateFormat:@"HH"];
    NSDate* date = [NSDate date];
    
    NSArray* rotations = @[ @2, @6, @10, @14, @18, @22 ];
    while (true) {
        date = [date dateByAddingTimeInterval:3600];
        for (NSNumber* num in rotations) {
            if ([@([[dateFormatter stringFromDate:date] integerValue]) isEqualToNumber:num]) {
                return date;
            }
        }
    }
}

+ (void) mergeScheduleArray:(NSMutableArray*) one withArray:(NSMutableArray*) two {
    for (int i = 0; i < 3; i++) {
        // Replace NSNull spaces with objects from the second array.
        if ([[one objectAtIndex:i] isEqual:[NSNull null]]) {
            [one replaceObjectAtIndex:i withObject:[two objectAtIndex:i]];
        }
    }
}

+ (NSMutableArray*) createUnknownSchedule {
    NSMutableArray* schedule = [[NSMutableArray alloc] init];
    NSDate* now = [NSDate date];
    NSDate* nextStart = [self getNextRotation];
    NSDate* laterStart = [nextStart dateByAddingTimeInterval:3600];
    NSDate* laterEnd =  [laterStart dateByAddingTimeInterval:3600];
    
    [schedule addObject:[[[SSFRotation alloc] init] initWithUnknownStages:now endTime:nextStart]];
    [schedule addObject:[[[SSFRotation alloc] init] initWithUnknownStages:nextStart endTime:laterStart]];
    [schedule addObject:[[[SSFRotation alloc] init] initWithUnknownStages:laterStart endTime:laterEnd]];
    
    return schedule;
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

@end
