//
//  TodayViewController.h
//  SplatStagesToday
//
//  Created by mac on 2015-09-26.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <SplatStagesFramework/SplatStagesFramework.h>

@interface TodayViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView* tableView;

@property (strong, atomic) SSFRotationTimer* rotationTimer;
@property (strong, atomic) SSFSplatfestTimer* splatfestTimer;
@property (atomic) BOOL errorOccurred;

@end
