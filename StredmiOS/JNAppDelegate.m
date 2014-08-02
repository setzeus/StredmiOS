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
#import "TracklistTableViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import <Mixpanel/Mixpanel.h>

@interface JNAppDelegate()
@property (nonatomic) BOOL registered;
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
    UITapGestureRecognizer *openTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openTap:)];
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
    
    self.playerView.hidden = YES;
    
    [self.window addSubview:self.playerView];
    

    [self setupMixpanel];
    
    
    [[Mixpanel sharedInstance] track:@"Application Opened"];
    
    [self updateVersionInfo];
    
    // register push notifications
    if (!self.registered) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert];
    }
    
    return YES;
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Successfully registered for push notifications");
    
    const void* devTokenBytes = [deviceToken bytes];
    self.registered = YES;
    [self sendDeviceToken:devTokenBytes];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Could not register for push notifications. %@", error.description);
}

-(void)sendDeviceToken:(const void*)tokenBytes {
    
}

- (void) updateVersionInfo
{
    // Get the Settings.bundle object
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // Get bunch of values from the .plist file and take note that the values that
    // we pull are generated in a Build Phase script that is definied in the Target.
    NSString *appVersionNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *buildNumber = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBuildNumber"];
    // Dealing with the date
    NSString *dateFromSettings = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBuildDate"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE MMM d HH:mm:ss zzz yyyy"];
    NSDate *date = [dateFormatter dateFromString:dateFromSettings];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSString *buildDate = [dateFormatter stringFromDate:date];
    // Create the version number
    NSString *versionNumberInSettings = [NSString stringWithFormat:@"%@.%@", appVersionNumber, buildNumber];
    NSLog(@"Version: %@", versionNumberInSettings);
    NSLog(@"Build date: %@", buildDate);
    // Set the build date and version number in the settings bundle reflected in app settings.
    [defaults setObject:versionNumberInSettings forKey:@"version"];
    [defaults setObject:buildDate forKey:@"buildDate"];
}

- (void)setupMixpanel {
    // Initialize Mixpanel
    Mixpanel *mixpanel = [Mixpanel sharedInstanceWithToken:@"379197a835a053a920eba4043c6e2c5b"];

    
    // Identify
    NSString *mixpanelUUID = [[NSUserDefaults standardUserDefaults] objectForKey:@"MixpanelUUID"];
    
    if (!mixpanelUUID) {
        mixpanelUUID = [[NSUUID UUID] UUIDString];
        [[NSUserDefaults standardUserDefaults] setObject:mixpanelUUID forKey:@"MixpanelUUID"];
    }
    
    [mixpanel identify:mixpanelUUID];
}

-(void)bringPlayerToFront {
    [self.window bringSubviewToFront:self.playerView];
}

-(void)openTap:(UITapGestureRecognizer*)tap {
    CGPoint tapCoords = [tap locationInView:self.playerView];
    if (!self.playerView.isOpen && !CGRectContainsPoint(CGRectMake(260, 0, 60, 60), tapCoords)) {
        self.playerView.frame = CGRectMake(0, self.window.frame.size.height-60, 320, self.window.frame.size.height);
        [UIView animateWithDuration:0.25 animations:^(void) {
            [self.playerView openPlayer:CGSizeMake(320, self.window.frame.size.height)];
            self.playerView.frame = CGRectMake(0, 0, 320, self.window.frame.size.height);
        }];
        
        [[Mixpanel sharedInstance] track:@"Open Player Tap"];
    }
}

-(void)closeTap:(UITapGestureRecognizer*)tap {
    if (self.playerView.isOpen) {
        [UIView animateWithDuration:0.25 animations:^(void) {
            self.playerView.frame = CGRectMake(0, self.window.frame.size.height-60, 320, 60);
            [self.playerView closePlayer];
        }];
        
        [[Mixpanel sharedInstance] track:@"Close Player Tap"];
    }
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
        }];
    }
}

-(BOOL)isPlaying {
    return self.playerView.isPlaying;
}

+ (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

-(void)showPlaylist:(id)sender {
    SearchResultViewController* srvc = [[SearchResultViewController alloc] initWithSearch:self.playerView.playlistArray andTitle:@"Playlist"];
    UINavigationController* navi = [[UINavigationController alloc] initWithRootViewController:srvc];
    srvc.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, srvc.view.frame.size.width, 60)];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closePopupMenu)];
    srvc.navigationItem.rightBarButtonItem = doneButton;
    [UIView animateWithDuration:0.25 animations:^(void) {
        self.playerView.frame = CGRectMake(0, self.window.frame.size.height-60, self.window.frame.size.width, 60);
        [self.playerView closePlayer];
    }];
    
    self.currentVC = navi;
    
    [[JNAppDelegate topMostController] presentViewController:navi animated:YES completion:nil];
}

-(void)showTracklist:(id)sender {
    TracklistTableViewController* srvc = [[TracklistTableViewController alloc] initWithTracklist:self.playerView.tracklist andStartTimes:self.playerView.startTimes];
    UINavigationController* navi = [[UINavigationController alloc] initWithRootViewController:srvc];
    srvc.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, srvc.view.frame.size.width, 60)];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closePopupMenu)];
    srvc.navigationItem.rightBarButtonItem = doneButton;
    [UIView animateWithDuration:0.25 animations:^(void) {
        self.playerView.frame = CGRectMake(0, self.window.frame.size.height-60, self.window.frame.size.width, 60);
        [self.playerView closePlayer];
    }];
    
    self.currentVC = navi;
    
    [[JNAppDelegate topMostController] presentViewController:navi animated:YES completion:nil];
}


-(void)closePopupMenu {
    if (self.currentVC) {
        [self.currentVC dismissViewControllerAnimated:YES completion:nil];
        self.currentVC = nil;
        
        self.playerView.frame = CGRectMake(0, self.window.frame.size.height-60, self.window.frame.size.width, self.window.frame.size.height);
        [UIView animateWithDuration:0.25 animations:^(void) {
            [self.playerView openPlayer:CGSizeMake(self.window.frame.size.width, self.window.frame.size.height)];
            self.playerView.frame = CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height);
        }];
        
    }
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
