//
//  SplatUtilities.h
//  SplatStages
//
//  Created by mac on 2015-09-26.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SplatUtilities : NSObject

//! Convert the string to a localizable (e.g. "Moray Towers" -> "MORAY_TOWERS")
+ (NSString*) toLocalizable:(NSString*) string;

//! Returns if the user's language is currently Japanese.
+ (BOOL) isDeviceLangaugeJapanese;

//! Returns the user's selected Splatoon region
+ (NSString*) getUserRegion;

//! Get our user defaults group.
+ (NSUserDefaults*) getUserDefaults;

@end
