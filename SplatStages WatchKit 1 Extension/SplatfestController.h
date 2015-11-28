//
//  SplatfestController.h
//  SplatStages
//
//  Created by mac on 2015-11-28.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface SplatfestController : WKInterfaceController

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel* messageLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel* mapOne;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel* mapTwo;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel* mapThree;

@end
