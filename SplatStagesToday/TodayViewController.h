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

@property (strong, nonatomic) MessageCell* rotationCountdownCell;
@property (strong, nonatomic) MessageCell* splatfestCountdownCell;
@property (strong, atomic) SplatTimer* rotationTimer;
@property (strong, atomic) SplatTimer* splatfestTimer;
@property (atomic) BOOL errorOccurred;

@end
