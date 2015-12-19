//
//  TodayViewController.m
//  SplatStagesToday
//
//  Created by mac on 2015-09-26.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <NotificationCenter/NotificationCenter.h>

#import "NSAttributedString+CCLFormat.h"

#import "HeaderCell.h"
#import "MessageCell.h"
#import "StagesCell.h"
#import "TodayViewController.h"

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void) viewDidLoad {
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    
    // Start our timers again
    if (self.rotationTimer) {
        [self.rotationTimer start];
    }
    
    if (self.splatfestTimer) {
        [self.splatfestTimer start];
    }
    
    // Register as observers of our timer notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotationTimerTick:) name:@"rotationTimerTick" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotationTimerFinish:) name:@"rotationTimerFinished" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(splatfestTimerTick:) name:@"splatfestTimerTick" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(splatfestTimerFinish:) name:@"splatfestTimerFinished" object:nil];
}

- (void) viewWillDisappear:(BOOL) animated {
    [super viewWillDisappear:animated];
    
    // Stop our timers
    if (self.rotationTimer) {
        [self.rotationTimer stop];
    }
    
    if (self.splatfestTimer) {
        [self.splatfestTimer stop];
    }
    
    // Remove ourself as an observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"rotationTimerTick" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"rotationTimerFinished" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"splatfestTimerTick" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"splatfestTimerFinished" object:nil];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section {
    // Here's the eight cells:
    // - Schedule Header
    // - Rotation Countdown
    // - Stage 1
    // - Stage 2
    // - Stage 3
    // - Splatfest Header
    // - Splatfest Information (ex. countdown)
    // - Splatfest Stages
    
    return 8;
}

- (CGFloat) tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *) indexPath {
    // Check if app setup was completed or if there was an error.
    if ([[SplatUtilities getUserDefaults] objectForKey:@"setupFinished"] == nil || self.errorOccurred) {
        if (indexPath.row == 0) {
            return 44;
        } else {
            return 0;
        }
    }
    
    switch (indexPath.row) {
        case 0:
            return 19;
        case 1:
            return 29;
        case 2:
        case 3:
        case 4: {
            NSNumber* rotationsShown = [[SplatUtilities getUserDefaults] objectForKey:@"rotationsShown"];
            if (rotationsShown == nil) {
                [[SplatUtilities getUserDefaults] setObject:@(3) forKey:@"rotationsShown"];
                rotationsShown = @(3);
            }
            return ((rotationsShown.integerValue - indexPath.row + 1) < 0) ? 0 : 44;
        }
        case 5:
            if ([[SplatUtilities getUserDefaults] objectForKey:@"hideSplatfestInToday"] != nil) {
                return 0;
            }
            return 19;
        case 6:
            if ([[SplatUtilities getUserDefaults] objectForKey:@"hideSplatfestInToday"] != nil) {
                return 0;
            } else {
                return 38;
            }
        case 7:
            if ([[SplatUtilities getUserDefaults] objectForKey:@"hideSplatfestInToday"] != nil) {
                return 0;
            } else {
                NSDictionary* splatfestData = [[SplatUtilities getUserDefaults] objectForKey:@"splatfestData"];
                NSDate* splatfestStart = [NSDate dateWithTimeIntervalSince1970:[[splatfestData objectForKey:@"startTime"] longLongValue]];
                NSDate* splatfestEnd = [NSDate dateWithTimeIntervalSince1970:[[splatfestData objectForKey:@"endTime"] longLongValue]];
                
                if ([splatfestStart timeIntervalSinceNow] > 0.0 || [splatfestEnd timeIntervalSinceNow] < 0.0) { // Splatfest in the future or ended
                    return 0;
                }
            }
            return 44;
        default:
            return 44;
    }
}

- (UITableViewCell*) tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath*) indexPath {
    // Check if app setup was completed or if there was an error.
    if ([[SplatUtilities getUserDefaults] objectForKey:@"setupFinished"] == nil || self.errorOccurred) {
        if (indexPath.row == 0) {
            // Display a special message.
            MessageCell* messageCell = (MessageCell*) [self getCellWithIdentifier:@"messageCell" tableView:tableView];
            NSString* message = (self.errorOccurred) ? NSLocalizedString(@"TODAY_ERROR", nil) : NSLocalizedString(@"TODAY_DO_SETUP_FIRST", nil);
            [messageCell.messageLabel setText:message];
            return messageCell;
        } else {
            return [self getCellWithIdentifier:@"emptyCell" tableView:tableView];
        }
    }
    
    switch (indexPath.row) {
        case 0: {
            HeaderCell* headerCell = (HeaderCell*) [self getCellWithIdentifier:@"headerCell" tableView:tableView];
            [headerCell.headerLabel setText:NSLocalizedString(@"TODAY_HEADER_SCHEDULE", nil)];
            return headerCell;
        }
        case 1: {
            return [self getCellWithIdentifier:@"messageCell" tableView:self.tableView];
        }
        case 2:
        case 3:
        case 4: {
            NSInteger rotationNum = indexPath.row - 2; // for example, row 4 - 2 = index 2 in our schedule array
            NSArray* schedules = [NSKeyedUnarchiver unarchiveObjectWithData:[[SplatUtilities getUserDefaults] objectForKey:@"schedule"]];
            NSString* timePeriod = [NSString stringWithFormat:@"TODAY_TIME_PERIOD_%@", @(rotationNum + 1)];
            StagesCell* stagesCell = (StagesCell*) [self getCellWithIdentifier:@"stagesCell" tableView:tableView];
            
            [stagesCell setupWithRotation:[schedules objectAtIndex:rotationNum] timePeriod:timePeriod];
            
            return stagesCell;
        }
        case 5: {
            HeaderCell* headerCell = (HeaderCell*) [self getCellWithIdentifier:@"headerCell" tableView:tableView];
            [headerCell.headerLabel setText:NSLocalizedString(@"TODAY_HEADER_SPLATFEST", nil)];
            return headerCell;
        }
        case 6: {
            return [self getCellWithIdentifier:@"messageCell" tableView:self.tableView];
        }
        case 7: {
            NSArray* splatfestStages = [[[SplatUtilities getUserDefaults] objectForKey:@"splatfestData"] objectForKey:@"maps"];
            StagesCell* stagesCell = (StagesCell*) [self getCellWithIdentifier:@"stagesCell" tableView:tableView];
            [stagesCell setupWithSplatfestStages:splatfestStages];
            return stagesCell;
        }
        default:
            // This should NEVER happen.
            return [self getCellWithIdentifier:@"emptyCell" tableView:tableView];
    }
} 

- (UIEdgeInsets) widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets) defaultMarginInsets {
    return UIEdgeInsetsMake(defaultMarginInsets.top, defaultMarginInsets.left, 0, defaultMarginInsets.right);
}

- (void) widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    // Call the completionHandler before we even start fetching to ensure that
    // this method is continued to be called.
    completionHandler(NCUpdateResultNewData);
    
    if ([[SplatUtilities getUserDefaults] objectForKey:@"setupFinished"] == nil) {
        [self reloadTableViewWithCompletionHandler:^(){}];
        return;
    }
    
    [SplatDataFetcher requestFestivalDataWithCallback:^() {
        [SplatDataFetcher getSchedule:^{
            self.errorOccurred = false;
            [self reloadTableViewWithCompletionHandler:^{
                // Setup timers.
                [self setupSplatfestTimer];
                [self setupRotationTimer];
                
                // Populate all cells right now!
                for (int i = 0; i < 8; i++) {
                    [self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                }
            }];
        } errorHandler:^(NSError* error, NSString* when) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self errorHasOccurred];
            });
        }];
    } errorHandler:^(NSError* error, NSString* when) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self errorHasOccurred];
        });
    }];
}

- (void) setupRotationTimer {
    SSFRotation* rotation = [[NSKeyedUnarchiver unarchiveObjectWithData:[[SplatUtilities getUserDefaults] objectForKey:@"schedule"]] objectAtIndex:0];
    NSDate* nextRotation = [rotation endTime];
    
    if (self.rotationTimer) {
        [self.rotationTimer stop];
        self.rotationTimer = nil;
    }
    
    [self setRotationTimer:[[SSFRotationTimer alloc] initWithDate:nextRotation]];
    [self.rotationTimer start];
}



- (void) setupSplatfestTimer {
    NSDictionary* splatfestData = [[SplatUtilities getUserDefaults] objectForKey:@"splatfestData"];
    NSDate* splatfestStart = [NSDate dateWithTimeIntervalSince1970:[[splatfestData objectForKey:@"startTime"] longLongValue]];
    NSDate* splatfestEnd = [NSDate dateWithTimeIntervalSince1970:[[splatfestData objectForKey:@"endTime"] longLongValue]];
    
    // Get team names.
    NSArray* teams = [splatfestData objectForKey:@"teams"];
    NSAttributedString* teamA = [SplatUtilities getSplatfestTeamName:[teams objectAtIndex:0]];
    NSAttributedString* teamB = [SplatUtilities getSplatfestTeamName:[teams objectAtIndex:1]];
    
    if (self.splatfestTimer) {
        [self.splatfestTimer stop];
        self.splatfestTimer = nil;
    }
    
    if ([splatfestStart timeIntervalSinceNow] > 0.0) {
        // Splatfest is in the future.
        self.splatfestTimer = [[SSFSplatfestTimer alloc] initWithDate:splatfestStart teamA:teamA teamB:teamB showDays:true];
        [self.splatfestTimer start];
    } else if ([splatfestStart timeIntervalSinceNow] < 0.0 && [splatfestEnd timeIntervalSinceNow] > 0.0) {
        // The Splatfest is going on right now!
        self.splatfestTimer = [[SSFSplatfestTimer alloc] initWithDate:splatfestEnd teamA:teamA teamB:teamB showDays:false];
        [self.splatfestTimer start];
    } else {
        // The Splatfest has ended.
        MessageCell* messageCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];
        [messageCell.messageLabel setAttributedText:[NSAttributedString attributedStringWithFormat:[SplatUtilities localizeString:@"SPLATFEST_FINISHED"], teamA, teamB]];
    }
}

- (void) rotationTimerTick:(NSNotification*) notification {
    MessageCell* messageCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [messageCell.messageLabel setText:[[notification userInfo] objectForKey:@"countdownString"]];
}

- (void) rotationTimerFinish:(NSNotification*) notification {
    MessageCell* messageCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [messageCell.messageLabel setText:[SplatUtilities localizeString:@"ROTATION_NOW"]];
    self.rotationTimer = nil;
}

- (void) splatfestTimerTick:(NSNotification*) notification {
    MessageCell* messageCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];
    [messageCell.messageLabel setAttributedText:[[notification userInfo] objectForKey:@"countdownString"]];
}

- (void) splatfestTimerFinish:(NSNotification*) notification {
    [self setupSplatfestTimer];
}


- (void) errorHasOccurred {
    if (self.rotationTimer) {
        [self.rotationTimer stop];
        self.rotationTimer = nil;
    }
    
    if (self.splatfestTimer) {
        [self.splatfestTimer stop];
        self.splatfestTimer = nil;
    }
    
    self.errorOccurred = true;
    
    [self reloadTableViewWithCompletionHandler:^(){}];
}

- (void) reloadTableViewWithCompletionHandler:(void (^)()) completionHandler {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Queue this first to make sure that reloadData is finished before we move on
        [self.tableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            // Set the new height of the tableView and set the preferredContentSize.
            self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.contentSize.height);
            self.preferredContentSize = self.tableView.contentSize;
            
            // Run the completion handler.
            completionHandler();
        });
    });
}

//! A utility method that returns a cell with the provided identifier.
- (UITableViewCell*) getCellWithIdentifier:(NSString*) identifier tableView:(UITableView*) tableView {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    return cell;
}

@end
