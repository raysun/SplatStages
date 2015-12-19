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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) numberOfSectionsInTableView:(UITableView*) tableView {
    return 2;
}

- (NSInteger) tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section {
    if (section == 0) {
        // do something
        return 0;
    } else {
        return 1;
    }
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
