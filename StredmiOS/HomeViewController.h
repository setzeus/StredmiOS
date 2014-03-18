//
//  HomeViewController.h
//  StredmiOS
//
//  Created by Conner Fromknecht on 3/15/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayButton.h"
#import "HomeDrawerView.h"

@interface HomeViewController : UIViewController


@property (strong, nonatomic) IBOutlet PlayButton *playButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (strong, nonatomic) HomeDrawerView *homeDrawer;

-(void)updateCurrentTimeLabel:(float)currTime;
-(void)updateDurationLabel:(float)duration;
-(void)updateTitleLabel:(NSString*)title;
-(void)updateCurrentSong:(NSString*)songTitle;


-(IBAction)playPush:(id)sender;
-(IBAction)scrub:(PlayButton *)sender forEvent:(UIEvent *)event;


@end
