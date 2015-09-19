//
//  ViewController.m
//  SplatStages
//
//  Created by mac on 2015-08-25.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

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
    
    // Setup the calendar stuff we need.
    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    self.calendarUnits = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    // Setup the NSURLSession.
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    self.urlSession = [NSURLSession sessionWithConfiguration:configuration];
    
    // Set the default last update date (in unix time, 0)
    self.lastStageDataUpdate = [NSDate dateWithTimeIntervalSince1970:0];
    
    // Force all our views to load right now.
    [self.viewControllers makeObjectsPerformSelector:@selector(view)];
    
    // Check if we need to do the initial setup.
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"setupFinished"] == nil) {
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
    // TODO Should we be doing anything here...?
}

// Data Methods ---------------

// Sends requests for all the data we need
- (void) getStageData {
    // Add an MBProgressHUD instance to each of our stage view controllers.
    RegularViewController* regularViewController = [self.viewControllers objectAtIndex:REGULAR_CONTROLLER];
    RankedViewController* rankedViewController = [self.viewControllers objectAtIndex:RANKED_CONTROLLER];
    [self generateLoadingHudWithView:regularViewController.view];
    [self generateLoadingHudWithView:rankedViewController.view];
    
    // Get the Temporary Stage Mapping, which contains the English names for maps that aren't supported by splatoon.ink yet.
    [self downloadAndParseJson:@"https://oatmealdome.github.io/splatcompanion/temporary-stage-mapping.json" completionHandler:^(NSDictionary* data) {
        self.temporaryStageMapping = data;
        
        // Request stage data asynchronously
        [self downloadAndParseJson:@"https://splatoon.ink/schedule.json" completionHandler:^(NSDictionary* data) {
            // Check if the data is stale, and return if it is.
            NSDate* dataLastUpdated = [NSDate dateWithTimeIntervalSince1970:[[data objectForKey:@"updateTime"] longLongValue] / 1000];
            if ([dataLastUpdated timeIntervalSinceDate:self.lastStageDataUpdate] <= 0.0) {
                [self setStageLoadingFinished];
                return;
            }
            
            // Check for the rotation download timer and stops it.
            if (self.stageRequestTimer) {
                [self.stageRequestTimer invalidate];
                self.stageRequestTimer = nil;
            }
            
            // Check for the stage rotation timer and get rid of it.
            if (self.rotationTimer) {
                [self.rotationTimer invalidate];
                self.rotationTimer = nil;
            }
            
            // Set all our data variables.
            [self setSelectedRotation:0];
            self.lastStageDataUpdate = dataLastUpdated;
            self.schedule = [data objectForKey:@"schedule"];
            
            // Check if there's no schedule (for example, splatoon.ink returns nothing of value during Splatfests)
            if ([self.schedule count] == 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setStagesUnavailable];
                });
                return;
            }
            
            // splatoon.ink gives unix time in milliseconds, so we convert it into real unix time here
            NSTimeInterval nextInEpoch = [[[self.schedule objectAtIndex:0] objectForKey:@"endTime"] longLongValue] / 1000;
            self.nextRotation = [NSDate dateWithTimeIntervalSince1970:nextInEpoch];
            
            // This needs to be called on the UI thread so we can update it.
            // We also schedule the rotation timer here.
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setStages];
                self.rotationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateRotationTimer) userInfo:nil repeats:true];
            });
        }];
    }];
    
}

- (void) getSplatfestData {
    // Add an MBProgressHUD instance to our Splatfest view controller.
    SplatfestViewController* splatfestViewController = [self.viewControllers objectAtIndex:SPLATFEST_CONTROLLER];
    [self generateLoadingHudWithView:[splatfestViewController view]];
    
    // Request Splatfest data asynchronously
    [self downloadAndParseJson:@"https://oatmealdome.github.io/splatcompanion/splatfest.json" completionHandler:^(NSDictionary* data) {
        // Check for the Splatfest countdown timer.
        SplatfestViewController* viewController = [[self viewControllers] objectAtIndex:SPLATFEST_CONTROLLER];
        if (viewController.countdown) {
            [viewController.countdown invalidate];
            viewController.countdown = nil;
        }
        
        // Set the data variables.
        self.splatfestData = [data objectForKey:[self getUserRegion]];
        int splatfestId = [[self.splatfestData objectForKey:@"id"] intValue];
        
        // Clear the image cache for any leftover images.
        [self removeCacheFilesExceptFor:splatfestId];
        
        // Check if the Splatfest image still exists.
        NSString* cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* imagePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"splatfest-%@-%i.jpg", [self getUserRegion], splatfestId]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
            // Skip straight to UI setup, we don't need to download anything.
            [self setupSplatfestWithId:splatfestId];
            return;
        }
        
        // We need to get the image file first.
        [self downloadFile:[self.splatfestData objectForKey:@"image"] completionHandler:^(NSData* data) {
            [data writeToFile:imagePath atomically:true];
            [self setupSplatfestWithId:splatfestId];
        }];
    }];
}
- (void) refreshAllData {
    // Make sure this is called on the main thread so we can update the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getStageData];
        [self getSplatfestData];
    });
}

/// Schedules a timer to attempt to download Splatfest data every 60s.
- (void) scheduleStageDownloadTimer {
    self.stageRequestTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(getStageData) userInfo:nil repeats:true];
    [self.stageRequestTimer fire];
}

/// Downloads the JSON data and then attempts to parse it into an NSDictionary.
- (void) downloadAndParseJson:(NSString*) urlString completionHandler:(void (^)(NSDictionary* dict)) completionHandler {
    [self downloadFile:urlString completionHandler:^(NSData* data) {
        // Attempt to parse the data.
        NSError* jsonError;
        NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
        
        // Check for a error first
        if (jsonError) {
            [self errorOccurred:jsonError when:@"ERROR_PARSING_JSON"];
            return;
        }
        
        // Call the completion handler.
        completionHandler(jsonDict);
    }];
}

/// Downloads a file and returns an NSData instance.
- (void) downloadFile:(NSString*) urlString completionHandler:(void (^)(NSData* data)) completionHandler {
    NSURL* url = [NSURL URLWithString:urlString];
    
    // Asynchronously request the data.
    [[self.urlSession dataTaskWithURL:url completionHandler:^(NSData* data, NSURLResponse* response, NSError* taskError) {
        // Check for an error first
        if (taskError) {
            [self errorOccurred:taskError when:@"ERROR_DOWNLOADING_DATA"];
            return;
        }
        
        // Call the completion handler.
        completionHandler(data);
    }] resume];
}

- (void) setStages {
    if (self.schedule == nil) {
        // Just in case.
        return;
    }
    
    // Get the stages for the chosen rotation and setup the Regular and Ranked tabs
    NSDictionary* chosenSchedule = [self.schedule objectAtIndex:[self getSelectedRotation]];
    RegularViewController* regularViewController = [self.viewControllers objectAtIndex:REGULAR_CONTROLLER];
    RankedViewController* rankedViewController = [self.viewControllers objectAtIndex:RANKED_CONTROLLER];
    [regularViewController setupViewWithData:[chosenSchedule objectForKey:@"regular"]];
    [rankedViewController setupViewWithData:[chosenSchedule objectForKey:@"ranked"]];
    
    // Clear any MBProgressHUDs currently attached to the views.
    [MBProgressHUD hideAllHUDsForView:regularViewController.view animated:true];
    [MBProgressHUD hideAllHUDsForView:rankedViewController.view animated:true];
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
                                            },
                                            @{
                                                @"nameEN" : @"UNKNOWN_MAP"
                                            }
                                        ],
                                @"rulesEN" : @"UNKNOWN_GAMEMODE"
                              };
    
    // Setup the views
    RegularViewController* regularViewController = [self.viewControllers objectAtIndex:REGULAR_CONTROLLER];
    RankedViewController* rankedViewController = [self.viewControllers objectAtIndex:RANKED_CONTROLLER];
    [regularViewController setupViewWithData:unknown];
    [rankedViewController setupViewWithData:unknown];
    
    // Set the rotation countdown labels
    [regularViewController.rotationCountdownLabel setText:NSLocalizedString(@"ROTATION_SPLATFEST", nil)];
    [rankedViewController.rotationCountdownLabel setText:NSLocalizedString(@"ROTATION_SPLATFEST", nil)];
    
    // Clear any MBProgressHUDs currently attached to the views.
    [MBProgressHUD hideAllHUDsForView:regularViewController.view animated:true];
    [MBProgressHUD hideAllHUDsForView:rankedViewController.view animated:true];
}

- (void) setupSplatfestWithId:(int) splatfestId {
    // Get the time period of the Splatfest
    NSDate* splatfestStart = [NSDate dateWithTimeIntervalSince1970:[[self.splatfestData objectForKey:@"startTime"] longLongValue]];
    NSDate* splatfestEnd = [NSDate dateWithTimeIntervalSince1970:[[self.splatfestData objectForKey:@"endTime"] longLongValue]];
    
    SplatfestViewController* splatfestViewController = [self.viewControllers objectAtIndex:SPLATFEST_CONTROLLER];
    
    // Do preliminary setup (set variables in the view controller)
    [splatfestViewController preliminarySetup:[self.splatfestData objectForKey:@"teams"] id:splatfestId];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // We need to be on the UI thread to change the layout and contents.
        // Check if a Splatfest is in the future, has started, or has passed.
        if ([splatfestStart timeIntervalSinceNow] > 0.0) {
            // Splatfest is in the future.
            [splatfestViewController setupViewSplatfestSoon:splatfestStart];
        } else if ([splatfestStart timeIntervalSinceNow] < 0.0 && [splatfestEnd timeIntervalSinceNow] > 0.0) {
            // The Splatfest is going on right now!
            [splatfestViewController setupViewSplatfestStarted:splatfestEnd stages:[self.splatfestData objectForKey:@"maps"]];
        } else {
            // The Splatfest has ended.
            [splatfestViewController setupViewSplatfestFinished:[self.splatfestData objectForKey:@"results"]];
        }
        [MBProgressHUD hideAllHUDsForView:splatfestViewController.view animated:true];
    });
    
}

- (void) setupStageView:(NSString*) nameEN nameJP:(NSString*) nameJP label:(UILabel*) label imageView:(UIImageView*) imageView {
    NSString* localizable = [self toLocalizable:nameEN];
    NSString* localizedText = NSLocalizedString(localizable, nil);
    if ([localizedText isEqualToString:localizable]) {
        // We don't have data for this stage! We have the Japanese (and maybe English)
        // name(s) for this stage. If the user's language is Japanese, great! If not, we'll
        // try to use the English name.
        if (![nameEN canBeConvertedToEncoding:NSISOLatin1StringEncoding]) {
            // Uh-oh, splatoon.ink hasn't provided an English name and has instead repeated the Japanese name.
            // Check our temporary stage mapping data to see if we can find the English name for this stage.
            // If there is no temporary mapping, then fall back to UNKNOWN_MAP.
            NSString* temporaryMapping = [self.temporaryStageMapping objectForKey:nameEN];
            nameEN = (temporaryMapping == nil) ? NSLocalizedString(@"UNKNOWN_MAP", nil) : temporaryMapping;
        }
        
        [label setText:([self isDeviceLangaugeJapanese]) ? nameJP : nameEN];
        
        // Check if we have an image for this stage already. If we do, great! If not, default to
        // the generic question mark image.
        NSString* newLocalizable = [self toLocalizable:nameEN];
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

- (void) setStageLoadingFinished {
    dispatch_async(dispatch_get_main_queue(), ^{
        RegularViewController* regularViewController = [self.viewControllers objectAtIndex:REGULAR_CONTROLLER];
        RankedViewController* rankedViewController = [self.viewControllers objectAtIndex:RANKED_CONTROLLER];
        [MBProgressHUD hideAllHUDsForView:regularViewController.view animated:true];
        [MBProgressHUD hideAllHUDsForView:rankedViewController.view animated:true];
    });
}

- (void) removeCacheFilesExceptFor:(int) usedId {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* userRegion = [self getUserRegion];
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

/// Convert the string to a localizable (e.g. "Moray Towers" -> "MORAY_TOWERS")
- (NSString*) toLocalizable:(NSString*) string {
    return [[string stringByReplacingOccurrencesOfString:@" " withString:@"_"] uppercaseString];
}

/// Returns if the user's language is currently Japanese.
- (BOOL) isDeviceLangaugeJapanese {
    NSString* deviceLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    return [deviceLanguage isEqualToString:@"ja"];
}

// Returns the user's selected Splatoon region
- (NSString*) getUserRegion {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"region"];
}

/// Returns the currently selected rotation (Current/0, Next/1, Later/2)
- (NSInteger) getSelectedRotation {
    SettingsViewController* settingsController = [self.viewControllers objectAtIndex:SETTINGS_CONTROLLER];
    return [settingsController.rotationSelector selectedSegmentIndex];
}

/// Sets the selected rotation.
- (void) setSelectedRotation:(NSInteger) rotation {
    SettingsViewController* settingsController = [self.viewControllers objectAtIndex:SETTINGS_CONTROLLER];
    [settingsController.rotationSelector setSelectedSegmentIndex:rotation];
}

// Timer Method --------------

- (void) updateRotationTimer {
    RegularViewController* regularController = [self.viewControllers objectAtIndex:REGULAR_CONTROLLER];
    RankedViewController* rankedController = [self.viewControllers objectAtIndex:RANKED_CONTROLLER];
    
    if ([self.nextRotation timeIntervalSinceNow] <= 0.0) {
        // Rotating now! Update the UI first and update the schedule data in the background.
        NSString* rotatingNowText = NSLocalizedString(@"ROTATION_NOW", nil);
        [regularController.rotationCountdownLabel setText:rotatingNowText];
        [rankedController.rotationCountdownLabel setText:rotatingNowText];
        [self setSelectedRotation:1];
        [self setStages];
        [self scheduleStageDownloadTimer];
        [self.rotationTimer invalidate];
        self.rotationTimer = nil;
    } else {
        NSString* rotationCountdownText;
        if ([self getSelectedRotation] != 0) {
            rotationCountdownText = NSLocalizedString(@"ROTATION_FUTURE", nil);
        } else {
            NSDateComponents* components = [self.calendar components:self.calendarUnits fromDate:[NSDate date] toDate:self.nextRotation options:0];
            rotationCountdownText = [NSString stringWithFormat:NSLocalizedString(@"ROTATION_COUNTDOWN", nil), [components hour], [components minute], [components second]];
        }
        [regularController.rotationCountdownLabel setText:rotationCountdownText];
        [rankedController.rotationCountdownLabel setText:rotationCountdownText];
    }
}

- (BOOL) tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (self.needsInitialSetup) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SETTINGS_SELECT_REGION_FIRST_TITLE", nil) message:NSLocalizedString(@"SETTINGS_SELECT_REGION_FIRST_TEXT", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CONFIRM", nil) otherButtonTitles:nil, nil];
        [alert show];
        return false;
    }
    
    return true;
}

@end
