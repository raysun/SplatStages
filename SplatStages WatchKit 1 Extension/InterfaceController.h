//
//  InterfaceController.h
//  SplatStages WatchKit 1 Extension
//
//  Created by mac on 2015-11-21.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SplatStagesFramework/SplatTimer.h>

#import <WatchKit/WatchKit.h>

@interface InterfaceController : WKInterfaceController

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *rotationLabel;
@property (strong, atomic) SplatTimer* rotationTimer;

@end
