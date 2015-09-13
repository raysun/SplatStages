//
//  ViewController.m
//  SplatStages
//
//  Created by mac on 2015-08-25.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import "TabViewController.h"
#import "RegularViewController.h"
#import "RankedViewController.h"
#import "SplatfestViewController.h"
#import "SettingsViewController.h"

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
    // Request stage data asynchronously
    [self downloadAndParseJson:@"https://splatoon.ink/schedule.json" completionHandler:^(NSDictionary* data) {
        // Check if the data is stale, and return if it is.
        NSDate* dataLastUpdated = [NSDate dateWithTimeIntervalSince1970:[[data objectForKey:@"updateTime"] longLongValue] / 1000];
        NSLog(@"new data: %@ | old data: %@", dataLastUpdated, self.lastStageDataUpdate);
        if ([dataLastUpdated timeIntervalSinceDate:self.lastStageDataUpdate] <= 0.0) { // TODO something is wrong with the request timer
            NSLog(@"Data still stale, trying again later.");
            return;
        }
        
        NSLog(@"This data is fresh!");
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

}

- (void) getSplatfestData {
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
    [self getStageData];
    [self getSplatfestData];
}

// Schedules a timer to attempt to download Splatfest data every 60s.
- (void) scheduleStageDownloadTimer {
    self.stageRequestTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(getStageData) userInfo:nil repeats:true];
    [self.stageRequestTimer fire];
}

// Downloads the JSON data and then attempts to parse it into an NSDictionary.
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

// Downloads a file and returns an NSData instance.
- (void) downloadFile:(NSString*) urlString completionHandler:(void (^)(NSData* data)) completionHandler {
    NSURL* url = [NSURL URLWithString:urlString];
    NSURLSession* session = [NSURLSession sharedSession];
    
    // Asynchronously request the data.
    [[session dataTaskWithURL:url completionHandler:^(NSData* data, NSURLResponse* response, NSError* taskError) {
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
    });
    
}

- (void) setupStageView:(NSString*) nameEN nameJP:(NSString*) nameJP label:(UILabel*) label imageView:(UIImageView*) imageView {
    NSString* localizable = [self toLocalizable:nameEN];
    NSString* localizedText = NSLocalizedString(localizable, nil);
    if (localizedText == nil) {
        // We don't have data for this stage!
        // We have the Japanese (and maybe English) name(s) for this stage.
        // If the user's language is Japanese, great! If not, we'll just use the English name.
        if (nameEN == nil || [nameEN isEqualToString:@""]) {
            // We don't have the English name for this stage... Use UNKNOWN_MAP instead.
            nameEN = NSLocalizedString(@"UNKNOWN_MAP", nil);
        }
        
        [label setText:([self isUserLangaugeJapanese]) ? nameJP : nameEN];
        
        // We don't have a picture for this stage, so we'll use the default question mark image instead.
        [imageView setImage:[UIImage imageNamed:@"UNKNOWN_MAP"]];
        
        NSLog(@"No data for stage (en)\"%@\" (jp)\"%@\"!", nameEN, nameJP);
    } else {
        // Alright, we know this stage!
        label.text = localizedText;
        [imageView setImage:[UIImage imageNamed:localizable]];
    }
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
        UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_TITLE", nil) message:alertText delegate:nil cancelButtonTitle:NSLocalizedString(@"SETUP_CONFIRM", nil) otherButtonTitles:nil, nil];
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

// Convert the string to a localizable
// e.g. "Moray Towers" -> "MORAY_TOWERS"
- (NSString*) toLocalizable:(NSString*) string {
    return [[string stringByReplacingOccurrencesOfString:@" " withString:@"_"] uppercaseString];
}

- (BOOL) isUserLangaugeJapanese {
    NSString* deviceLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    return [deviceLanguage isEqualToString:@"ja"];
}

- (NSString*) getUserRegion {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"region"];
}

- (NSInteger) getSelectedRotation {
    // TODO change all references to this method to the ui selector's method
    SettingsViewController* settingsController = [self.viewControllers objectAtIndex:SETTINGS_CONTROLLER];
    return [settingsController.rotationSelector selectedSegmentIndex];
}

- (void) setSelectedRotation:(NSInteger) rotation {
    SettingsViewController* settingsController = [self.viewControllers objectAtIndex:SETTINGS_CONTROLLER];
    [settingsController.rotationSelector setSelectedSegmentIndex:rotation];
}

// Timer Method --------------

- (void) updateRotationTimer {
    RegularViewController* regularController = [self.viewControllers objectAtIndex:REGULAR_CONTROLLER];
    RankedViewController* rankedController = [self.viewControllers objectAtIndex:RANKED_CONTROLLER];
    
    NSLog(@"Time to next rotation: %f", [self.nextRotation timeIntervalSinceDate:[NSDate date]]);
    if ([self.nextRotation timeIntervalSinceDate:[NSDate date]] <= 0.0) {
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
