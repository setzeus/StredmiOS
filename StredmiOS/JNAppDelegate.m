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
#import "SearchResultViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import <Mixpanel/Mixpanel.h>

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
    UITapGestureRecognizer *openTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeTap:)];
    [openSwipe setDirection:UISwipeGestureRecognizerDirectionUp];
    [closeSwipe setDirection:UISwipeGestureRecognizerDirectionDown];
    openSwipe.cancelsTouchesInView = NO;
    closeSwipe.cancelsTouchesInView = NO;
    openTap.cancelsTouchesInView = NO;
    closeTap.cancelsTouchesInView = NO;
    [self.playerView.playerToolbar addGestureRecognizer:openSwipe];
    [self.playerView.swipeDownView addGestureRecognizer:closeSwipe];
    [self.playerView.playerToolbar addGestureRecognizer:openTap];
    [self.playerView.swipeDownView addGestureRecognizer:closeTap];
    
    [self.window addSubview:self.playerView];
    
    self.playerView.hidden = YES;

    [Mixpanel sharedInstanceWithToken:@"379197a835a053a920eba4043c6e2c5b"];
    
    return YES;
}

-(void)bringPlayerToFront {
    [self.window bringSubviewToFront:self.playerView];
}

-(void)handleTap:(UITapGestureRecognizer*)tap {
    CGPoint tapCoords = [tap locationInView:self.playerView];
    NSLog(@"coords: %f %f", tapCoords.x, tapCoords.y);
    if (!self.playerView.isOpen && !CGRectContainsPoint(CGRectMake(260, 0, 60, 60), tapCoords)) {
        self.playerView.frame = CGRectMake(0, self.window.frame.size.height-60, 320, self.window.frame.size.height);
        [UIView animateWithDuration:0.25 animations:^(void) {
            [self.playerView openPlayer:CGSizeMake(320, self.window.frame.size.height)];
            self.playerView.frame = CGRectMake(0, 0, 320, self.window.frame.size.height);
        }];
    }    
}

-(void)closeTap:(UITapGestureRecognizer*)tap {
    [UIView animateWithDuration:0.25 animations:^(void) {
        self.playerView.frame = CGRectMake(0, self.window.frame.size.height-60, 320, 60);
        [self.playerView closePlayer];
    }];
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
