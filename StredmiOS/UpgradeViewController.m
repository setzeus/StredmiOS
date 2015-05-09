//
//  UpgradeViewController.m
//  StredmiOS
//
//  Created by Conner Fromknecht on 5/9/15.
//  Copyright (c) 2015 Stredm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UpgradeViewController.h"

@implementation UpgradeViewController

-(IBAction)pushUpgradeButton:(UIButton *)upgradeButton {
    NSString *setmineItunesLink = @"itms://itunes.apple.com/us/app/setmine/id921325688";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:setmineItunesLink]];
}

@end