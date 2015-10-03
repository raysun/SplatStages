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

@property MessageCell* rotationCountdownCell;
@property MessageCell* splatfestCountdownCell;
@property SplatTimer* rotationTimer;
@property SplatTimer* splatfestTimer;
@property BOOL errorOccurred;

@end
