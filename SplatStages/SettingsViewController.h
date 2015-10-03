//
//  SettingsViewController.h
//  SplatStages
//
//  Created by mac on 2015-09-11.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel* regionLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl* rotationSelector;
@property (weak, nonatomic) IBOutlet UIButton* refreshDataButton;
@property NSArray* pickerOptions;
@property NSArray* internalRegionStrings;
@property NSInteger chosenRegion;

@end

