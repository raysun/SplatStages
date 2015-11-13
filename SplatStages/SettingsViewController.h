//
//  SettingsViewController.h
//  SplatStages
//
//  Created by mac on 2015-09-11.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#ifdef DEBUG
#warning Debug build detected; the Report an Issue button will set the region to "debug".
#endif

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel* regionLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl* rotationSelector;

@end

