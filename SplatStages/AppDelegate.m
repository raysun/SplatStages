//
//  AppDelegate.m
//  SplatStages
//
//  Created by mac on 2015-08-25.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import "AppDelegate.h"
#import "SplatfestViewController.h"
#import "TabViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL) application:(UIApplication*) application didFinishLaunchingWithOptions:(NSDictionary*) launchOptions {
    /*
    self.oneSignal = [[OneSignal alloc] initWithLaunchOptions:launchOptions
                                                        appId:@"e029fb88-69a9-4291-8b71-25e6d3bd881e"
                                           handleNotification:nil];
     */
    
    self.oneSignal = [[OneSignal alloc]
                      initWithLaunchOptions:launchOptions
                      appId:@"e029fb88-69a9-4291-8b71-25e6d3bd881e"
                      handleNotification:^(NSString* message, NSDictionary* additionalData, BOOL isActive) {
                          NSLog(@"OneSignal Notification opened:\nMessage: %@", message);
                          
                          if (additionalData) {
                              NSLog(@"additionalData: %@", additionalData);
                              
                              // Check for and read any custom values you added to the notification
                              // This done with the "Additonal Data" section the dashbaord.
                              // OR setting the 'data' field on our REST API.
                              NSString* customKey = additionalData[@"customKey"];
                              if (customKey)
                                  NSLog(@"customKey: %@", customKey);
                          }
                      }];
    return YES;
}

- (void) applicationWillResignActive:(UIApplication*) application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    // Invalidate all timers.
    TabViewController* viewController = (TabViewController*) self.window.rootViewController;
    SplatfestViewController* splatfestVC = [[viewController viewControllers] objectAtIndex:2];
    
    if (viewController.rotationTimer != nil) {
        [viewController.rotationTimer stop];
    }
    
    if (splatfestVC.countdownTimer != nil) {
        [splatfestVC.countdownTimer stop];
    }
}

- (void) applicationDidEnterBackground:(UIApplication*) application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void) applicationWillEnterForeground:(UIApplication*) application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void) applicationDidBecomeActive:(UIApplication*) application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Restart timers.
    TabViewController* viewController = (TabViewController*) self.window.rootViewController;
    if (viewController.rotationTimer) {
        [viewController.rotationTimer start];
    } else {
        [viewController refreshAllData];
    }
    
    SplatfestViewController* splatfestViewController = [viewController.viewControllers objectAtIndex:SPLATFEST_CONTROLLER];
    if (splatfestViewController.countdownTimer) {
        [splatfestViewController.countdownTimer start];
    }
}

- (void) applicationWillTerminate:(UIApplication*) application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
