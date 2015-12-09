//
//  StageViewController.h
//  SplatStages
//
//  Created by mac on 2015-12-08.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;
@property (weak, nonatomic) IBOutlet UILabel *gamemodeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *stageOneImage;
@property (weak, nonatomic) IBOutlet UILabel *stageOneLabel;
@property (weak, nonatomic) IBOutlet UIImageView *stageTwoImage;
@property (weak, nonatomic) IBOutlet UILabel *stageTwoLabel;

- (void) setupViewWithData:(NSDictionary*) data;

@end
