//
//  SplatUtilities.h
//  SplatStages
//
//  Created by mac on 2015-09-26.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface SplatUtilities : NSObject

//! Convert the string to a localizable (e.g. "Moray Towers" -> "MORAY_TOWERS")
+ (NSString*) toLocalizable:(NSString*) string;

//! Returns if the user's language is currently Japanese.
+ (BOOL) isDeviceLangaugeJapanese;

//! Returns the user's selected Splatoon region
+ (NSString*) getUserRegion;

//! Get our user defaults group.
+ (NSUserDefaults*) getUserDefaults;

//! Get the team name as a coloured NSAttributedString.
+ (NSAttributedString*) getSplatfestTeamName:(NSDictionary*) teamData;

//! Returns the hex string as a UIColor.
+ (UIColor*) colorWithHexString:(NSString*) hex;

@end
