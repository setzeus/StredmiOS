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

@implementation JNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    // Override point for customization after application launch.
    
    // Create a JNMenuViewController
    //JNMenuViewController *menuViewController = [[JNMenuViewController alloc] init];
    
    // Create a JNSettingsViewController
//    JNSettingsViewController *settingsViewController = [[JNSettingsViewController alloc] init];
    
    // Create an instance of a UINavigationController
    // its stack contains settingsViewController
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    
    // Place navigation controller's view in the window hierarchy
//    self.window.rootViewController = navController;
//    
//    self.window.backgroundColor = [UIColor whiteColor];
//    [self.window makeKeyAndVisible];
    NSError *setCategoryErr = nil;
    NSError *activationErr  = nil;
    [[AVAudioSession sharedInstance] setDelegate:self];
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:&setCategoryErr];
    [[AVAudioSession sharedInstance] setActive:YES error:&activationErr];
    
    NSUserDefaults * defaults  = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"yes" forKey:@"startup"];
    [defaults setObject:@"" forKey:@"title"];
    [defaults setObject:@"" forKey:@"song"];
    [defaults setInteger:0.0 forKey:@"row"];
    [defaults setBool:false forKey:@"isScrubbing"];
    [defaults setBool:false forKey:@"isPlaying"];
    [defaults setFloat:0.0 forKey:@"current"];
    [defaults setFloat:0.0 forKey:@"duration"];
    [defaults setFloat:0.0 forKey:@"percent"];
    [defaults setBool:true forKey:@"invisible"];
    
    [defaults synchronize];

    
    return YES;
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
