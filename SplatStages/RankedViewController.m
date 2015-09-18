//
//  RankedViewController.m
//  SplatStages
//
//  Created by mac on 2015-08-30.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import "RankedViewController.h"
#import "TabViewController.h"

@interface RankedViewController ()

@end

@implementation RankedViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Set background
    UIImage* image = [UIImage imageNamed:@"BACKGROUND"];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:image]];
}

- (void) setupViewWithData:(NSDictionary*) data {
    TabViewController* rootController = (TabViewController*) [self tabBarController];
    NSArray* stages = [data objectForKey:@"maps"];
    
    // Set the Stage text and images
    NSString* stageOneEN = [[stages objectAtIndex:0] objectForKey:@"nameEN"];
    NSString* stageOneJP = [[stages objectAtIndex:0] objectForKey:@"nameJP"];
    NSString* stageTwoEN = [[stages objectAtIndex:1] objectForKey:@"nameEN"];
    NSString* stageTwoJP = [[stages objectAtIndex:1] objectForKey:@"nameJP"];
    
    [rootController setupStageView:stageOneEN nameJP:stageOneJP label:self.stageLabelOne imageView:self.stageImageOne];
    [rootController setupStageView:stageTwoEN nameJP:stageTwoJP label:self.stageLabelTwo imageView:self.stageImageTwo];
    
    // Ranked Battles have all the other gamemodes.
    NSString* gamemode = [rootController toLocalizable:[data objectForKey:@"rulesEN"]];
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
        localizedGamemode = ([rootController isUserLangaugeJapanese]) ? gamemodeJP : gamemode;
        NSLog(@"No string for gamemode (en)\"%@\" (jp)\"%@\"!", gamemode, gamemodeJP);
    }
    self.gamemodeLabel.text = localizedGamemode;
}

@end