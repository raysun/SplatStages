//
//  SplatLabel.h
//  SplatStages
//
//  Created by mac on 2015-11-26.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

// This header file contains the definition for PLATFORM_SPECIFIC_LABEL,
// which is used for easily referring to the different label types
// (at the moment, WKInterfaceLabel and UILabel).

#pragma once

#if TARGET_OS_WATCH
    // WatchOS
    #import <WatchKit/WKInterfaceLabel.h>
    #define PLATFORM_SPECIFIC_LABEL WKInterfaceLabel
#elif TARGET_OS_IOS || TARGET_OS_TV
    // iOS / tvOS
    #import <UIKit/UILabel.h>
    #define PLATFORM_SPECIFIC_LABEL UILabel
#else
    // Unknown platform
    #error Unsupported platform.
#endif