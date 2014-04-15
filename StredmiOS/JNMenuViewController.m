//
//  JNMenuViewController.m
//  StredmiOS
//
//  Created by Jesus Najera on 3/9/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import "JNMenuViewController.h"
#import "JNAppDelegate.h"

@interface JNMenuViewController ()

@property (strong, nonatomic) NSArray *playlistArray;

@end

@implementation JNMenuViewController

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.percentageOfSong = 0.0;
        [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"isPlaying" options:NSKeyValueObservingOptionNew context:nil];
        [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"isScrubbing" options:NSKeyValueObservingOptionNew context:nil];
        
        JNAppDelegate* jnad = (JNAppDelegate*) [[UIApplication sharedApplication] delegate];
        [jnad.playerView.playerLayer.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}
-(IBAction)unwindToMenuViewController:(UIStoryboardSegue *)segue; { }


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

-(void)viewDidLoad {
    [super viewDidLoad];
    
    // lock screen
    [[AVAudioSession sharedInstance] setDelegate: self];
    
    NSError* myErr;
    if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&myErr]) {
        NSLog(@"Audio Session error %@, %@", myErr, [myErr userInfo]);
    } else{
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    }
    
    JNAppDelegate* jnad = (JNAppDelegate*) [[UIApplication sharedApplication] delegate];
    [jnad.playerView.playerLayer.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];

}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    
    NSLog(@"remote event received");
    
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlPause:
                //pause code here
                break;
                
            case UIEventSubtypeRemoteControlPlay:
                //play code here
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                // previous track code here
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                //next track code here
                break;
                
            default:
                break;
        }
    }
}



-(void)updateProgress {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![[defaults stringForKey:@"isScrubbing"] isEqualToString:@"yes"]) {
        if (CMTimeGetSeconds([[self.playerLayer.player currentItem] duration]) != 0.0) {
            [defaults setFloat:CMTimeGetSeconds([[self.playerLayer.player currentItem] currentTime])/CMTimeGetSeconds([[self.playerLayer.player currentItem] duration]) forKey:@"percent"];
            [defaults setFloat:CMTimeGetSeconds([[self.playerLayer.player currentItem] currentTime]) forKey:@"current"];
            [defaults setFloat:CMTimeGetSeconds([[self.playerLayer.player currentItem] duration]) forKey:@"duration"];
        } else {
            [defaults setFloat:0.0 forKey:@"percent"];
            [defaults setFloat:0.0 forKey:@"current"];
            [defaults setFloat:0.0 forKey:@"duration"];
        }
        [defaults synchronize];

    }
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
    NSLog(@"key value observed %@", keyPath);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ( object == self.playerLayer.player && [keyPath isEqualToString:@"status"] ) {
        if ( self.playerLayer.player.status == AVPlayerStatusFailed ) {
            NSLog(@"AVPlayer Failed");
        }
        else if ( self.playerLayer.player.status == AVPlayerStatusReadyToPlay ) {
            NSLog(@"Ready to play");
            [self.playerLayer.player play];
        }
        else if ( self.playerLayer.player.status == AVPlayerItemStatusUnknown ) {
            NSLog(@"AVPlayer Unknown");
        }
    }
    else if ([keyPath isEqualToString:@"isPlaying"]) {
        BOOL playing = [defaults boolForKey:@"isPlaying"];
        if (playing) {
            [self.playerLayer.player play];
        }
        else {
            [self.playerLayer.player pause];
        }
    }
    else if ([keyPath isEqualToString:@"isScrubbing"]) {
        if ([defaults boolForKey:@"isScrubbing"]) {
            float percent = [defaults floatForKey:@"percent"];
            NSLog(@"percent: %f", percent);
            float duration = [defaults floatForKey:@"duration"];
            int timeScale = self.playerLayer.player.currentItem.asset.duration.timescale;
            CMTime time = CMTimeMakeWithSeconds(duration * percent, timeScale);
            [self.playerLayer.player seekToTime:time completionHandler:^(BOOL complete){
                [defaults setBool:true forKey:@"isPlaying"];
                [defaults setBool:false forKey:@"isScrubbing"];
                [defaults synchronize];
                [self.playerLayer.player play];
            }];
            
        }
    } else if ([keyPath isEqual:@"rate"]) {
        NSLog(@"rate change");
        [self.playerView updateLockscreen];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
