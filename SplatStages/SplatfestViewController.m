//
//  SplatfestViewController.m
//  SplatStages
//
//  Created by mac on 2015-09-04.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <SplatStagesFramework/SplatUtilities.h>

#import "NSAttributedString+CCLFormat.h"

#import "SplatfestViewController.h"
#import "TabViewController.h"

@interface SplatfestViewController ()

@end

@implementation SplatfestViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Set background
    UIImage* image = [UIImage imageNamed:@"BACKGROUND"];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:image]];
}

- (void) preliminarySetup:(NSArray*) teams id:(int) id {
    self.teams = teams;
    self.splatfestId = id;
    
    self.teamANameString = [self getTeamName:[self.teams objectAtIndex:0]];
    self.teamBNameString = [self getTeamName:[self.teams objectAtIndex:1]];
    
    if (self.countdown) {
        [self.countdown invalidate];
        self.countdown = nil;
    }
}

// Splatfest is upcoming
- (void) setupViewSplatfestSoon:(NSDate*) startDate {
    [self setDefaultVisibilitiesAndText];
    
    // Update image views.
    [self setupImages];
    
    // Update header label.
    [self.headerLabel setText:NSLocalizedString(@"SPLATFEST_ANNOUNCED", nil)];
    
    // Schedule the countdown timer.
    self.countdown = [[SplatTimer alloc] initFestivalTimerWithDate:startDate label:self.resultsMessageLabel textString:NSLocalizedString(@"SPLATFEST_UPCOMING_COUNTDOWN", nil) timeString:NSLocalizedString(@"SPLATFEST_UPCOMING_COUNTDOWN_TIME", nil) teamA:self.teamANameString teamB:self.teamBNameString useThreeNumbers:false timerFinishedHandler:^() {
        TabViewController* rootController = (TabViewController*) [self tabBarController];
        [rootController getSplatfestData];
        [self.countdown invalidate];
        self.countdown = nil;
    }];
}

// Splatfest has started.
- (void) setupViewSplatfestStarted:(NSDate*) endDate stages:(NSArray*) stages {
    [self setStageVisibilies:true];
    
    // Setup the stage text and images.
    TabViewController* rootController = (TabViewController*) [self tabBarController];
    [rootController setupStageView:[stages objectAtIndex:0] nameJP:nil label:self.stageOneLabel imageView:self.stageOneImage];
    [rootController setupStageView:[stages objectAtIndex:1] nameJP:nil label:self.stageTwoLabel imageView:self.stageTwoImage];
    [rootController setupStageView:[stages objectAtIndex:2] nameJP:nil label:self.stageThreeLabel imageView:self.stageThreeImage];
    
    self.countdown = [[SplatTimer alloc] initFestivalTimerWithDate:endDate label:self.headerLabel textString:NSLocalizedString(@"SPLATFEST_FINISH_COUNTDOWN", nil) timeString:NSLocalizedString(@"SPLATFEST_FINISH_COUNTDOWN_TIME", nil) teamA:self.teamANameString teamB:self.teamBNameString useThreeNumbers:true timerFinishedHandler:^() {
        TabViewController* rootController = (TabViewController*) [self tabBarController];
        [rootController getSplatfestData];
        [self.countdown invalidate];
        self.countdown = nil;
    }];
}

// Splatfest has finished.
- (void) setupViewSplatfestFinished:(NSArray*) results {
    [self setStageVisibilies:false];
    
    // Setup image views.
    [self setupImages];
    
    // Update header label.
    NSString* finishLocalized = NSLocalizedString(@"SPLATFEST_FINISHED", nil);
    NSAttributedString* finishText = [NSAttributedString attributedStringWithFormat:finishLocalized, self.teamANameString, self.teamBNameString];
    [self.headerLabel setAttributedText:finishText];

    // Setup the results.
    if (![[[results objectAtIndex:0] objectForKey:@"final"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
        // The results are available.
        [self setResultsVisbilities:true];
        [self setupResultsView:results team:0 opponents:1 teamLabel:self.teamAName popLabel:self.teamAPop winLabel:self.teamAWinPercent finalLabel:self.teamAFinalScore];
        [self setupResultsView:results team:1 opponents:0 teamLabel:self.teamBName popLabel:self.teamBPop winLabel:self.teamBWinPercent finalLabel:self.teamBFinalScore];
    } else {
        // Results are not available yet.
        [self setResultsVisbilities:false];
        [self.resultsMessageLabel setText:NSLocalizedString(@"SPLATFEST_SCORES_UNAVAILABLE", nil)];
    }
}

- (void) setupResultsView:(NSArray*) scores team:(int) team opponents:(int) opponents teamLabel:(UILabel*) teamLabel popLabel:(UILabel*) popLabel winLabel:(UILabel*) winLabel finalLabel:(UILabel*) finalLabel {
    // Get our team colour and the scores
    UIColor* teamColour = [self colorWithHexString:[[self.teams objectAtIndex:team] objectForKey:@"colour"]];
    NSDictionary* teamScores = [scores objectAtIndex:team];
    NSDictionary* opposingScores = [scores objectAtIndex:opponents];
    
    // Set the team name label's text
    [teamLabel setAttributedText:[self getTeamName:[self.teams objectAtIndex:team]]];
    
    // Get the colours we should set for the scores
    UIColor* popColour = ([[teamScores objectForKey:@"popularity"] compare:[opposingScores objectForKey:@"popularity"]] == NSOrderedDescending) ? teamColour : [UIColor whiteColor];
    UIColor* winColour = ([[teamScores objectForKey:@"winPercentage"] compare:[opposingScores objectForKey:@"winPercentage"]] == NSOrderedDescending) ? teamColour : [UIColor whiteColor];
    UIColor* finalColour = ([[teamScores objectForKey:@"final"] compare:[opposingScores objectForKey:@"final"]] == NSOrderedDescending) ? teamColour : [UIColor whiteColor];
    
    // Set the text on the score labels.
    [popLabel setAttributedText:[[NSAttributedString alloc] initWithString:[[teamScores objectForKey:@"popularity"] stringValue] attributes:@{NSForegroundColorAttributeName:popColour}]];
    [winLabel setAttributedText:[[NSAttributedString alloc] initWithString:[[teamScores objectForKey:@"winPercentage"] stringValue] attributes:@{NSForegroundColorAttributeName:winColour}]];
    [finalLabel setAttributedText:[[NSAttributedString alloc] initWithString:[[teamScores objectForKey:@"final"] stringValue] attributes:@{NSForegroundColorAttributeName:finalColour}]];
    
}

- (void) setupImages {
    NSString* cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* imagePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"splatfest-%@-%i.jpg", [SplatUtilities getUserRegion], self.splatfestId]];
    [self.splatfestImageOne setImage:[UIImage imageWithContentsOfFile:imagePath]];
    [self.splatfestImageTwo setImage:[UIImage imageWithContentsOfFile:imagePath]];
}

- (void) setDefaultVisibilitiesAndText {
    // Set default settings for view visibility
    [self setStageVisibilies:false];
    [self setResultsVisbilities:false];
    [self.resultsMessageLabel setText:NSLocalizedString(@"SPLATFEST_DATA_UNAVAILABLE", nil)];
}

- (void) setStageVisibilies:(BOOL) visibility {
    [self.stageOneContainer setHidden:!visibility];
    [self.stageTwoContainer setHidden:!visibility];
    [self.stageThreeContainer setHidden:!visibility];
    [self.imageContainer setHidden:visibility];
    [self.resultsContainer setHidden:visibility];
}

- (void) setResultsVisbilities:(BOOL) visibility {
    [self.teamAContainer setHidden:!visibility];
    [self.labelsContainer setHidden:!visibility];
    [self.teamBContainer setHidden:!visibility];
    [self.resultsMessageLabel setHidden:visibility];
}

- (NSAttributedString*) getTeamName:(NSDictionary*) teamData {
    UIColor* teamColour = [self colorWithHexString:[teamData objectForKey:@"colour"]];
    NSAttributedString* string = [[NSAttributedString alloc] initWithString:[teamData objectForKey:@"name"] attributes:@{NSForegroundColorAttributeName: teamColour}];
    return string;
}

// Thanks WrightsCS on StackOverflow!
// http://stackoverflow.com/questions/6207329/how-to-set-hex-color-code-for-background
- (UIColor*) colorWithHexString:(NSString*) hex
{
    NSString* cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString* rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString* gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString* bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}


@end