//
//  PlayerView
//  StredmiOS
//
//  Created by Conner Fromknecht on 3/16/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import "PlayButton.h"

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "UIImage+ImageEffects.h"

@interface PlayerView : UIView <UIScrollViewDelegate, UIToolbarDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIScrollView *songScrollView;
@property (strong, nonatomic) UILabel *currentTimeLabel;
@property (strong, nonatomic) UILabel *durationLabel;
@property (strong, nonatomic) UILabel *songTitleLabel;
@property (strong, nonatomic) PlayButton *playButton;

@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (nonatomic) float percentageOfSong;
@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) NSString *title;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) BOOL isScrubbing;
@property (nonatomic) BOOL justScrubbed;

@property (strong, nonatomic) UIImageView *artwork;
@property (strong, nonatomic) UIImageView *background;
@property (strong, nonatomic) UILabel *artistLabel;
@property (strong, nonatomic) UILabel *eventLabel;
@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UIImageView *smallPlayButton;

@property (strong, nonatomic) UIToolbar *playerToolbar;
@property (strong, nonatomic) UIToolbar *bottomToolbar;

@property (strong, nonatomic) UIView *swipeDownView;

@property (strong, nonatomic) NSArray *playlistArray;


-(void)openPlayer:(CGSize)size;
-(void)closePlayer;

-(void)loadSongWithQuery:(NSString*)query row:(NSInteger)row;
-(void)playSong:(NSInteger)row;

@end
