//
//  RegionViewController.m
//  SplatStages
//
//  Created by mac on 2015-10-09.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import "SplatStagesFramework/SplatUtilities.h"

#import "RegionViewController.h"
#import "TabViewController.h"

@interface RegionViewController ()

@end

@implementation RegionViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.userFacingRegionStrings = @[
                           NSLocalizedString(@"REGION_NORTH_AMERICA", nil),
                           NSLocalizedString(@"REGION_EUROPE", nil),
                           NSLocalizedString(@"REGION_JAPAN", nil),
#ifdef DEBUG
                           NSLocalizedString(@"REGION_DEBUG", nil),
#endif
                           ];
    self.internalRegionStrings = @[ @"na", @"eu", @"jp", @"debug" ];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) tableView:(UITableView*) tableView willDisplayCell:(UITableViewCell*) cell forRowAtIndexPath:(NSIndexPath*) indexPath {
    if (indexPath.section == 1)
        return;
    
    switch (indexPath.row) {
        case 0:
            if ([[SplatUtilities getUserRegion] isEqualToString:@"na"]) {
                self.oldIndex = indexPath;
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
        case 1:
            if ([[SplatUtilities getUserRegion] isEqualToString:@"eu"]) {
                self.oldIndex = indexPath;
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
        case 2:
            if ([[SplatUtilities getUserRegion] isEqualToString:@"jp"]) {
                self.oldIndex = indexPath;
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
        default:
            // This should *never* happen.
            break;
    }
}

// Thanks to Zyphrax at StackOverflow!
// http://stackoverflow.com/questions/2797165/uitableviewcell-checkmark-change-on-select
- (NSIndexPath*) tableView:(UITableView*) tableView willSelectRowAtIndexPath:(NSIndexPath*) indexPath {
    if (indexPath.section == 0) {
        NSLog(@"old: %li, new: %li", self.oldIndex.row, indexPath.row);
        [self.tableView cellForRowAtIndexPath:self.oldIndex].accessoryType = UITableViewCellAccessoryNone;
        [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        self.oldIndex = indexPath;
    }
    
    return indexPath;
}

- (void) tableView:(UITableView*) tableView didSelectRowAtIndexPath:(NSIndexPath*) indexPath {
    if ((long) indexPath.section == 1) {
        // User tapped on Save, so let's do just that!
        NSString* chosenRegionInternal = [self.internalRegionStrings objectAtIndex:self.oldIndex.row];
        NSString* chosenRegionUser = [self.userFacingRegionStrings objectAtIndex:self.oldIndex.row];
        NSMutableString* finishText = [NSMutableString stringWithFormat:NSLocalizedString(@"SETTINGS_REGION_SET_TEXT", nil), chosenRegionUser];
        
        // Add the outdated message to the text if the user is not in the NA region
        if (![chosenRegionInternal isEqualToString:@"na"]) {
            [finishText appendString:[NSString stringWithFormat:@"\n\n%@", NSLocalizedString(@"SETTINGS_REGION_SET_TEXT_OUTDATED", nil)]];
        }
        
        // Show the region set alert
        UIAlertView* finishAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SETTINGS_REGION_SET_TITLE", nil) message:finishText delegate:self cancelButtonTitle:NSLocalizedString(@"CONFIRM", nil) otherButtonTitles:nil, nil];
        [finishAlert show];
        
        // Update region label
        [self.settingsRegionLabel setText:chosenRegionUser];
        
        // Save this setting.
        NSUserDefaults* userDefaults = [SplatUtilities getUserDefaults];
        [userDefaults setObject:@1 forKey:@"setupFinished"];
        [userDefaults setObject:chosenRegionInternal forKey:@"region"];
        [userDefaults setObject:chosenRegionUser forKey:@"regionUserFacing"];
        [userDefaults synchronize];
        
        // Tell the TabViewController that it's okay to let the user out.
        TabViewController* rootController = (TabViewController*) self.tabBarController;
        rootController.needsInitialSetup = false;
        
        // Force a refresh of all the data.
        [rootController refreshAllData];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
