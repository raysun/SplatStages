//
//  RankedViewController.h
//  SplatStages
//
//  Created by mac on 2015-08-30.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD/MBProgressHUD.h"

@interface RankedViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *stageImageOne;
@property (weak, nonatomic) IBOutlet UIImageView *stageImageTwo;
@property (weak, nonatomic) IBOutlet UILabel *stageLabelOne;
@property (weak, nonatomic) IBOutlet UILabel *stageLabelTwo;
@property (weak, nonatomic) IBOutlet UILabel *rotationCountdownLabel;
@property (weak, nonatomic) IBOutlet UILabel *gamemodeLabel;
@property MBProgressHUD* loadingHud;

- (void) setupViewWithData:(NSDictionary*) data;
- (void) setLoading:(MBProgressHUD*) hud;
- (void) loadingFinished;

@end

