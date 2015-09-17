//
//  RegularViewController.m
//  SplatStages
//
//  Created by mac on 2015-08-30.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import "RegularViewController.h"
#import "TabViewController.h"

@interface RegularViewController ()

@end

@implementation RegularViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Set background
    UIImage* image = [UIImage imageNamed:@"BACKGROUND"];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:image]];
}

- (void) setupViewWithData:(NSDictionary*) data {
    TabViewController* rootController = (TabViewController*) [self tabBarController];
    NSArray* stages = [data objectForKey:@"maps"];
    
    // Set the Stage text and images
    NSString* stageOneEN = [[stages objectAtIndex:0] objectForKey:@"nameEN"];
    NSString* stageOneJP = [[stages objectAtIndex:0] objectForKey:@"nameJP"];
    NSString* stageTwoEN = [[stages objectAtIndex:1] objectForKey:@"nameEN"];
    NSString* stageTwoJP = [[stages objectAtIndex:1] objectForKey:@"nameJP"];
    
    [rootController setupStageView:stageOneEN nameJP:stageOneJP label:self.stageLabelOne imageView:self.stageImageOne];
    [rootController setupStageView:stageTwoEN nameJP:stageTwoJP label:self.stageLabelTwo imageView:self.stageImageTwo];
    
    // Regular Battles always have Turf War as their gamemode.
    [self.gamemodeLabel setText:NSLocalizedString(@"TURF_WAR", nil)];
}

- (void) setLoading:(MBProgressHUD*) hud {
    if (self.loadingHud) {
        [self loadingFinished];
    }
    
    self.loadingHud = hud;
    [self.loadingHud show:true];
}

- (void) loadingFinished {
    if (self.loadingHud) {
        [self.loadingHud hide:true];
        self.loadingHud = nil;
    }
}

@end