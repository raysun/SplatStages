//
//  WidgetConfigViewController.m
//  SplatStages
//
//  Created by mac on 2015-10-18.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <SplatStagesFramework/SplatUtilities.h>

#import "WidgetConfigViewController.h"

@interface WidgetConfigViewController ()

@end

@implementation WidgetConfigViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults* userDefaults = [SplatUtilities getUserDefaults];
    self.rotationsShown = [userDefaults objectForKey:@"rotationsShown"];
    if (self.rotationsShown == nil) {
        [userDefaults setObject:@(3) forKey:@"rotationsShown"];
        [userDefaults synchronize];
        self.rotationsShown = @(3);
    }
    [self.stepper setValue:[self.rotationsShown doubleValue]];
    [self updateNumberLabel];
    
    self.hideSplatfestInformation = [userDefaults objectForKey:@"hideSplatfestInToday"] != nil;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) tableView:(UITableView*) tableView willDisplayCell:(UITableViewCell*) cell forRowAtIndexPath:(NSIndexPath*) indexPath {
    if (indexPath.section == 0 && indexPath.row == 1) {
        if (self.hideSplatfestInformation) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

- (void) tableView:(UITableView*) tableView didSelectRowAtIndexPath:(NSIndexPath*) indexPath {
    if (indexPath.section == 1) {
        // Show a settings saved alert
        UIAlertView* finishAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SETTINGS_SAVED_TITLE", nil) message:NSLocalizedString(@"SETTINGS_SAVED_TEXT", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CONFIRM", nil) otherButtonTitles:nil, nil];
        [finishAlert show];
        
        // Save the settings.
        NSUserDefaults* userDefaults = [SplatUtilities getUserDefaults];
        [userDefaults setObject:self.rotationsShown forKey:@"rotationsShown"];
        if (self.hideSplatfestInformation) {
            [userDefaults setObject:@"" forKey:@"hideSplatfestInToday"];
        } else {
            [userDefaults removeObjectForKey:@"hideSplatfestInToday"];
        }
        [userDefaults synchronize];
    } else if (indexPath.row == 1) {
        self.hideSplatfestInformation = !self.hideSplatfestInformation;
        if (self.hideSplatfestInformation) {
            [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction) valueChanged:(UIStepper*) sender {
    self.rotationsShown = @([sender value]);
    [self updateNumberLabel];
}

- (void) updateNumberLabel {
    [self.numberLabel setText:[NSString stringWithFormat:@"%@", self.rotationsShown]];
}


@end
