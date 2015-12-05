//
//  ViewController.m
//  SplatStages
//
//  Created by mac on 2015-08-25.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <SplatStagesFramework/SplatStagesFramework.h>

#import "RankedViewController.h"
#import "RegularViewController.h"
#import "SettingsViewController.h"
#import "SplatfestViewController.h"
#import "TabViewController.h"

@interface TabViewController ()

@end

@implementation TabViewController

// View Controller Methods ----

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // For some reason this isn't possible in Interface Builder.
    [self setDelegate:self];
    
    // Force all our views to load right now.
    [self.viewControllers makeObjectsPerformSelector:@selector(view)];
    
    // Check if we need to do the initial setup.
    if (![SplatUtilities getSetupFinished]) {
        // Yes, set our BOOL to lock the user in and switch to the Settings tab.
        self.needsInitialSetup = true;
        [self setSelectedIndex:SETTINGS_CONTROLLER];
        
        // Show the user the welcome alert too.
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SETTINGS_WELCOME_TITLE", nil) message:NSLocalizedString(@"SETTINGS_WELCOME_TEXT", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CONFIRM", nil) otherButtonTitles:nil, nil];
        [alert show];
    } else {
        // Select the default tab and fetch the latest schedule data.
        [self setSelectedIndex:REGULAR_CONTROLLER];
        [self getStageData];
        [self getSplatfestData];
    }
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Data Methods ---------------

// Sends requests for all the data we need
- (void) getStageData {
    // Add an MBProgressHUD instance to each of our stage view controllers.
    RegularViewController* regularViewController = [self.viewControllers objectAtIndex:REGULAR_CONTROLLER];
    RankedViewController* rankedViewController = [self.viewControllers objectAtIndex:RANKED_CONTROLLER];
    [self generateLoadingHudWithView:regularViewController.view];
    [self generateLoadingHudWithView:rankedViewController.view];

    [SplatDataFetcher requestStageDataWithCallback:^(NSNumber* mode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch ([mode integerValue]) {
                case 1: // Data is stale
                    [self setStageLoadingFinished];
                    break;
                case 2: // No stages available
                    [self setStagesUnavailable];
                    break;
                case 3: // Setup views and schedule timer
                    [self setSelectedRotation:0];
                    [self setStages];
                    break;
            }
        });
    } errorHandler:^(NSError* error, NSString* when) {
        [self errorOccurred:error when:when];
    }];
    
}

- (void) getSplatfestData {
    // Add an MBProgressHUD instance to our Splatfest view controller.
    SplatfestViewController* splatfestViewController = [self.viewControllers objectAtIndex:SPLATFEST_CONTROLLER];
    [self generateLoadingHudWithView:[splatfestViewController view]];
    
    // Request Splatfest data
    [SplatDataFetcher requestFestivalDataWithCallback:^() {
        NSDictionary* splatfestData = [[SplatUtilities getUserDefaults] objectForKey:@"splatfestData"];
        int splatfestId = [[splatfestData objectForKey:@"id"] intValue];
        
        // Clear any leftover images from the image cache.
        [self removeCacheFilesExceptFor:splatfestId];
        
        // Check if the latest Splatfest image exists.
        NSString* cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* imagePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"splatfest-%@-%i.jpg", [SplatUtilities getUserRegion], splatfestId]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
            // Skip straight to UI setup, we don't need to download anything.
            [self setupSplatfestWithData:splatfestData splatfestId:splatfestId];
            return;
        }
        
        // We need to get the image file first.
        [SplatDataFetcher downloadFile:[splatfestData objectForKey:@"image"] completionHandler:^(NSData* data) {
            [data writeToFile:imagePath atomically:true];
            [self setupSplatfestWithData:splatfestData splatfestId:splatfestId];
        } errorHandler:^(NSError* error, NSString* when) {
            [self errorOccurred:error when:when];
        }];
    } errorHandler:^(NSError* error, NSString* when) {
        [self errorOccurred:error when:when];
    }];
}

- (void) refreshAllData {
    // Don't refresh data if setup has not been finished
    if ([SplatUtilities getSetupFinished]) {
        // Make sure this is called on the main thread so we can update the UI.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getStageData];
            [self getSplatfestData];
        });
    }
}

/// Schedules a timer to attempt to download Stage data every 120s.
- (void) scheduleStageDownloadTimer {
    self.stageRequestTimer = [NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(getStageData) userInfo:nil repeats:true];
    [self.stageRequestTimer fire];
}

- (void) setStageLoadingFinished {
    if (!self.viewsReady) {
        [self setStages];
    } else {
        RegularViewController* regularViewController = [self.viewControllers objectAtIndex:REGULAR_CONTROLLER];
        RankedViewController* rankedViewController = [self.viewControllers objectAtIndex:RANKED_CONTROLLER];
        [MBProgressHUD hideAllHUDsForView:regularViewController.view animated:true];
        [MBProgressHUD hideAllHUDsForView:rankedViewController.view animated:true];
    };
}

- (void) setStagesUnavailable {
    // Setup a schedule dictionary with all unknowns
    NSDictionary* unknown = @{
                                @"maps" : @[
                                            @{
                                                @"nameEN" : @"UNKNOWN_MAP"
                                            },
                                            @{
                                                @"nameEN" : @"UNKNOWN_MAP"
                                            }
                                        ],
                                @"rulesEN" : @"UNKNOWN_GAMEMODE"
                              };
    
    // Invalidate the rotation timer
    if (self.rotationTimer) {
        [self.rotationTimer invalidate];
        self.rotationTimer = nil;
    }
    
    // Setup the views
    RegularViewController* regularViewController = [self.viewControllers objectAtIndex:REGULAR_CONTROLLER];
    RankedViewController* rankedViewController = [self.viewControllers objectAtIndex:RANKED_CONTROLLER];
    [regularViewController setupViewWithData:unknown];
    [rankedViewController setupViewWithData:unknown];
    
    // Set the rotation countdown labels
    [regularViewController.rotationCountdownLabel setText:NSLocalizedString(@"ROTATION_UNAVAILABLE", nil)];
    [rankedViewController.rotationCountdownLabel setText:NSLocalizedString(@"ROTATION_UNAVAILABLE", nil)];
    
    // Clear any MBProgressHUDs currently attached to the views.
    [MBProgressHUD hideAllHUDsForView:regularViewController.view animated:true];
    [MBProgressHUD hideAllHUDsForView:rankedViewController.view animated:true];
    
    self.viewsReady = true;
}

- (void) setupSplatfestWithData:(NSDictionary*) splatfestData splatfestId:(int) splatfestId {
    SplatfestViewController* splatfestViewController = [self.viewControllers objectAtIndex:SPLATFEST_CONTROLLER];
    
    // Get the time period of the Splatfest
    NSDate* splatfestStart = [NSDate dateWithTimeIntervalSince1970:[[splatfestData objectForKey:@"startTime"] longLongValue]];
    NSDate* splatfestEnd = [NSDate dateWithTimeIntervalSince1970:[[splatfestData objectForKey:@"endTime"] longLongValue]];
    
    // Do preliminary setup (set variables in the view controller)
    [splatfestViewController preliminarySetup:[splatfestData objectForKey:@"teams"] id:splatfestId];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // We need to be on the UI thread to change the layout and contents.
        // Check if a Splatfest is in the future, has started, or has passed.
        if ([splatfestStart timeIntervalSinceNow] > 0.0) {
            // Splatfest is in the future.
            [splatfestViewController setupViewSplatfestSoon:splatfestStart];
        } else if ([splatfestStart timeIntervalSinceNow] < 0.0 && [splatfestEnd timeIntervalSinceNow] > 0.0) {
            // The Splatfest is going on right now!
            [splatfestViewController setupViewSplatfestStarted:splatfestEnd stages:[splatfestData objectForKey:@"maps"]];
        } else {
            // The Splatfest has ended.
            [splatfestViewController setupViewSplatfestFinished:[splatfestData objectForKey:@"results"]];
        }
        [MBProgressHUD hideAllHUDsForView:splatfestViewController.view animated:true];
    });
}

- (void) setStages {
    // Check if the schedule data is usable first
    if (![SplatUtilities isScheduleUsable]) {
        [self setStagesUnavailable];
        return;
    }
    
    // Set up the tabs.
    NSArray* schedule = [[SplatUtilities getUserDefaults] objectForKey:@"schedule"];
    NSDictionary* chosenSchedule = [schedule objectAtIndex:[self getSelectedRotation]];
    RegularViewController* regularVC = [self.viewControllers objectAtIndex:REGULAR_CONTROLLER];
    RankedViewController* rankedVC = [self.viewControllers objectAtIndex:RANKED_CONTROLLER];
    [regularVC setupViewWithData:[chosenSchedule objectForKey:@"regular"]];
    [rankedVC setupViewWithData:[chosenSchedule objectForKey:@"ranked"]];
    
    // Schedule the rotation timer.
    if ([self getSelectedRotation] == 0) {
        NSDate* nextRotation = [NSDate dateWithTimeIntervalSince1970:[[[schedule objectAtIndex:0] objectForKey:@"endTime"] longLongValue] / 1000];
        if (self.rotationTimer) {
            [self.rotationTimer invalidate];
            self.rotationTimer = nil;
        }
        self.rotationTimer = [[SplatTimer alloc] initRotationTimerWithDate:nextRotation labelOne:regularVC.rotationCountdownLabel labelTwo:rankedVC.rotationCountdownLabel textString:NSLocalizedString(@"ROTATION_COUNTDOWN", nil) timerFinishedHandler:^() {
            // Rotating now! Update the UI first and update the schedule data in the background.
            NSString* rotatingNowText = NSLocalizedString(@"ROTATION_NOW", nil);
            [regularVC.rotationCountdownLabel setText:rotatingNowText];
            [rankedVC.rotationCountdownLabel setText:rotatingNowText];
            [self setSelectedRotation:1];
            [self setStages];
            [self scheduleStageDownloadTimer];
            [self.rotationTimer invalidate];
            self.rotationTimer = nil;
        }];
    } else {
        if (self.rotationTimer) {
            [self.rotationTimer invalidate];
            self.rotationTimer = nil;
        }
        
        // Check if the first rotation is over. If it is, then don't touch the labels.
        NSDate* firstRotationEnd = [NSDate dateWithTimeIntervalSince1970:[[[schedule objectAtIndex:0] objectForKey:@"endTime"] longLongValue] / 1000];
        if ([firstRotationEnd timeIntervalSinceNow] > 0.0) {
            [regularVC.rotationCountdownLabel setText:NSLocalizedString(@"ROTATION_FUTURE", nil)];
            [rankedVC.rotationCountdownLabel setText:NSLocalizedString(@"ROTATION_FUTURE", nil)];
        }
    }
    
    // Invalidate the stage requeset timer.
    if (self.stageRequestTimer) {
        [self.stageRequestTimer invalidate];
        self.stageRequestTimer = nil;
    }
    
    // Clear any MBProgressHUDs currently attached to the views.
    [MBProgressHUD hideAllHUDsForView:regularVC.view animated:true];
    [MBProgressHUD hideAllHUDsForView:rankedVC.view animated:true];
    
    self.viewsReady = true;
}

- (void) setupStageView:(NSString*) nameEN nameJP:(NSString*) nameJP label:(UILabel*) label imageView:(UIImageView*) imageView {
    NSString* localizable = [SplatUtilities toLocalizable:nameEN];
    NSString* localizedText = NSLocalizedString(localizable, nil);
    if ([localizedText isEqualToString:localizable]) {
        // We don't have data for this stage! We have the Japanese (and maybe English)
        // name(s) for this stage. If the user's language is Japanese, great! If not, we'll
        // try to use the English name.
        if (![nameEN canBeConvertedToEncoding:NSISOLatin1StringEncoding]) {
            // Uh-oh, splatoon.ink hasn't provided an English name and has instead repeated the Japanese name.
            // Check our temporary stage mapping data to see if we can find the English name for this stage.
            // If there is no temporary mapping, then fall back to UNKNOWN_MAP.
            NSDictionary* temporaryMappings = [[SplatUtilities getUserDefaults] objectForKey:@"temporaryMappings"];
            NSString* temporaryMapping = [temporaryMappings objectForKey:nameEN];
            nameEN = (temporaryMapping == nil) ? NSLocalizedString(@"UNKNOWN_MAP", nil) : temporaryMapping;
        }
        
        [label setText:([SplatUtilities isDeviceLangaugeJapanese]) ? nameJP : nameEN];
        
        // Check if we have an image for this stage already. If we do, great! If not, default to
        // the generic question mark image.
        NSString* newLocalizable = [SplatUtilities toLocalizable:nameEN];
        [imageView setImage:[UIImage imageNamed:([NSLocalizedString(newLocalizable, nil) isEqualToString:newLocalizable]) ? @"UNKNOWN_MAP" : newLocalizable]];
        
        NSLog(@"No data for stage (en) \"%@\" (jp) \"%@\"!", nameEN, nameJP);
    } else {
        // Alright, we know this stage!
        label.text = localizedText;
        [imageView setImage:[UIImage imageNamed:localizable]];
    }
}

- (void) generateLoadingHudWithView:(UIView*) view {
    // Remove any existing MBProgressHUD that's already attached to this view.
    [MBProgressHUD hideAllHUDsForView:view animated:true];
    
    // Create a new MBProgressHUD attached to the view.
    MBProgressHUD* loadingHud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    loadingHud.mode = MBProgressHUDModeIndeterminate;
    loadingHud.labelText = NSLocalizedString(@"LOADING", nil);
}

- (void) removeCacheFilesExceptFor:(int) usedId {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* userRegion = [SplatUtilities getUserRegion];
    for (int i = 0; i != usedId; i++) {
        NSString* filePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"splatfest-%@-%i.jpg", userRegion, i]];
        if ([fileManager fileExistsAtPath:filePath]) {
            NSError* error;
            [fileManager removeItemAtPath:filePath error:&error];
            if (error) {
                [self errorOccurred:error when:@"ERROR_CLEARING_IMAGE_CACHE"];
                return;
            }
        }
    }
}

- (void) errorOccurred:(NSError*) error when:(NSString*) when {
    NSString* whenLocalized = NSLocalizedString(when, nil);
    NSString* errorLocalized = [error localizedDescription];
    NSString* alertText = [whenLocalized stringByAppendingFormat:@"\n\n%@%@\n\n%@", NSLocalizedString(@"ERROR_INTERNAL_DESCRIPTION", nil), errorLocalized, NSLocalizedString(@"ERROR_TRY_AGAIN", nil)];
    
    // Create a UIAlertView on the UI thread
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_TITLE", nil) message:alertText delegate:nil cancelButtonTitle:NSLocalizedString(@"CONFIRM", nil) otherButtonTitles:nil, nil];
        [errorAlert show];
    });
    
    // Log it in the console too (in case anybody is looking there)
    NSLog(@"%@ (Internal description: %@)", NSLocalizedString(when, nil), [error localizedDescription]);
    
    // Invalidate all download timers.
    if (self.stageRequestTimer) {
        [self.stageRequestTimer invalidate];
        self.stageRequestTimer = nil;
    }
}

/// Returns the currently selected rotation (Current/0, Next/1, Later/2)
- (NSInteger) getSelectedRotation {
    NSArray* settingsViewControllers = [[self.viewControllers objectAtIndex:SETTINGS_CONTROLLER] viewControllers];
    SettingsViewController* settingsController = (SettingsViewController*) [settingsViewControllers objectAtIndex:0];
    return [settingsController.rotationSelector selectedSegmentIndex];
}

/// Sets the selected rotation.
- (void) setSelectedRotation:(NSInteger) rotation {
    NSArray* settingsViewControllers = [[self.viewControllers objectAtIndex:SETTINGS_CONTROLLER] viewControllers];
    SettingsViewController* settingsController = (SettingsViewController*) [settingsViewControllers objectAtIndex:0];
    [settingsController.rotationSelector setSelectedSegmentIndex:rotation];
}

// Delegate Method ------------

- (BOOL) tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (self.needsInitialSetup) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SETTINGS_SELECT_REGION_FIRST_TITLE", nil) message:NSLocalizedString(@"SETTINGS_SELECT_REGION_FIRST_TEXT", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CONFIRM", nil) otherButtonTitles:nil, nil];
        [alert show];
        return false;
    }
    
    return true;
}

@end
