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
    
    if (!self.rotationCountdownCell) {
        self.rotationCountdownCell = (MessageCell*) [self getCellWithIdentifier:@"messageCell" tableView:self.tableView];
        [self.rotationCountdownCell.messageLabel setText:NSLocalizedString(@"TODAY_PLACEHOLDER", nil)];
    }
    
    if (!self.splatfestCountdownCell) {
        self.splatfestCountdownCell = (MessageCell*) [self getCellWithIdentifier:@"messageCell" tableView:self.tableView];
        [self.splatfestCountdownCell.messageLabel setText:NSLocalizedString(@"TODAY_PLACEHOLDER", nil)];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.rotationTimer) {
        [self.rotationTimer start];
    }
    
    if (self.splatfestTimer) {
        [self.splatfestTimer start];
    }
}

- (void) viewDidDisappear:(BOOL) animated {
    [super viewDidDisappear:animated];
    
    if (self.rotationTimer) {
        [self.rotationTimer invalidate];
    }
    
    if (self.splatfestTimer) {
        [self.splatfestTimer invalidate];
    }
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
        case 4:
            // TODO: ability to pick how many rotations are shown
            return 44;
        case 5:
            if ([[SplatUtilities getUserDefaults] objectForKey:@"showSplatfestInToday"] != nil) {
                return 0;
            }
            return 19;
        case 6:
            if ([[SplatUtilities getUserDefaults] objectForKey:@"showSplatfestInToday"] != nil) {
                return 0;
            } else {
                NSDictionary* splatfestData = [[SplatUtilities getUserDefaults] objectForKey:@"splatfestData"];
                NSDate* splatfestStart = [NSDate dateWithTimeIntervalSince1970:[[splatfestData objectForKey:@"startTime"] longLongValue]];
                NSDate* splatfestEnd = [NSDate dateWithTimeIntervalSince1970:[[splatfestData objectForKey:@"endTime"] longLongValue]];
                
                if ([splatfestStart timeIntervalSinceNow] < 0.0 && [splatfestEnd timeIntervalSinceNow] > 0.0) { // Splatfest started
                    return 44;
                }
            }
            return 29;
        case 7:
            if ([[SplatUtilities getUserDefaults] objectForKey:@"showSplatfestInToday"] != nil) {
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
            return self.rotationCountdownCell;
        }
        case 2:
        case 3:
        case 4: {
            NSInteger rotationNum = indexPath.row - 2; // for example, row 4 - 2 = index 2 in our schedule array
            NSArray* schedules = [[SplatUtilities getUserDefaults] objectForKey:@"schedule"];
            StagesCell* stagesCell = (StagesCell*) [self getCellWithIdentifier:@"stagesCell" tableView:tableView];
            
            // Check if there is a schedule
            if ([schedules count] <= 1) {
                // No schedule! Setup the cell with unknowns.
                [stagesCell setupWithUnknownStages];
            } else {
                // There is a schedule, continue with setup as normal.
                NSString* timePeriod = [NSString stringWithFormat:@"TODAY_TIME_PERIOD_%ld", (NSInteger) rotationNum + 1];
                [stagesCell setupWithSchedule:[schedules objectAtIndex:rotationNum] timePeriod:NSLocalizedString(timePeriod, nil)];
            }
            
            return stagesCell;
        }
        case 5: {
            HeaderCell* headerCell = (HeaderCell*) [self getCellWithIdentifier:@"headerCell" tableView:tableView];
            [headerCell.headerLabel setText:NSLocalizedString(@"TODAY_HEADER_SPLATFEST", nil)];
            return headerCell;
        }
        case 6: {
            return self.splatfestCountdownCell;
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
    completionHandler(NCUpdateResultNoData);
    
    if ([[SplatUtilities getUserDefaults] objectForKey:@"setupFinished"] == nil) {
        [self reloadTableViewWithCompletionHandler:^(){}];
        completionHandler(NCUpdateResultNewData);
        return;
    }
    
    [SplatDataFetcher requestFestivalDataWithCallback:^() {
        [SplatDataFetcher requestStageDataWithCallback:^(NSNumber* mode) {
            self.errorOccurred = false;
            [self reloadTableViewWithCompletionHandler:^{
                // Setup timers.
                [self setupRotationTimer];
                [self setupSplatfestTimer];
                
                // Populate all cells right now!
                for (int i = 0; i < 8; i++) {
                    [self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                }
                
                if ([mode isEqualToNumber:@1]) {
                    completionHandler(NCUpdateResultNoData);
                } else {
                    completionHandler(NCUpdateResultNewData);
                }
            }];
        } errorHandler:^(NSError* error, NSString* when) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self errorHasOccurred];
                completionHandler(NCUpdateResultFailed);
            });
        }];
    } errorHandler:^(NSError* error, NSString* when) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self errorHasOccurred];
            completionHandler(NCUpdateResultFailed);
        });
    }];
}

- (void) setupRotationTimer {
    NSArray* schedule = [[SplatUtilities getUserDefaults] objectForKey:@"schedule"];
    NSDate* nextRotation = [NSDate dateWithTimeIntervalSince1970:[[[schedule objectAtIndex:0] objectForKey:@"endTime"] longLongValue] / 1000];
    
    if (self.rotationTimer) {
        [self.rotationTimer invalidate];
        self.rotationTimer = nil;
    }
    
    self.rotationTimer = [[SplatTimer alloc] initRotationTimerWithDate:nextRotation labelOne:self.rotationCountdownCell.messageLabel labelTwo:nil textString:NSLocalizedString(@"ROTATION_COUNTDOWN", nil) timerFinishedHandler:^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Just in case, dispatch this on the main queue.
            [self.rotationCountdownCell.messageLabel setText:NSLocalizedString(@"ROTATION_NOW", nil)];
        });
        [self.rotationTimer invalidate];
        self.rotationTimer = nil;
    }];
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
        [self.splatfestTimer invalidate];
        self.splatfestTimer = nil;
    }
    
    if ([splatfestStart timeIntervalSinceNow] > 0.0) {
        // Splatfest is in the future.
        self.splatfestTimer = [[SplatTimer alloc] initFestivalTimerWithDate:splatfestStart label:self.splatfestCountdownCell.messageLabel textString:NSLocalizedString(@"SPLATFEST_UPCOMING_COUNTDOWN", nil) timeString:NSLocalizedString(@"SPLATFEST_UPCOMING_COUNTDOWN_TIME", nil) teamA:teamA teamB:teamB useThreeNumbers:false timerFinishedHandler:^(NSAttributedString* teamA, NSAttributedString* teamB) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSAttributedString* message = [NSAttributedString attributedStringWithFormat:NSLocalizedString(@"TODAY_SPLATFEST_STARTED", nil), teamA, teamB];
                [self.splatfestCountdownCell.messageLabel setAttributedText:message];
            });
            [self.splatfestTimer invalidate];
            self.splatfestTimer = nil;
        }];
    } else if ([splatfestStart timeIntervalSinceNow] < 0.0 && [splatfestEnd timeIntervalSinceNow] > 0.0) {
        // The Splatfest is going on right now!
        self.splatfestTimer = [[SplatTimer alloc] initFestivalTimerWithDate:splatfestEnd label:self.splatfestCountdownCell.messageLabel textString:NSLocalizedString(@"SPLATFEST_FINISH_COUNTDOWN", nil) timeString:NSLocalizedString(@"SPLATFEST_FINISH_COUNTDOWN_TIME", nil) teamA:teamA teamB:teamB useThreeNumbers:true timerFinishedHandler:^(NSAttributedString* teamA, NSAttributedString* teamB) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSAttributedString* message = [NSAttributedString attributedStringWithFormat:NSLocalizedString(@"SPLATFEST_FINISHED", nil), teamA, teamB];
                [self.splatfestCountdownCell.messageLabel setAttributedText:message];
            });
            [self.splatfestTimer invalidate];
            self.splatfestTimer = nil;
        }];
    } else {
        // The Splatfest has ended.
        NSAttributedString* message = [NSAttributedString attributedStringWithFormat:NSLocalizedString(@"SPLATFEST_FINISHED", nil), teamA, teamB];
        [self.splatfestCountdownCell.messageLabel setAttributedText:message];
    }
}

- (void) errorHasOccurred {
    if (self.rotationTimer) {
        [self.rotationTimer invalidate];
        self.rotationTimer = nil;
    }
    
    if (self.splatfestTimer) {
        [self.splatfestTimer invalidate];
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
