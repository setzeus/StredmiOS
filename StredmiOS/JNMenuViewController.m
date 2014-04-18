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
    }
    return self;
}

-(void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    JNAppDelegate* jnad = (JNAppDelegate*) [[UIApplication sharedApplication] delegate];
    if (swipe.direction == UISwipeGestureRecognizerDirectionUp) {
        jnad.playerView.frame = CGRectMake(0, self.view.frame.size.height-64, 320, self.view.frame.size.height-64);
        [UIView animateWithDuration:0.25 animations:^(void) {
            [jnad.playerView openPlayer:CGSizeMake(320, self.view.frame.size.height-64)];
            jnad.playerView.frame = CGRectMake(0, 64, 320, self.view.frame.size.height-64);
        }];
    }
    else if (!jnad.playerView.isScrubbing) {
        [UIView animateWithDuration:0.25 animations:^(void) {
            jnad.playerView.frame = CGRectMake(0, self.view.frame.size.height-60, 320, 60);
            [jnad.playerView closePlayer];
            
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

@end
