//
//  HomeViewController.m
//  StredmiOS
//
//  Created by Conner Fromknecht on 3/15/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import "HomeViewController.h"

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

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([keyPath isEqualToString:@"current"]) {
//        [self updateCurrentTimeLabel:[defaults floatForKey:@"current"]];
    } else if ([keyPath isEqualToString:@"duration"]) {
//        [self updateDurationLabel:[defaults floatForKey:@"duration"]];
    } else if ([keyPath isEqualToString:@"title"]) {
//        [self updateTitleLabel:[[defaults stringForKey:@"title"] copy]];
    } else if ([keyPath isEqualToString:@"song"]) {
//        [self updateCurrentSong:[[defaults stringForKey:@"song"] copy]];
    } else if ([keyPath isEqualToString:@"percent"]) {
//        self.playButton.percentageOfSong = [defaults floatForKey:@"percent"];
//        [self.playButton setNeedsDisplay];
    } else if ([keyPath isEqualToString:@"isPlaying"]) {
//        self.playButton.isPlaying = [defaults boolForKey:@"isPlaying"];
//        [self.playButton setNeedsDisplay];
    } else if ([keyPath isEqualToString:@"invisible"]) {
//        self.playButton.invisible = [defaults boolForKey:@"invisible"];
    }   else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return !(touch.view == self.playerView);
}


//-(IBAction)playPush:(id)sender {
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if (![defaults boolForKey:@"isScrubbing"]) {
//        self.isPlaying = !self.isPlaying;
//        [defaults setBool:self.isPlaying forKey:@"isPlaying"];
//        [defaults synchronize];
//        self.playButton.isPlaying = self.isPlaying;
//        [self.playButton setNeedsDisplay];
//    } else {
//        [defaults setBool:false forKey:@"isScrubbing"];
//        [defaults synchronize];
//    }
//}

//-(IBAction)scrub:(PlayButton *)sender forEvent:(UIEvent *)event {
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setBool:true forKey:@"isScrubbing"];
//    [defaults synchronize];
//    
//    NSSet *touches = [event touchesForView:sender];
//    UITouch *touch = [touches anyObject];
//    CGPoint point = [touch locationInView:sender];
//    float x = point.x - 120.0;
//    float y = point.y - 120.0;
//    float per = -atan(x/y);
//    if (y > 0) per += 3.1415926535;
//    if (per < 0) per += 2*3.1415926535;
//    per /= 2*3.141592653;
//
//    self.playButton.percentageOfSong = per;
//
//    [defaults setFloat:per forKey:@"percent"];
//    [defaults synchronize];
//
//}

- (IBAction)random:(id)sender {
}

- (IBAction)search:(id)sender {
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
    
    self.playerView = [[PlayerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-60, 320, self.view.frame.size.height-64)];
    [self.playerView closePlayer];
    UISwipeGestureRecognizer *openSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *closeSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [openSwipe setDirection:UISwipeGestureRecognizerDirectionUp];
    [closeSwipe setDirection:UISwipeGestureRecognizerDirectionDown];
    openSwipe.cancelsTouchesInView = NO;
    closeSwipe.cancelsTouchesInView = NO;
    [self.playerView.playerToolbar addGestureRecognizer:openSwipe];
    [self.playerView.swipeDownView addGestureRecognizer:closeSwipe];
    [self.view addSubview:self.playerView];
    
    
    self.playerView.frame =CGRectMake(0, self.view.frame.size.height-64, 320, self.view.frame.size.height);
    [self.view addSubview:self.playerView];

    [self.playerView loadSongWithQuery:@"3LAU" row:0];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"current" options:NSKeyValueObservingOptionNew context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"song" options:NSKeyValueObservingOptionNew context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"percent" options:NSKeyValueObservingOptionNew context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"isPlaying" options:NSKeyValueObservingOptionNew context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"invisible" options:NSKeyValueObservingOptionNew context:nil];

}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"current"];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"duration"];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"title"];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"song"];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"percent"];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"isPlaying"];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"invisible"];
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
