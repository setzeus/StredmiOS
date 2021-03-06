 //
//  HomeDrawerView.m
//  StredmiOS
//
//  Created by Conner Fromknecht on 3/16/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import "PlayerView.h"
#import "JNAppDelegate.h"
#import "SearchResultViewController.h"

#import <AFNetworking/AFURLSessionManager.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>

#import <Mixpanel/Mixpanel.h>

@implementation SetListView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        
        [self addSubview:self.label];
    }
    
    return self;
}

@end

@interface PlayerView()

@property (nonatomic, strong) UIView* handle;

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
    _playlistArray = [NSMutableArray arrayWithArray:pl];
}

-(NSArray *)playlistArray {
    if (!_playlistArray) {
        _playlistArray = [[NSMutableArray alloc] init];
    }
    return _playlistArray;
}

-(void)openPlayer:(CGSize)size {
    self.isOpen = true;
    
    self.titleLabel.frame = CGRectMake(10, 20, self.frame.size.width-20, 60);
    self.currentTimeLabel.frame = CGRectMake(20, 80, self.frame.size.width-40, 20);
    
    self.eventLabel.alpha = 0.0;
    self.artistLabel.alpha = 0.0;
    self.artwork.alpha = 0.0;
    
    self.titleLabel.alpha = 1.0;
    self.currentTimeLabel.alpha = 1.0;
    self.durationLabel.alpha = 0.0;
    
    self.playerToolbar.alpha = 0.0;
    
    self.handle.alpha = 0.0;
    
    JNAppDelegate *jnad = (JNAppDelegate *)[[UIApplication sharedApplication] delegate];
    [jnad closePopupMenu];
}

-(void)closePlayer {
    self.isOpen = false;
    
    self.artwork.frame = CGRectMake(5, 5, 50, 50);
    self.eventLabel.frame = CGRectMake(65, 10, self.frame.size.width-55, 22);
    self.artistLabel.frame = CGRectMake(65, 32, self.frame.size.width-55, 18);
    
    self.eventLabel.alpha = 1.0;
    self.artistLabel.alpha = 1.0;
    self.artwork.alpha = 1.0;
    
    self.titleLabel.alpha = 0.0;
    self.currentTimeLabel.alpha = 0.0;
    self.durationLabel.alpha = 0.0;
    
    self.playerToolbar.alpha = 1.0;
    
    self.handle.alpha = 1.0;
    
    self.addedSong.alpha = 0.0;
    
}


-(NSData*)dataFromURL:(NSString *)url {
    NSError* error;
    NSString *string = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSISOLatin1StringEncoding error:&error];
    if (error != nil){
//        [[Mixpanel sharedInstance] track:@"Data Request Error" properties:@{@"Error" : error.description}];
        [NSException exceptionWithName:@"Error Requesting Data" reason:error.description userInfo:nil];
    }
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

-(NSMutableArray *)safeJSONParseArray:(NSString *)url {
    NSData* data;
    @try {
        data = [self dataFromURL:url];
    }
    @catch (NSException *exception) {
        return [NSMutableArray arrayWithObjects:exception.description, nil];
    }
    NSError *error;
    NSMutableArray* array;
    NSMutableDictionary* responseDict;
    if (data) responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (responseDict) {
        if ([[responseDict objectForKey:@"status"]  isEqual: @"success"]) {
            NSMutableDictionary *payload = [responseDict objectForKey:@"payload"];
            if (payload) {
                NSString *type = [payload objectForKey:@"type"];
                NSMutableArray *array = [payload objectForKey:type];
                if (array) return array;
            }
        }
    }
    NSLog(@"[DiscoverVC]: API Failure");
    if (error) return [NSMutableArray arrayWithObjects:error.description, nil];
    return [NSMutableArray arrayWithObjects:@{@"event" : @"No Results",
                                              @"artist" : @"",
                                              @"match_type" : @"artist"}, nil];
}

-(NSMutableDictionary *)safeJSONParseDict:(NSString *)url {
    NSData* data;
    @try {
        data = [self dataFromURL:url];
    }
    @catch (NSException *exception) {
        return [NSMutableDictionary dictionaryWithObjectsAndKeys:@"error", exception.description, nil];
    }
    NSError *error;
    if (data) {
        NSMutableDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (dict) return dict;
        else if (error) return [NSMutableDictionary dictionaryWithObjectsAndKeys: @"error", error.description, nil];
    }
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:@"error", @"Something went wrong", nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"key value observed");
    if ( object == self.playerLayer.player && [keyPath isEqualToString:@"status"] ) {
        if ( self.playerLayer.player.status == AVPlayerStatusFailed ) {
            NSLog(@"AVPlayer Failed");
        }
        else if ( self.playerLayer.player.status == AVPlayerStatusReadyToPlay ) {
            NSLog(@"AVPlayer Ready To Play");
            self.playButton.customPlayButton.isPlaying = self.isPlaying;
            
            while (CMTimeGetSeconds([[self.playerLayer.player currentItem] duration]) == 0.0);
        }
        else if ( self.playerLayer.player.status == AVPlayerItemStatusUnknown ) {
            NSLog(@"AVPlayer Unknown");
        }
        [self.playButton redrawButton];
        [self updatePlayerToolbar];
        [self updateLockscreen];
    }
}

-(void)updateProgress {
    if (!self.isScrubbing) {
        if (CMTimeGetSeconds([[self.playerLayer.player currentItem] duration]) != 0.0) {
            float currTime = CMTimeGetSeconds([[self.playerLayer.player currentItem] currentTime]);
            float duration = CMTimeGetSeconds([[self.playerLayer.player currentItem] duration]);
            self.playButton.percentageOfSong = currTime/duration;
            [self updateCurrentTimeLabel:currTime duration:duration];
        } else {
            [self updateCurrentTimeLabel:0.0 duration:0.0];
        }
        [self.playButton redrawButton];
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
    NSString *currentHalf = [NSString stringWithFormat:@"%02d:%02d", currMinutes, currSeconds];
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%@/%02d:%02d", currentHalf, durMinutes, durSeconds];
    
    NSInteger finalIndex = 0;
    NSInteger upperLimit = self.startTimes.count;
    for (NSInteger i = 1; i < upperLimit; ++i) {
        if ([currentHalf compare:[self.startTimes objectAtIndex:i]] != NSOrderedDescending) {
            finalIndex = i - 1;
            break;
        }
    }
    
    if ([currentHalf compare:[self.startTimes objectAtIndex:upperLimit-1]] == NSOrderedDescending) {
        finalIndex = upperLimit-1;
    }
    
    [self setTracklistTitle:finalIndex];
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
            NSLog(@"PLAY");
            [self play];
//            [[Mixpanel sharedInstance] track:@"Play Button"];
            
        } else {
            NSLog(@"PAUSE");
            [self pause];
//            [[Mixpanel sharedInstance] track:@"Pause Button"];
        }
    }
    else {
        NSLog(@"Scrubbed");
        self.justScrubbed = false;
        
        float duration = CMTimeGetSeconds([[self.playerLayer.player currentItem] duration]);
        int timeScale = self.playerLayer.player.currentItem.asset.duration.timescale;
        CMTime time = CMTimeMake(duration * self.playButton.percentageOfSong, timeScale);
        [self.playerLayer.player seekToTime:time completionHandler:^(BOOL complete){
            self.isScrubbing = false;
            [self play];
        }];
        
//        [[Mixpanel sharedInstance] track:@"Scrub" properties:@{@"Artist" : self.artistLabel.text,
//                                                               @"Event" : self.eventLabel.text,
//                                                               @"Current Time" : [NSNumber numberWithDouble:CMTimeGetSeconds([[self.playerLayer.player currentItem] currentTime])],
//                                                               @"Duration" : [NSNumber numberWithDouble:CMTimeGetSeconds([[self.playerLayer.player currentItem] duration])]}];
    }
}

-(void)play {
    self.isPlaying = true;
    self.playButton.customPlayButton.isPlaying = true;
    [self.playerLayer.player play];
    [self updatePlayerToolbar];
}


-(void)pause {
    self.isPlaying = false;
    self.playButton.customPlayButton.isPlaying = false;
    [self.playerLayer.player pause];
    [self updatePlayerToolbar];
}

-(void)updatePlayerToolbar {
    if (self.isPlaying) {
        UIBarButtonItem *playPauseBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(playPush:)];
        UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        playPauseBarItem.tintColor = [UIColor grayColor];
        [self.playerToolbar setItems:@[flex, playPauseBarItem]];
    } else {
        UIBarButtonItem *playPauseBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playPush:)];
        UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        playPauseBarItem.tintColor = [UIColor grayColor];
        [self.playerToolbar setItems:@[flex, playPauseBarItem]];
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
    [self.playButton redrawButton];

    self.justScrubbed = true;
}

-(void)initMethod {
    JNAppDelegate* jnad = (JNAppDelegate*) [[UIApplication sharedApplication] delegate];

    self.backgroundColor = [UIColor whiteColor];
    self.isPlaying = false;
    self.justScrubbed = false;
    
    self.background = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"ios7"] applyLightEffect]];
    self.background.contentMode = UIViewContentModeScaleAspectFill;
    self.background.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.background.clipsToBounds = YES;
    [self addSubview:self.background];
    
    self.swipeDownView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 100)];

    [self addSubview:self.swipeDownView];
    
    self.playerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 60)];
    UIBarButtonItem *playPauseBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playPush:)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    playPauseBarItem.tintColor = [UIColor grayColor];
    [self.playerToolbar setItems:@[flex, playPauseBarItem]];
    [self addSubview:self.playerToolbar];
    
    self.handle = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2-20, 6, 40, 4)];
    self.handle.alpha = 1.0;
    [self.handle setBackgroundColor:[UIColor grayColor]];
    [self.handle.layer setCornerRadius:2.0];
    [self addSubview:self.handle];
    
    self.setList = [[UIButton alloc] initWithFrame:CGRectMake(0, self.frame.size.height-60, self.frame.size.width, 60)];
    self.setList.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:0.5];
    [self.setList setTitle:@"Receiving tracklist..." forState:UIControlStateNormal];
    self.setList.titleLabel.numberOfLines = 2;
    self.setList.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.setList.titleLabel.adjustsFontSizeToFitWidth = true;
    self.setList.titleLabel.textColor = [UIColor whiteColor];
    self.setList.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.setList addTarget:jnad action:@selector(showTracklist:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.setList];
    
    NSLog(@"FRAME: %f %f %f %f", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    self.bottomToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.frame.size.height-120, self.frame.size.width, 60)];
    UIBarButtonItem *shuffle = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"shuffle_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(shuffle)];
    UIBarButtonItem *rewind = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(previous)];
    UIBarButtonItem *ffw = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(next)];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSet:)];
    UIButton* playlistButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playlistButton setBackgroundImage:[UIImage imageNamed:@"playlist.png"] forState:UIControlStateNormal];
    playlistButton.frame = CGRectMake(0, 0, 20, 20);
    [playlistButton addTarget:jnad action:@selector(showPlaylist:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *playlist = [[UIBarButtonItem alloc] initWithCustomView:playlistButton];
    [self.bottomToolbar setItems:@[flex, shuffle, flex, rewind, flex, playlist, flex, ffw, flex, add, flex]];
    [self.bottomToolbar setTintColor:[UIColor whiteColor]];
    [self.bottomToolbar setUserInteractionEnabled:YES];
    [self.bottomToolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.bottomToolbar setShadowImage:[UIImage new] forToolbarPosition:UIBarPositionAny];
    [self addSubview:self.bottomToolbar];
    
    self.currentTimeLabel = [[UILabel alloc] init];
    self.currentTimeLabel.textColor = [UIColor whiteColor];
    self.currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.currentTimeLabel.text = @"00:00/00:00";
    [self addSubview:self.currentTimeLabel];
    
    self.durationLabel = [[UILabel alloc] init];
    self.durationLabel.textColor = [UIColor whiteColor];
    self.durationLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.durationLabel];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.text = @"Avicii - Ultra Music Festival 2013";
    [self.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:24]];
    [self addSubview:self.titleLabel];
    
    self.artwork = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://s3.amazonaws.com/stredm/namecheap/d1e1dba7f8d6739862295ed7cb68d3ee68547544.jpg"]]]];
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

    CGFloat playButtonOffsetY = (self.frame.size.height-240)/2;
    self.playButton = [[PlayButton alloc] initWithFrame:CGRectMake((self.frame.size.width-240)/2, playButtonOffsetY, 240, 240)];
    [self addSubview:self.playButton];
    [self.songScrollView addSubview:self.songTitleLabel];
    self.songScrollView.contentSize = self.songTitleLabel.frame.size;
    [self.playButton addTarget:self action:@selector(playPush:) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton addTarget:self action:@selector(scrub:forEvent:) forControlEvents:UIControlEventTouchDragInside];
    [self addSubview:self.songScrollView];
    
    self.addedSong = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-69, self.frame.size.width, 20)];
    self.addedSong.textAlignment = NSTextAlignmentCenter;
    self.addedSong.text = @"Adding to My Sets";
    self.addedSong.alpha = 0.0;
    self.addedSong.textColor = [UIColor whiteColor];
    [self addSubview:self.addedSong];
}

-(void)hideAdding {
    [UIView animateWithDuration:.25 delay:2.25 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
        self.addedSong.alpha = 0.0;
    } completion:^(BOOL completion) {
        
    }];
}

-(void)addSet:(UIBarButtonItem*)sender {
    NSLog(@"Starting download of %@", [_setURL absoluteString]);
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Add to My Sets" message:@"Please be patient as adding a set may take several minutes. We also recommend the use of WiFi." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
    [alert show];
    
}
-(void)finishAddingSet {

    [UIView animateWithDuration:.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
        self.addedSong.alpha = 1.0;
    } completion:^(BOOL completion) {
        
    }];
    
    [self performSelector:@selector(hideAdding) withObject:nil afterDelay:2.0];
   
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* plistPath = [documentsPath stringByAppendingPathComponent:@"sets.plist"];
    
    
    NSDictionary* song = (NSDictionary*)[self.playlistArray objectAtIndex:self.currentRow];
    NSLog(@"addSet %@", plistPath);
    
    NSArray* setsArray = [NSArray arrayWithContentsOfFile:plistPath];
    NSArray* keepSets;
    BOOL alreadyInMySets = [setsArray containsObject:song];
    
    if (alreadyInMySets) {
        NSInteger songIndex = [setsArray indexOfObject:song];
        if (songIndex == 1) {
            keepSets = @[[setsArray objectAtIndex:0], song];
        } else if ([setsArray count] > 1) {
            keepSets = @[[setsArray objectAtIndex:1], song];
        } else {
            keepSets = @[song];
        }
    } else {
        if ([setsArray count] > 1) {
            NSLog(@"BIGGER than 1");
            keepSets = @[(NSDictionary*)[setsArray objectAtIndex:1], song];
        } else if ([setsArray count] == 1){
            NSLog(@"equal to 1");
            keepSets = @[(NSDictionary*)[setsArray objectAtIndex:0], song];
        } else {
            NSLog(@"new");
            keepSets = @[song];
        }
    }
    
    BOOL written = [keepSets writeToFile:plistPath atomically:YES];
    NSLog(@"file was written successfully?: %d", written);
    
    NSString* libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];

    for (NSInteger i = 0; i < [setsArray count]; ++i) {
        id songDescriptor = [setsArray objectAtIndex:i];
        if (![keepSets containsObject:songDescriptor]) {
            NSString *setFile = [[libraryDirectory stringByAppendingPathComponent:@"Caches/"] stringByAppendingPathComponent:[songDescriptor objectForKey:@"songURL"]];
            [[NSFileManager defaultManager] removeItemAtPath:setFile error:nil];
        }
    }

    
    NSLog(@"file exists @ %@?: %@", plistPath, [NSArray arrayWithContentsOfFile:plistPath]);
    
    
    if (![self fileIsCached:[song objectForKey:@"imageURL"]]) {
        NSLog(@"DOWNLOADING IMAGE");
        [self downloadAsync:_imageURL];
    }
    
    if (![self fileIsCached:[song objectForKey:@"songURL"]]) {
        NSLog(@"DOWNLOADING SET");
        
        [self downloadSetAsync:_setURL];
    }

//    [[Mixpanel sharedInstance] track:@"Set Added"];
}

-(void)downloadAsync:(NSURL*)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError) {
                               NSString* libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                               [data writeToFile:[[libraryPath stringByAppendingPathComponent:@"Caches/"] stringByAppendingPathComponent:[response suggestedFilename]] atomically:YES];
                               
                               if (![self fileIsCached:[[libraryPath stringByAppendingString:@"Caches/"] stringByAppendingString:[response suggestedFilename]]]) {
                                   NSLog(@"Retrying Download");
                                   [self downloadAsync:_setURL];
                                   return;
                               }
                               
                               NSLog(@"FILE DOWNLOADED: %@", url);
                           }];
}


-(void)downloadSetAsync:(NSURL*)url {
    [self downloadAsync:url];
    
//    [[Mixpanel sharedInstance] track:@"Download Completed"];
}

-(BOOL)fileIsCached:(NSString*)url {
    NSString* libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *imageFile = [[libraryDirectory stringByAppendingPathComponent:@"Caches/"] stringByAppendingPathComponent:url];
    return [[NSFileManager defaultManager] fileExistsAtPath:imageFile];
}

-(UIImage*)localImageOrPull:(NSString*)url {
    NSString* libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSURL *imagePath = [NSURL URLWithString:[NSString stringWithFormat:@"http://s3.amazonaws.com/stredm/namecheap/%@", url]];
    NSString *imageFile = [[libraryDirectory stringByAppendingPathComponent:@"Caches/"] stringByAppendingPathComponent:url];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile])
        return [UIImage imageWithData:[NSData dataWithContentsOfFile:imageFile]];
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:imagePath]];
}

-(void) buildTracklist:(id)song {
    [self.setList setTitle:@"Retrieving tracklist..." forState:UIControlStateNormal];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"fetching tracklist");
        NSMutableDictionary *trackDict = [self safeJSONParseDict:[NSString stringWithFormat:@"http://setmine.com/api/v/7/tracklist/%@", [song objectForKey:@"id"]]];
        NSMutableArray* tracklist = [trackDict objectForKey:@"tracklist"];
        NSMutableArray* startTimes = [trackDict objectForKey:@"starttimes"];
        if (tracklist.count != startTimes.count) {
            NSLog(@"not same length");
        }
        if (tracklist) {
            NSLog(@"tracklist received");
            self.tracklist = tracklist;
            self.startTimes = [NSMutableArray arrayWithArray:startTimes];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self setTracklistTitle:0];
            });
        } else {
            self.tracklist = [NSMutableArray arrayWithObjects:@"Unknown", nil];
            self.startTimes = [NSMutableArray arrayWithObjects:@"00:00", nil];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.setList setTitle:@"No tracklist available" forState:UIControlStateNormal];
            });
        }
    });
}

-(void) setTracklistTitle:(NSInteger)index {
    NSString *newText = @"";
    NSString *songTitle = [self.tracklist objectAtIndex:index];
    NSInteger tracklistLength = self.tracklist.count;
    
    if ([songTitle isEqual: @"Unknown"]) {
        newText = [NSString stringWithFormat:@"Tracklist available (%lu)", (unsigned long)tracklistLength];
    } else {
        newText = [NSString stringWithFormat:@"%@ (%lu)", songTitle, (unsigned long)self.tracklist.count];
    }
    [self.setList setTitle:newText forState:UIControlStateNormal];
}

-(void)playSong:(NSInteger)row {
    if (row < 0 || row >= [self.playlistArray count]) {
        [self random];
        return;
    }
    
    [[Mixpanel sharedInstance] track:@"Playing track"];
    
    self.currentRow = row;
    
    id song = [self.playlistArray objectAtIndex:self.currentRow];
    self.artistLabel.text = [song objectForKey:@"artist"];
    self.eventLabel.text = [song objectForKey:@"event"];
    self.titleLabel.text = [NSString stringWithFormat:@"%@ - %@", self.artistLabel.text, self.eventLabel.text];
    [self.artwork setImage:[self localImageOrPull:[song objectForKey:@"imageURL"]]];
    [self.background setImage:[[self localImageOrPull:[song objectForKey:@"imageURL"]] applyLightEffect]];
    [self buildTracklist:song];
    self.hidden = NO;
    
    JNAppDelegate *jnad = (JNAppDelegate *)[[UIApplication sharedApplication] delegate];
    [jnad closePopupMenu];
    
    [self updateLockscreen];
    
    NSURL *imagePath = [NSURL URLWithString:[NSString stringWithFormat:@"http://s3.amazonaws.com/stredm/namecheap/%@", [song objectForKey:@"imageURL"]]];
    NSString* libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *imageFile = [[libraryDirectory stringByAppendingPathComponent:@"Caches/"] stringByAppendingPathComponent:[song objectForKey:@"imageURL"]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
        imagePath = [NSURL fileURLWithPath:imageFile];
    }
    
    _imageURL = imagePath;
    
    NSString *setFile = [[libraryDirectory stringByAppendingPathComponent:@"Caches/"] stringByAppendingPathComponent:[song objectForKey:@"songURL"]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:setFile];
    if(fileExists) {
        _setURL = [NSURL fileURLWithPath:setFile];
//        [[Mixpanel sharedInstance] track:@"Playing Local Set"];
    }
    else {
        _setURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://s3.amazonaws.com/stredm/namecheap/%@", [song objectForKey:@"songURL"]]];
    }

    NSLog(@"_setURL: %@", _setURL);

    if (self.timer)
        [self.timer invalidate];

    if (!self.playerLayer) {
        AVPlayer *player = [[AVPlayer alloc] init];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
        [self.layer addSublayer:self.playerLayer];
        [self.playerLayer.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    AVAsset* asset = [AVAsset assetWithURL:_setURL];
    AVPlayerItem* avpi = [AVPlayerItem playerItemWithAsset:asset];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:avpi];
    [self.playerLayer.player replaceCurrentItemWithPlayerItem:avpi];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    NSLog(@"playing");
    [self play];

}

-(void)itemDidFinishPlaying:(id)sender {
    [self next];
    
//    [[Mixpanel sharedInstance] track:@"Finished Playing"];
}

-(void)random {
    self.playlistArray = [self safeJSONParseArray:@"http://stredm.com/scripts/mobile/random.php"];
    [self playSong: 0];
}

-(void)shuffle {
    [self random];
//    [[Mixpanel sharedInstance] track:@"Shuffle"];
}

-(void)next {
    [self playSong:self.currentRow + 1];
}

-(void)lockNext {
    [self next];
    
//    [[Mixpanel sharedInstance] track:@"Lock Screen Next"];
}

-(void)previous {
    if (self.currentRow > [self.playlistArray count])
        [self playSong:[self.playlistArray count] - 1];
    else if (self.currentRow > 0)
        [self playSong:self.currentRow - 1];
}

-(void)lockPrevious {
    [self previous];
    
//    [[Mixpanel sharedInstance] track:@"Lock Screen Previous"];
}


-(void)updateLockscreen {
    
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    if (playingInfoCenter) {
        NSDictionary* songInfo;
        if (CMTimeGetSeconds([[self.playerLayer.player currentItem] duration])) {
             songInfo = @{MPMediaItemPropertyTitle: self.artistLabel.text,
                                       MPMediaItemPropertyArtist:self.eventLabel.text,
                                       MPMediaItemPropertyPlaybackDuration:[NSNumber numberWithDouble:(double)CMTimeGetSeconds([[self.playerLayer.player currentItem] duration])],
                                       MPNowPlayingInfoPropertyElapsedPlaybackTime:[NSNumber numberWithDouble:(double)CMTimeGetSeconds([[self.playerLayer.player currentItem] currentTime])],
                                       MPNowPlayingInfoPropertyPlaybackRate:@1.0
                                       };
        } else {
            songInfo = @{MPMediaItemPropertyTitle: self.artistLabel.text,
                         MPMediaItemPropertyArtist:self.eventLabel.text,
                         };
        }
      
        NSMutableDictionary *maybeWithImage = [NSMutableDictionary dictionaryWithDictionary:songInfo];
        if (self.artwork.image) {
            [maybeWithImage setValue:[[MPMediaItemArtwork alloc] initWithImage:self.artwork.image] forKey:MPMediaItemPropertyArtwork];
        }
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:[NSDictionary dictionaryWithDictionary:maybeWithImage]];
    }
}


-(void)dealloc {
    [self.playerLayer.player removeObserver:self forKeyPath:@"status"];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self finishAddingSet];
    }
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
