//
//  JNAppDelegate.h
//  StredmiOS
//
//  Created by Jesus Najera on 2/25/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "PlayerView.h"
#import <AFNetworking/AFHTTPRequestOperation.h>

@interface JNAppDelegate : UIResponder <UIApplicationDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PlayerView *playerView;
@property (strong, nonatomic) UIViewController* currentVC;

-(void)bringPlayerToFront;
-(BOOL)isPlaying;
-(void)showPlaylist:(id)sender;
-(void)showTracklist:(id)sender;
-(void)closePopupMenu;

@end
