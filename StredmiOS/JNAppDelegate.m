//
//  JNAppDelegate.m
//  StredmiOS
//
//  Created by Jesus Najera on 2/25/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import "JNAppDelegate.h"
#import "JNMenuViewController.h"
#import "JNSettingsViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface JNAppDelegate()

@end

@implementation JNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSError *setCategoryErr = nil;
    NSError *activationErr  = nil;
    [[AVAudioSession sharedInstance] setDelegate:self];
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:&setCategoryErr];
    [[AVAudioSession sharedInstance] setActive:YES error:&activationErr];
    
    self.playerView = [[PlayerView alloc] initWithFrame:CGRectMake(0, self.window.frame.size.height-60, 320, self.window.frame.size.height)];
    [self.playerView closePlayer];
    UISwipeGestureRecognizer *openSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *closeSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [openSwipe setDirection:UISwipeGestureRecognizerDirectionUp];
    [closeSwipe setDirection:UISwipeGestureRecognizerDirectionDown];
    openSwipe.cancelsTouchesInView = NO;
    closeSwipe.cancelsTouchesInView = NO;
    [self.playerView.playerToolbar addGestureRecognizer:openSwipe];
    [self.playerView.swipeDownView addGestureRecognizer:closeSwipe];
    
    
    [self.window addSubview:self.playerView];
    
    self.playerView.hidden = YES;
    
    return YES;
}

-(void)bringPlayerToFront {
    [self.window bringSubviewToFront:self.playerView];
}

-(void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    if (swipe.direction == UISwipeGestureRecognizerDirectionUp) {
        self.playerView.frame = CGRectMake(0, self.window.frame.size.height-60, 320, self.window.frame.size.height);
        [UIView animateWithDuration:0.25 animations:^(void) {
            [self.playerView openPlayer:CGSizeMake(320, self.window.frame.size.height)];
            self.playerView.frame = CGRectMake(0, 0, 320, self.window.frame.size.height);
        }];
    }
    else if (!self.playerView.isScrubbing) {
        [UIView animateWithDuration:0.25 animations:^(void) {
            self.playerView.frame = CGRectMake(0, self.window.frame.size.height-60, 320, 60);
            [self.playerView closePlayer];
            
        } completion:^(BOOL completion) {
            
        }];
    }
}

-(BOOL)isPlaying {
    return self.playerView.isPlaying;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
