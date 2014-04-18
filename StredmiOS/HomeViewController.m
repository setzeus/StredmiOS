//
//  HomeViewController.m
//  StredmiOS
//
//  Created by Conner Fromknecht on 3/15/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import "HomeViewController.h"
#import "JNAppDelegate.h"

#import <math.h>

@interface HomeViewController ()

@property (nonatomic) BOOL isPlaying;

@end

@implementation HomeViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        
    }
    
    
    return self;
}

-(void)search:(id)sender {
    NSLog(@"performing segue ...");
    [self performSegueWithIdentifier:@"SearchSegue" sender:sender];
}

-(void)random:(id)sender {
    JNAppDelegate *jnad = (JNAppDelegate*)[[UIApplication sharedApplication] delegate];
    [jnad.playerView playRandom];
}

-(void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    if (swipe.direction == UISwipeGestureRecognizerDirectionUp) {
        self.playerView.frame = CGRectMake(0, self.view.frame.size.height-64, 320, self.view.frame.size.height-64);
        [UIView animateWithDuration:0.25 animations:^(void) {
            [self.playerView openPlayer:CGSizeMake(320, self.view.frame.size.height-64)];
            self.playerView.frame = CGRectMake(0, 64, 320, self.view.frame.size.height-64);
        }];
    }
    else if (!self.playerView.isScrubbing) {
        [UIView animateWithDuration:0.25 animations:^(void) {
            self.playerView.frame = CGRectMake(0, self.view.frame.size.height-60, 320, 60);
            [self.playerView closePlayer];
            
        } completion:^(BOOL completion) {
        
        }];
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    JNAppDelegate *jnad = (JNAppDelegate*) [[UIApplication sharedApplication] delegate];
    [jnad bringPlayerToFront];
    
    [self.homeView.searchButton addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    [self.homeView.randomButton addTarget:self action:@selector(random:) forControlEvents:UIControlEventTouchUpInside];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
