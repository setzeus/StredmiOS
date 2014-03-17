//
//  HomeViewController.m
//  StredmiOS
//
//  Created by Conner Fromknecht on 3/15/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@property (nonatomic) BOOL isPlaying;

@end

@implementation HomeViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.homeDrawer = [[HomeDrawerView alloc] initWithFrame:CGRectMake(0, 600, 320, 600)];
        self.homeDrawer.backgroundColor = [UIColor colorWithRed:(247/255.0) green:(247/255.0) blue:(247/255.0) alpha:1.0];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.isPlaying = [defaults boolForKey:@"isPlaying"];
        [self.playButton setNeedsDisplay];

    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([keyPath isEqualToString:@"current"]) {
        [self updateCurrentTimeLabel:[defaults floatForKey:@"current"]];
    } else if ([keyPath isEqualToString:@"duration"]) {
        [self updateDurationLabel:[defaults floatForKey:@"duration"]];
    } else if ([keyPath isEqualToString:@"title"]) {
        [self updateTitleLabel:[[defaults stringForKey:@"title"] copy]];
    } else if ([keyPath isEqualToString:@"song"]) {
        [self updateCurrentSong:[[defaults stringForKey:@"song"] copy]];
    } else if ([keyPath isEqualToString:@"percent"]) {
        self.playButton.percentageOfSong = [defaults floatForKey:@"percent"];
        [self.playButton setNeedsDisplay];
    } else if ([keyPath isEqualToString:@"isPlaying"]) {
        self.playButton.isPlaying = [defaults boolForKey:@"isPlaying"];
        [self.playButton setNeedsDisplay];
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


-(IBAction)playPush:(id)sender {
    self.isPlaying = !self.isPlaying;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.isPlaying forKey:@"isPlaying"];
    [defaults synchronize];
    self.playButton.isPlaying = self.isPlaying;
    [self.playButton setNeedsDisplay];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.homeDrawer.frame =CGRectMake(0, self.view.frame.size.height-60, 320, self.view.frame.size.height);
    [self.view addSubview:self.homeDrawer];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self updateTitleLabel:[[defaults objectForKey:@"title"] copy]];
    [self updateCurrentSong:[[defaults objectForKey:@"song"] copy]];
    [self updateDurationLabel:[defaults floatForKey:@"duration"]];
    [self updateCurrentTimeLabel:[defaults floatForKey:@"current"]];
    self.playButton.isPlaying = [defaults boolForKey:@"isPlaying"];
    self.playButton.percentageOfSong = [defaults floatForKey:@"percent"];
    
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"current" options:NSKeyValueObservingOptionNew context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"song" options:NSKeyValueObservingOptionNew context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"percent" options:NSKeyValueObservingOptionNew context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"isPlaying" options:NSKeyValueObservingOptionInitial context:nil];

}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"current"];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"duration"];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"title"];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"song"];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"percent"];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"isPlaying"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateCurrentTimeLabel:(float)currTime {
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", ((int)currTime)/60, (int)currTime%60];
    self.homeDrawer.currentTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)currTime/60, (int)currTime%60];
}

-(void)updateDurationLabel:(float)duration {
    self.homeDrawer.durationLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)duration/60, (int)duration%60];
}
-(void)updateTitleLabel:(NSString*)title {
    self.titleLabel.text = title;
}
-(void)updateCurrentSong:(NSString*)songTitle {
    self.homeDrawer.songTitleLabel.text = songTitle;
}

@end
