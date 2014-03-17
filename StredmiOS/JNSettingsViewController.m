//
//  JNSettingsViewController.m
//  StredmiOS
//
//  Created by Christian Guerin on 3/16/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import "JNSettingsViewController.h"

@interface JNSettingsViewController ()

@end

@implementation JNSettingsViewController

- (instancetype)init
{
    //Call the superclass's designated initializer
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
