//
//  RegionViewController.h
//  SplatStages
//
//  Created by mac on 2015-10-09.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegionViewController : UITableViewController

@property NSIndexPath* oldIndex;
@property UILabel* settingsRegionLabel;
@property NSArray* userFacingRegionStrings;
@property NSArray* internalRegionStrings;

@end
