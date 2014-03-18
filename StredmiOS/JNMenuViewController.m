//
//  JNMenuViewController.m
//  StredmiOS
//
//  Created by Jesus Najera on 3/9/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import "JNMenuViewController.h"

@interface JNMenuViewController ()

@end

@implementation JNMenuViewController

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.percentageOfSong = 0.0;
        [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"search" options:NSKeyValueObservingOptionNew context:nil];
        [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"isPlaying" options:NSKeyValueObservingOptionNew context:nil];
        [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"scrubbing" options:NSKeyValueObservingOptionNew context:nil];
        [self.playerLayer.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}
-(IBAction)unwindToMenuViewController:(UIStoryboardSegue *)segue; { }

-(void)playSongWithQuery:(NSString *)query row:(NSInteger)row {
    NSString *songPath = [NSString stringWithFormat:@"http://stredm.com/scripts/mobile/search.php?label=%@", query];
    NSArray *songArray = [self safeJSONParseArray:songPath];
    
    NSString *artist = [[songArray objectAtIndex:row] objectForKey:@"artist"];
    NSString *event = [[songArray objectAtIndex:row] objectForKey:@"event"];
    NSString *title = [NSString stringWithFormat:@"%@ - %@", artist, event];
    NSString *song = [NSString stringWithFormat:@"%@ - %@", artist, event];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:title forKey:@"title"];
    [defaults setObject:song forKey:@"song"];
    [defaults setBool:true forKey:@"isPlaying"];
    [defaults setObject:@"no" forKey:@"scrubbing"];
    [defaults synchronize];
    
    NSString *setPath = [NSString stringWithFormat:@"http://stredm.com/uploads/%@", [[songArray objectAtIndex:row] objectForKey:@"songURL"]];
    NSURL *setURL = [NSURL URLWithString:setPath];
    
    @try {
        if (self.playerLayer) {
            [self.playerLayer.player removeObserver:self forKeyPath:@"status"];
            [self.playerLayer.player pause];
            self.playerLayer = nil;
            [self.playerLayer removeFromSuperlayer];
        }
    }
    @catch (NSException *exception) {
        
    }
    if (self.timer)
        [self.timer invalidate];
    
    
    if (!self.playerLayer) {
        AVPlayer *player = [[AVPlayer alloc] init];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
        [self.view.layer addSublayer:self.playerLayer];
    }
    [self.playerLayer.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:setURL]];
    [self.playerLayer.player addObserver:self forKeyPath:@"status" options:0 context:nil];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    [self.playerLayer.player play];
    
}


-(void)updateProgress {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![[defaults stringForKey:@"scrubbing"] isEqualToString:@"yes"]) {
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
    else if ([keyPath isEqualToString:@"search"] ) {
        NSString *query = [defaults stringForKey:@"search"];
        NSInteger row = [defaults integerForKey:@"row"];
        [self playSongWithQuery:query row:row];
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
    else if ([keyPath isEqualToString:@"scrubbing"]) {
        if ([[defaults stringForKey:@"scrubbing"] isEqualToString:@"yes"]) {
            float percent = [defaults floatForKey:@"percent"];
            NSLog(@"percent: %f", percent);
            float duration = [defaults floatForKey:@"duration"];
            int timeScale = self.playerLayer.player.currentItem.asset.duration.timescale;
            CMTime time = CMTimeMakeWithSeconds(duration * percent, timeScale);
            NSLog(@"seeking");
            [self.playerLayer.player seekToTime:time completionHandler:^(BOOL complete){
                NSLog(@"playing");
                [self.playerLayer.player play];
                [defaults setBool:true forKey:@"isPlaying"];
                [defaults synchronize];
                NSLog(@"play called");
            }];
            [defaults setObject:@"no" forKey:@"scrubbing"];
            [defaults synchronize];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
