//
//  RegionViewController.h
//  SplatStages
//
//  Created by mac on 2015-10-09.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegionViewController : UITableViewController

@property (strong, nonatomic) NSIndexPath* oldIndex;
@property (weak, nonatomic) UILabel* settingsRegionLabel;
@property (strong, nonatomic) NSArray* userFacingRegionStrings;
@property (strong, nonatomic) NSArray* internalRegionStrings;

@end
