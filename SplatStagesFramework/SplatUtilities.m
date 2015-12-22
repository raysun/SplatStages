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

+ (NSDate*) getNextRotation {
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDateComponents* roundDownComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitNanosecond fromDate:[NSDate date]];
    [roundDownComponents setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [roundDownComponents setMinute:0];
    [roundDownComponents setSecond:0];
    [roundDownComponents setNanosecond:0];
    
    NSDate* roundedDate = [calendar dateFromComponents:roundDownComponents];
    NSDateComponents* hourComponents = [[NSDateComponents alloc] init];
    [hourComponents setHour:1];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [dateFormatter setDateFormat:@"HH"];
    
    NSArray* rotations = @[ @2, @6, @10, @14, @18, @22 ];
    while (true) {
        roundedDate = [calendar dateByAddingComponents:hourComponents toDate:roundedDate options:0];
        for (NSNumber* num in rotations) {
            if ([@([[dateFormatter stringFromDate:roundedDate] integerValue]) isEqualToNumber:num]) {
                return roundedDate;
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

+ (void) shiftScheduleDown:(NSMutableArray*) schedule {
    NSDate* laterStart = [[schedule lastObject] endTime];
    NSDate* laterEnd =  [laterStart dateByAddingTimeInterval:3600];
    
    [schedule removeObjectAtIndex:0];
    [schedule addObject:[[[SSFRotation alloc] init] initWithUnknownStages:laterStart endTime:laterEnd]];
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
