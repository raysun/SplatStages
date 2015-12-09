//
//  StageViewController.m
//  SplatStages
//
//  Created by mac on 2015-12-08.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <SplatStagesFramework/SplatUtilities.h>

#import "StageViewController.h"
#import "TabViewController.h"

@implementation StageViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Set background - a generic background is used in attempt to comply with App Store guidelines
    UIImage* image = [UIImage imageNamed:@"GENERIC_BACKGROUND"];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:image]];
    
    // Update status bar
    [self setNeedsStatusBarAppearanceUpdate];
    
}

- (void) setupViewWithData:(NSDictionary*) data {
    TabViewController* rootController = (TabViewController*) [self tabBarController];
    NSArray* stages = [data objectForKey:@"maps"];
    
    // Set the Stage text and images
    NSString* stageOneEN = [[stages objectAtIndex:0] objectForKey:@"nameEN"];
    NSString* stageOneJP = [[stages objectAtIndex:0] objectForKey:@"nameJP"];
    NSString* stageTwoEN = [[stages objectAtIndex:1] objectForKey:@"nameEN"];
    NSString* stageTwoJP = [[stages objectAtIndex:1] objectForKey:@"nameJP"];
    
    [rootController setupStageView:stageOneEN nameJP:stageOneJP label:self.self.stageOneLabel imageView:self.stageOneImage];
    [rootController setupStageView:stageTwoEN nameJP:stageTwoJP label:self.stageTwoLabel imageView:self.self.stageTwoImage];
    
    // TODO: broken for turf wars, rulesEN does not exist
    NSString* gamemode = [SplatUtilities toLocalizable:[data objectForKey:@"rulesEN"]];
    NSString* gamemodeJP = [data objectForKey:@"rulesJP"];
    NSString* localizedGamemode = NSLocalizedString(gamemode, nil);
    if ([localizedGamemode isEqualToString:gamemode]) {
        // We don't have a localized string for this gamemode.
        // However, we have the Japanese (and maybe English) name(s)!
        // If the user's language is Japanese, great! If not, we'll just use the English name.
        if (![gamemode canBeConvertedToEncoding:NSISOLatin1StringEncoding]) {
            // We don't have the English name for this gamemode, so fallback to UNKNOWN_GAMEMODE.
            gamemode = NSLocalizedString(@"UNKNOWN_GAMEMODE", nil);
        }
        localizedGamemode = ([SplatUtilities isDeviceLangaugeJapanese]) ? gamemodeJP : gamemode;
        NSLog(@"No string for gamemode (en)\"%@\" (jp)\"%@\"!", gamemode, gamemodeJP);
    }
    self.gamemodeLabel.text = localizedGamemode;
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
