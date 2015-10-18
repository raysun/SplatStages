//
//  WidgetConfigViewController.h
//  SplatStages
//
//  Created by mac on 2015-10-18.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WidgetConfigViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIStepper* stepper;
@property (weak, nonatomic) IBOutlet UILabel* numberLabel;
@property NSNumber* rotationsShown;
@property BOOL hideSplatfestInformation;

@end
