//
//  ViewController.h
//  SplatStages
//
//  Created by mac on 2015-08-25.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <UIKit/UIKit.h>

#define REGULAR_CONTROLLER 0
#define RANKED_CONTROLLER 1
#define SPLATFEST_CONTROLLER 2
#define SETTINGS_CONTROLLER 3

@interface TabViewController : UITabBarController <UITabBarControllerDelegate>

@property NSTimer* timer; // test

// Stages
@property NSArray* schedule;
@property NSDate* lastStageDataUpdate;
@property NSDate* nextRotation;
@property NSTimer* rotationTimer;
@property NSTimer* stageRequestTimer;
@property NSDictionary* temporaryStageMapping;

// Splatfest
@property NSDictionary* splatfestData;

// Calendar Stuff
@property NSCalendar* calendar;
@property int calendarUnits;

// Setup
@property BOOL needsInitialSetup;

// Network
@property NSURLSession* urlSession;

- (void) getStageData;
- (void) getSplatfestData;
- (void) refreshAllData;
- (void) setStages;
- (void) setupStageView:(NSString*) nameEN nameJP:(NSString*) nameJP label:(UILabel*) label imageView:(UIImageView*) imageView;
- (void) errorOccurred:(NSError*) error when:(NSString*) errorWhen;
- (NSString*) toLocalizable:(NSString*) string;
- (BOOL) isUserLangaugeJapanese;
- (NSString*) getUserRegion;

@end

