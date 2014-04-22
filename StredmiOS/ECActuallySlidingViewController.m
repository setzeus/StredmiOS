//
//  ECActuallySlidingViewController.m
//  StredmiOS
//
//  Created by Conner Fromknecht on 4/18/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import "ECActuallySlidingViewController.h"

@interface ECActuallySlidingViewController ()

@end

@implementation ECActuallySlidingViewController

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
    
    [self.view addGestureRecognizer:self.panGesture];
    self.navigationItem.leftBarButtonItem.customView.frame = CGRectMake(0, 0, 20, 20);
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
