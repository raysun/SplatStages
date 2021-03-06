//
//  SplatUtilities.h
//  SplatStages
//
//  Created by mac on 2015-09-26.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import <Valet/Valet.h>

@interface SplatUtilities : NSObject

//! Convert the string to a localizable (e.g. "Moray Towers" -> "MORAY_TOWERS")
+ (NSString*) toLocalizable:(NSString*) string;

//! Returns true if the user's language is currently Japanese.
+ (BOOL) isDeviceLangaugeJapanese;

//! Returns true if setup has been finished.
+ (BOOL) getSetupFinished;

//! Returns the user's selected Splatoon region
+ (NSString*) getUserRegion;

//! Get our user defaults group.
+ (NSUserDefaults*) getUserDefaults;

//! Returns a Valet instance that we can use to access the Keychain.
+ (VALValet*) getValet;

//! Get the team name as a coloured NSAttributedString.
+ (NSAttributedString*) getSplatfestTeamName:(NSDictionary*) teamData;

//! Localizes a string with priority to the Framework bundle.
+ (NSString*) localizeString:(NSString*) string;

//! Merges two schedule arrays.
+ (void) mergeScheduleArray:(NSMutableArray*) one withArray:(NSMutableArray*) two;

//! Creates an unknown schedule.
+ (NSMutableArray*) createUnknownSchedule;

//! Removes the first object and appends an unknown rotation object.
+ (void) shiftScheduleDown:(NSMutableArray*) schedule;

//
// Thanks WrightsCS on StackOverflow!
// http://stackoverflow.com/questions/6207329/how-to-set-hex-color-code-for-background
//
//! Returns the hex string as a UIColor.
+ (UIColor*) colorWithHexString:(NSString*) hex;

@end