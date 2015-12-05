//
//  SplatfestController.h
//  SplatStages
//
//  Created by mac on 2015-11-28.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SplatStagesFramework/SplatTimer.h>

#import <WatchKit/WatchKit.h>

@interface SplatfestController : WKInterfaceController

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel* messageLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceSeparator* separator;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceGroup* stagesGroup;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel* mapOne;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel* mapTwo;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel* mapThree;

@property (strong, atomic) SplatTimer* timer;

@end
