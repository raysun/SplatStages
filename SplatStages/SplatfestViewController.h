//
//  SplatfestViewController.h
//  SplatStages
//
//  Created by mac on 2015-09-04.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <SplatStagesFramework/SplatTimer.h>

#import <UIKit/UIKit.h>

#import "MBProgressHUD/MBProgressHUD.h"

@interface SplatfestViewController : UIViewController

// Countdown
@property (weak, nonatomic) IBOutlet UILabel* headerLabel;

// Image Container
@property (weak, nonatomic) IBOutlet UIView* imageContainer;
@property (weak, nonatomic) IBOutlet UIImageView* splatfestImageOne;

// Stage One Container
@property (weak, nonatomic) IBOutlet UIView* stageOneContainer;
@property (weak, nonatomic) IBOutlet UIImageView* stageOneImage;
@property (weak, nonatomic) IBOutlet UILabel* stageOneLabel;

// Stage Two Container
@property (weak, nonatomic) IBOutlet UIView* stageTwoContainer;
@property (weak, nonatomic) IBOutlet UIImageView* stageTwoImage;
@property (weak, nonatomic) IBOutlet UILabel* stageTwoLabel;

// Stage Three Container
@property (weak, nonatomic) IBOutlet UIView* stageThreeContainer;
@property (weak, nonatomic) IBOutlet UIImageView* stageThreeImage;
@property (weak, nonatomic) IBOutlet UILabel* stageThreeLabel;

// Results Container
@property (weak, nonatomic) IBOutlet UIView* resultsContainer;
@property (weak, nonatomic) IBOutlet UIImageView* splatfestImageTwo;
@property (weak, nonatomic) IBOutlet UILabel* resultsMessageLabel;
@property (weak, nonatomic) IBOutlet UIView* labelsContainer;

// Team A Container
@property (weak, nonatomic) IBOutlet UIView* teamAContainer;
@property (weak, nonatomic) IBOutlet UILabel* teamAName;
@property (weak, nonatomic) IBOutlet UILabel* teamAPop;
@property (weak, nonatomic) IBOutlet UILabel* teamAWinPercent;
@property (weak, nonatomic) IBOutlet UILabel* teamAFinalScore;

// Team B Results
@property (weak, nonatomic) IBOutlet UIView* teamBContainer;
@property (weak, nonatomic) IBOutlet UILabel* teamBName;
@property (weak, nonatomic) IBOutlet UILabel* teamBPop;
@property (weak, nonatomic) IBOutlet UILabel* teamBWinPercent;
@property (weak, nonatomic) IBOutlet UILabel* teamBFinalScore;

// Data
@property NSArray* teams;
@property SplatTimer* countdown;
@property int splatfestId;

// Team Names
@property NSAttributedString* teamANameString;
@property NSAttributedString* teamBNameString;

- (void) preliminarySetup:(NSArray*) teams id:(int) id;
- (void) setupViewSplatfestSoon:(NSDate*) startDate;
- (void) setupViewSplatfestStarted:(NSDate*) endDate stages:(NSArray*) stages;
- (void) setupViewSplatfestFinished:(NSArray*) results;

@end

