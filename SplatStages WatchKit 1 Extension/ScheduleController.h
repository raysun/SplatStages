//
//  ScheduleController.h
//  SplatStages
//
//  Created by mac on 2015-11-21.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface ScheduleController : WKInterfaceController

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel* regularMapOne;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel* regularMapTwo;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel* rankedGamemode;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel* rankedMapOne;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel* rankedMapTwo;

@property (nonatomic) NSInteger selectedRotation;

@end
