//
//  SettingsViewController.m
//  SplatStages
//
//  Created by mac on 2015-09-11.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <SplatStagesFramework/SplatUtilities.h>

#import "SettingsViewController.h"
#import "TabViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the picker options arrays
    self.pickerOptions = [[NSArray alloc] initWithObjects:NSLocalizedString(@"REGION_NORTH_AMERICA", nil), NSLocalizedString(@"REGION_EUROPE", nil), NSLocalizedString(@"REGION_JAPAN", nil), NSLocalizedString(@"REGION_DEBUG", nil), nil];
    self.internalRegionStrings = [[NSArray alloc] initWithObjects:@"na", @"eu", @"jp", @"debug", nil];
    
    // Setup the UISegmentedControl callback
    [self.rotationSelector addTarget:self action:@selector(userSelectedRotation:) forControlEvents:UIControlEventValueChanged];
    
    // Set background
    UIImage* image = [UIImage imageNamed:@"BACKGROUND"];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:image]];
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *) pickerView {
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *) pickerView numberOfRowsInComponent:(NSInteger) component {
#ifdef DEBUG
    return self.pickerOptions.count;
#else
    // Hide the "Debug" region in release builds.
    return self.pickerOptions.count - 1;
#endif
}

- (NSAttributedString*) pickerView:(UIPickerView *) pickerView attributedTitleForRow:(NSInteger) row forComponent:(NSInteger) component {
    return [[NSAttributedString alloc] initWithString:[self.pickerOptions objectAtIndex:row] attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (IBAction) regionConfirmed:(id) sender {
    NSString* chosenRegion = [self.pickerOptions objectAtIndex:[self.pickerView selectedRowInComponent:0]];
    NSString* confirmRegionLocalized = [NSString stringWithFormat:NSLocalizedString(@"SETTINGS_CONFIRM_REGION_TEXT", nil), chosenRegion];
    
    UIAlertView* confirmRegionAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SETTINGS_CONFIRM_REGION_TITLE", nil) message:confirmRegionLocalized delegate:self cancelButtonTitle:NSLocalizedString(@"CONFIRM", nil) otherButtonTitles:NSLocalizedString(@"CANCEL", nil), nil];
    confirmRegionAlert.tag = 1;
    [confirmRegionAlert show];
}

- (IBAction) refreshData:(id) sender {
    TabViewController* rootController = (TabViewController*) [self tabBarController];
    [rootController refreshAllData];
}

- (IBAction) showAbout:(id) sender {
    NSString* bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString* displayName = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
    NSString* aboutTitle = [NSString stringWithFormat:@"%@ (%@)", displayName, bundleVersion];
    UIAlertView* aboutAlert = [[UIAlertView alloc] initWithTitle:aboutTitle message:NSLocalizedString(@"SETTINGS_ABOUT_TEXT", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CONFIRM", nil) otherButtonTitles:nil, nil];
    [aboutAlert show];
}

- (void) alertView:(UIAlertView *) alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        // Confirm Region Alert
        
        if (buttonIndex == 0) {
            // User picked OK, so let's setup the done alert + save settings
            NSString* chosenRegionInternal = [self.internalRegionStrings objectAtIndex:[self.pickerView selectedRowInComponent:0]];
            NSString* chosenRegionUser = [self.pickerOptions objectAtIndex:[self.pickerView selectedRowInComponent:0]];
            NSMutableString* finishText = [NSMutableString stringWithFormat:NSLocalizedString(@"SETTINGS_DONE_TEXT", nil), chosenRegionUser];
            
            // Add the outdated message to the text if the user is not in the NA region
            if (![chosenRegionInternal isEqualToString:@"na"]) {
                [finishText appendString:[NSString stringWithFormat:@"\n\n%@", NSLocalizedString(@"SETTINGS_DONE_TEXT_OUTDATED", nil)]];
            }
            
            // Show the finished setup alert
            UIAlertView* finishAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SETTINGS_DONE_TITLE", nil) message:finishText delegate:self cancelButtonTitle:NSLocalizedString(@"CONFIRM", nil) otherButtonTitles:nil, nil];
            finishAlert.tag = 2;
            [finishAlert show];
            
            // Save this setting.
            NSUserDefaults* userDefaults = [SplatUtilities getUserDefaults];
            [userDefaults setObject:@1 forKey:@"setupFinished"];
            [userDefaults setObject:chosenRegionInternal forKey:@"region"];
            [userDefaults synchronize];
            
            // Tell the TabViewController that it's okay to let the user out.
            TabViewController* rootController = (TabViewController*) self.tabBarController;
            rootController.needsInitialSetup = false;
        } else {
            // Cancelled, do nothing.
            [alertView dismissWithClickedButtonIndex:-1 animated:true];
        }
    } else if (alertView.tag == 2) {
        // Finished Setup Alert
        // Force a refresh of all the data.
        [self.refreshDataButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

- (void) userSelectedRotation:(NSInteger) rotation {
    TabViewController* rootController = (TabViewController*) [self tabBarController];
    [rootController setStages];
}

@end