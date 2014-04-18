//
//  HomeDrawerView.m
//  StredmiOS
//
//  Created by Conner Fromknecht on 3/16/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import "PlayerView.h"
#import <AFNetworking/AFURLSessionManager.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>

#import <Mixpanel/Mixpanel.h>

@interface PlayerView()

@end

@implementation PlayerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initMethod];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initMethod];
    }
    return self;
}

-(void)playlistArray:(NSArray *)pl {
    _playlistArray = [NSArray arrayWithArray:pl];
}

-(NSArray *)playlistArray {
    if (!_playlistArray) {
        _playlistArray = [[NSArray alloc] init];
    }
    return _playlistArray;
}

-(void)openPlayer:(CGSize)size {
    self.isOpen = true;
    
    self.titleLabel.frame = CGRectMake(10, 20, 300, 60);
    self.currentTimeLabel.frame = CGRectMake(20, 80, 280, 20);
    
    self.eventLabel.alpha = 0.0;
    self.artistLabel.alpha = 0.0;
    self.artwork.alpha = 0.0;
    
    self.titleLabel.alpha = 1.0;
    self.currentTimeLabel.alpha = 1.0;
    self.durationLabel.alpha = 0.0;
    
    self.playerToolbar.alpha = 0.0;
}

-(void)closePlayer {
    self.isOpen = false;
    
    self.artwork.frame = CGRectMake(5, 5, 50, 50);
    self.eventLabel.frame = CGRectMake(65, 10, 200, 22);
    self.artistLabel.frame = CGRectMake(65, 32, 200, 18);
    
    self.artwork.frame = CGRectMake(5, 5, 50, 50);
    
    self.eventLabel.alpha = 1.0;
    self.artistLabel.alpha = 1.0;
    self.artwork.alpha = 1.0;
    
    self.titleLabel.alpha = 0.0;
    self.currentTimeLabel.alpha = 0.0;
    self.durationLabel.alpha = 0.0;
    
    self.playerToolbar.alpha = 1.0;
    
}


-(NSData *)dataFromURL:(NSString *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if ( error != nil ) [NSException raise:@"Error retrieving data" format:@"Could not reach %@", url];
    return data;
}

-(NSArray *)safeJSONParseArray:(NSString *)url {
    NSArray *array = nil;
    NSData *data = nil;
    @try {
        data = [self dataFromURL:url];
    }
    @catch (NSException *exception) {
        data = nil;
    }
    @finally {
        NSError *error;
        array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if ( error != nil ) array = [NSArray arrayWithObjects:@"An error occured", nil];
        return array;
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ( object == self.playerLayer.player && [keyPath isEqualToString:@"rate"] ) {
        if ( self.playerLayer.player.status == AVPlayerStatusFailed ) {
            NSLog(@"AVPlayer Failed");
        }
        else if ( self.playerLayer.player.status == AVPlayerStatusReadyToPlay ) {
            self.playButton.isPlaying = self.isPlaying;
            self.isScrubbing = false;
            
            while (CMTimeGetSeconds([[self.playerLayer.player currentItem] duration]) == 0.0);
        }
        else if ( self.playerLayer.player.status == AVPlayerItemStatusUnknown ) {
            NSLog(@"AVPlayer Unknown");
        }
        [self.playButton setNeedsDisplay];
        [self updatePlayerToolbar];
        [self updateLockscreen];
    }
}

-(void)updateProgress {
    if (!self.isScrubbing) {
        if (CMTimeGetSeconds([[self.playerLayer.player currentItem] duration]) != 0.0) {
            float currTime = CMTimeGetSeconds([[self.playerLayer.player currentItem] currentTime]);
            float duration = CMTimeGetSeconds([[self.playerLayer.player currentItem] duration]);
            self.percentageOfSong = currTime/duration;
            self.playButton.percentageOfSong = self.percentageOfSong;
            [self updateCurrentTimeLabel:currTime duration:duration];
        } else {
            [self updateCurrentTimeLabel:0.0 duration:0.0];
        }
        [self.playButton setNeedsDisplay];
    }
}

-(void)updateCurrentTimeLabel:(float)currTime duration:(float)duration {
    int currMinutes = (int)currTime/60;
    int currSeconds = (int)currTime%60;
    if (currMinutes < 0.0) currMinutes = 0.0;
    if (currSeconds < 0) currSeconds = 0.0;
    
    int durMinutes = (int)duration/60;
    int durSeconds = (int)duration%60;
    if (durMinutes < 0.0) durMinutes = 0.0;
    if (durSeconds < 0.0) durSeconds = 0.0;
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d/%02d:%02d", currMinutes, currSeconds, durMinutes, durSeconds];
}

-(BOOL)isScrubbing {
    if (!_isScrubbing) {
        _isScrubbing = false;
    }
    return _isScrubbing;
}

-(void)playPush:(id)sender {
    if (!self.isScrubbing && !self.justScrubbed) {
        if (!self.isPlaying) {
            [self play];
            [[Mixpanel sharedInstance] track:@"Play Button"];
            
        } else {
            [self pause];
            [[Mixpanel sharedInstance] track:@"Pause Button"];
        }
    }
    else {
        self.justScrubbed = false;
        [[Mixpanel sharedInstance] track:@"Scrub" properties:@{@"Artist" : self.artistLabel.text,
                                                               @"Event" : self.eventLabel.text,
                                                               @"Current Time" : [NSNumber numberWithDouble:CMTimeGetSeconds([[self.playerLayer.player currentItem] currentTime])],
                                                               @"Duration" : [NSNumber numberWithDouble:CMTimeGetSeconds([[self.playerLayer.player currentItem] duration])]}];
    }
}

-(void)play {
    self.isPlaying = true;
    [self.playerLayer.player play];
}


-(void)pause {
    self.isPlaying = false;
    [self.playerLayer.player pause];
}

-(void)updatePlayerToolbar {
    if (self.isPlaying) {
        UIBarButtonItem *playPauseBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(playPush:)];
        playPauseBarItem.tintColor = [UIColor grayColor];
        [self.playerToolbar setItems:@[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:@selector(playPush:)], playPauseBarItem]];
    } else {
        UIBarButtonItem *playPauseBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playPush:)];            playPauseBarItem.tintColor = [UIColor grayColor];
        [self.playerToolbar setItems:@[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:@selector(playPush:)], playPauseBarItem]];
    }
}

-(void)scrub:(PlayButton *)sender forEvent:(UIEvent *)event {
    self.isScrubbing = true;
    
    NSSet *touches = [event touchesForView:sender];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:sender];
    float x = point.x - 120.0;
    float y = point.y - 120.0;
    float per = -atan(x/y);
    if (y > 0) per += 3.1415926535;
    if (per < 0) per += 2*3.1415926535;
    per /= 2*3.141592653;
    
    self.playButton.percentageOfSong = per;
    [self.playButton setNeedsDisplay];
    
    float duration = CMTimeGetSeconds([[self.playerLayer.player currentItem] duration]);
    int timeScale = self.playerLayer.player.currentItem.asset.duration.timescale;
    CMTime time = CMTimeMakeWithSeconds(duration * per, timeScale);
    [self.playerLayer.player seekToTime:time completionHandler:^(BOOL complete){
        self.isScrubbing = false;
        [self play];
    }];
    self.justScrubbed = true;
}

-(void)initMethod {
    self.backgroundColor = [UIColor whiteColor];
    self.isPlaying = false;
    self.justScrubbed = false;
    
    self.background = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"ios7"] applyLightEffect]];
    self.background.contentMode = UIViewContentModeScaleAspectFill;
    self.background.frame = CGRectMake(0, 0, 320, self.frame.size.height);
    self.background.clipsToBounds = YES;
    [self addSubview:self.background];
    
    self.swipeDownView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.swipeDownView];
    
    self.playerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    UIBarButtonItem *playPauseBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playPush:)];
    playPauseBarItem.tintColor = [UIColor grayColor];
    [self.playerToolbar setItems:@[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:@selector(playPush:)], playPauseBarItem]];
    [self addSubview:self.playerToolbar];
    
    
    
    self.bottomToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.frame.size.height-60, 320, 60)];
    UIBarButtonItem *shuffle = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"shuffle_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(shuffle)];
    UIBarButtonItem *rewind = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(previous)];
    UIBarButtonItem *ffw = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(next)];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(addSet)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self.bottomToolbar setItems:@[shuffle, flex, rewind, flex, ffw, flex, add]];
    [self.bottomToolbar setTintColor:[UIColor whiteColor]];
    [self.bottomToolbar setUserInteractionEnabled:YES];
    [self.bottomToolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.bottomToolbar setShadowImage:[UIImage new] forToolbarPosition:UIBarPositionAny];
    [self addSubview:self.bottomToolbar];
    
    self.currentTimeLabel = [[UILabel alloc] init];
    self.currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.currentTimeLabel.text = @"00:00/00:00";
    [self addSubview:self.currentTimeLabel];
    
    self.durationLabel = [[UILabel alloc] init];
    self.durationLabel.textColor = [UIColor whiteColor];
    self.durationLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.durationLabel];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.text = @"Avicii - Ultra Music Festival 2013";
    [self.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:24]];
    [self addSubview:self.titleLabel];
    
    self.artwork = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://stredm.com/uploads/d1e1dba7f8d6739862295ed7cb68d3ee68547544.jpg"]]]];
    self.artwork.contentMode = UIViewContentModeScaleAspectFill;
    self.artwork.clipsToBounds = YES;
    [self.playerToolbar addSubview:self.artwork];

    self.artistLabel = [[UILabel alloc] init];
    self.artistLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
    self.artistLabel.textColor = [UIColor grayColor];
    self.artistLabel.text = @"Avicii";
    [self.playerToolbar addSubview:self.artistLabel];
    
    self.eventLabel = [[UILabel alloc] init];
    self.eventLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
    self.eventLabel.textColor = [UIColor darkTextColor];
    self.eventLabel.text = @"Ultra Music Festival 2013";
    [self.playerToolbar addSubview:self.eventLabel];

    self.playButton = [[PlayButton alloc] initWithFrame:CGRectMake(40, self.frame.size.height/2-110, 240, 240)];
    [self addSubview:self.playButton];
    [self.songScrollView addSubview:self.songTitleLabel];
    self.songScrollView.contentSize = self.songTitleLabel.frame.size;
    [self.playButton addTarget:self action:@selector(playPush:) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton addTarget:self action:@selector(scrub:forEvent:) forControlEvents:UIControlEventTouchDragInside];
    [self addSubview:self.songScrollView];

}

-(void)addSet {
    NSLog(@"Starting download of %@", [_setURL absoluteString]);
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLRequest *request = [NSURLRequest requestWithURL:_setURL];

    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    
    NSString *documentsDirectory = documentsDirectoryURL.path;
    NSLog(@"%@",documentsDirectory);
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"sets.plist"];
    NSLog(@"%@",appFile);
    //    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:appFile];
    //    NSArray *keys;
    //    NSArray *values;
    //    NSLog(@"file exists: %hhd",fileExists);
    //    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithCapacity:2];
    //    if(fileExists) {
    //        NSDictionary *myData = [NSDictionary dictionaryWithContentsOfFile:appFile];
    //        NSLog(@"Data : %@ ",myData);
    //        keys = [myData allKeys];
    //        values = [myData allValues];
    //        for (int i=0; i<[keys count]; i++) {
    //            [mutableDict setObject:myData forKey:[NSString stringWithFormat:@"%@",[values objectAtIndex:i]]];
    //        }
    //        NSLog(@"Data : %@ ",values);
    //    }

    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {

        NSLog(@"%@",[_playlistArray objectAtIndex:_currentRow]);
        NSMutableArray *song = [_playlistArray objectAtIndex:_currentRow];
        NSLog(@"%@",song);
        BOOL write = [song writeToFile:appFile atomically:YES];
        NSLog(@"%@",[_setURL absoluteString]);
        NSLog(@"file written: %hhd",write);

        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
    }];
    [downloadTask resume];
    
    
    [[Mixpanel sharedInstance] track:@"Set Added"];
}

-(void)playSong:(NSInteger)row {
    if (row < 0 || row >= [self.playlistArray count]) {
        [self random];
        return;
    }

    self.currentRow = row;
    
    id song = [self.playlistArray objectAtIndex:self.currentRow];
    self.artistLabel.text = [song objectForKey:@"artist"];
    self.eventLabel.text = [song objectForKey:@"event"];
    self.titleLabel.text = [NSString stringWithFormat:@"%@ - %@", self.artistLabel.text, self.eventLabel.text];
    
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://stredm.com/uploads/%@", [song objectForKey:@"imageURL"]]];
    [self.artwork setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]]];
    
    self.hidden = NO;
    
    NSString *setPath = [NSString stringWithFormat:@"http://stredm.com/uploads/%@", [song objectForKey:@"songURL"]];
    _setURL = [NSURL URLWithString:setPath];

    if (self.timer)
        [self.timer invalidate];

    if (!self.playerLayer) {
        AVPlayer *player = [[AVPlayer alloc] init];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
        [self.layer addSublayer:self.playerLayer];
        [self.playerLayer.player addObserver:self forKeyPath:@"rate" options:0 context:nil];
    }
    
    AVPlayerItem* avpi = [AVPlayerItem playerItemWithURL:_setURL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:avpi];
    [self.playerLayer.player replaceCurrentItemWithPlayerItem:avpi];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    [self play];
}

-(void)itemDidFinishPlaying:(id)sender {
    [self next];
    
    [[Mixpanel sharedInstance] track:@"Finished Playing"];
}

-(void)random {
    self.playlistArray = [self safeJSONParseArray:@"http://stredm.com/scripts/mobile/random.php"];
    [self playSong: 0];
}

-(void)shuffle {
    [self random];
    [[Mixpanel sharedInstance] track:@"Shuffle"];
}

-(void)next {
    [self playSong:self.currentRow + 1];
}

-(void)lockNext {
    [self next];
    
    [[Mixpanel sharedInstance] track:@"Lock Screen Next"];
}

-(void)previous {
    if (self.currentRow > [self.playlistArray count])
        [self playSong:[self.playlistArray count] - 1];
    else if (self.currentRow > 0)
        [self playSong:self.currentRow - 1];
}

-(void)lockPrevious {
    [self previous];
    
    [[Mixpanel sharedInstance] track:@"Lock Screen Previous"];
}


-(void)updateLockscreen {
    
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    if (playingInfoCenter) {
        NSDictionary *songInfo = @{MPMediaItemPropertyTitle: self.artistLabel.text,
                                    MPMediaItemPropertyArtist:self.eventLabel.text,
                                    MPMediaItemPropertyArtwork: [[MPMediaItemArtwork alloc] initWithImage:self.artwork.image],
                                    MPMediaItemPropertyPlaybackDuration:[NSNumber numberWithDouble:(double)CMTimeGetSeconds([[self.playerLayer.player currentItem] duration])],
                                    MPNowPlayingInfoPropertyElapsedPlaybackTime:[NSNumber numberWithDouble:(double)CMTimeGetSeconds([[self.playerLayer.player currentItem] currentTime])],
                                    MPNowPlayingInfoPropertyPlaybackRate:@1.0
                                    };
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    }
}


-(void)dealloc {
    [self.playerLayer.player removeObserver:self forKeyPath:@"rate"];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
