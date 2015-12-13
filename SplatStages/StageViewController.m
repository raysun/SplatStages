//
//  StageViewController.m
//  SplatStages
//
//  Created by mac on 2015-12-08.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <SplatStagesFramework/SplatUtilities.h>

#import "StageViewController.h"
#import "TabViewController.h"

@implementation StageViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Set background - a generic background is used in attempt to comply with App Store guidelines
    UIImage* image = [UIImage imageNamed:@"GENERIC_BACKGROUND"];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:image]];
    
    // Update status bar
    [self setNeedsStatusBarAppearanceUpdate];
    
}

- (void) setupViewWithData:(SSFRotation*) data {
    TabViewController* rootController = (TabViewController*) [self tabBarController];
    
    NSString* mapOne;
    NSString* mapTwo;
    if ([self ranked]) {
        mapOne = [data rankedStageOne];
        mapTwo = [data rankedStageTwo];
        
        NSString* gamemode = [data rankedGamemode];
        NSString* localizedGamemode = NSLocalizedString(gamemode, nil);
        if ([localizedGamemode isEqualToString:gamemode]) {
            self.gamemodeLabel.text = NSLocalizedString(@"UNKNOWN_GAMEMODE", nil);
        }
        self.gamemodeLabel.text = localizedGamemode;
    } else {
        mapOne = [data regularStageOne];
        mapTwo = [data regularStageTwo];
        
        self.gamemodeLabel.text = NSLocalizedString(@"TURF_WAR", nil);
    }
    
    [rootController setupStageView:mapOne nameJP:@"" label:self.stageOneLabel imageView:self.stageOneImage];
    [rootController setupStageView:mapTwo nameJP:@"" label:self.stageTwoLabel imageView:self.stageTwoImage];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
