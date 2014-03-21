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
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.isPlaying = [defaults boolForKey:@"isPlaying"];
//        [self.playButton setNeedsDisplay];
    }
    
    
    return self;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
-(void)updateCurrentTimeLabel:(float)currTime {
    int minutes = (int)currTime/60;
    int seconds = (int)currTime%60;
    if (minutes < 0.0) minutes = 0.0;
    if (seconds < 0) seconds = 0.0;
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    self.playerView.currentTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

-(void)updateDurationLabel:(float)duration {
    int minutes = (int)duration/60;
    int seconds = (int)duration%60;
    if (minutes < 0) minutes = 0.0;
    if (seconds < 0) seconds = 0.0;
    self.playerView.durationLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}
-(void)updateTitleLabel:(NSString*)title {
    self.titleLabel.text = title;
}
-(void)updateCurrentSong:(NSString*)songTitle {
    self.playerView.songTitleLabel.text = songTitle;
    [self.playerView.songTitleLabel sizeToFit];
    self.playerView.songTitleLabel.frame = CGRectMake(0, 0, self.playerView.songTitleLabel.frame.size.width, self.playerView.songScrollView.frame.size.height);
    self.playerView.songScrollView.contentSize = self.playerView.songTitleLabel.frame.size;
    if (self.playerView.songTitleLabel.frame.size.width > self.playerView.songScrollView.frame.size.width) {
        [self slideText];
    }
}

-(void)slideText {
    [UIView animateWithDuration:4.0 animations:^(void) {
        self.playerView.songScrollView.contentOffset = CGPointMake(self.playerView.songTitleLabel.frame.size.width - self.playerView.songScrollView.frame.size.width, 0);
    } completion:^(BOOL complete) {
        [UIView animateWithDuration:4.0 animations:^(void) {
            self.playerView.songScrollView.contentOffset = CGPointMake(0.0, 0.0);
        } completion:^(BOOL complete){
            [self performSelector:@selector(slideText) withObject:nil afterDelay:0.0];
        }];
    }];
}
 */

@end
