//
//  SubscriptionsViewController.m
//  SplatStages
//
//  Created by mac on 2015-10-18.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import "SubscriptionsViewController.h"

@interface SubscriptionsViewController ()

@end

@implementation SubscriptionsViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Turn the user away for now.
    UIAlertView* finishAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SETTINGS_NOTIFICATIONS_UNAVAILABLE_TITLE", nil) message:NSLocalizedString(@"SETTINGS_NOTIFICATIONS_UNAVAILABLE_TEXT", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CONFIRM", nil) otherButtonTitles:nil, nil];
    [finishAlert show];
    
    [self.navigationController popViewControllerAnimated:true];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) numberOfSectionsInTableView:(UITableView*) tableView {
    return 0;
}

- (NSInteger) tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section {
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
