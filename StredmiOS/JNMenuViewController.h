//
//  JNMenuViewController.h
//  StredmiOS
//
//  Created by Jesus Najera on 3/9/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "HomeViewController.h"
#import "PlayerView.h"

@interface JNMenuViewController : UITableViewController <AVAudioPlayerDelegate>

@property (nonatomic) float percentageOfSong;

-(IBAction)unwindToMenuViewController:(UIStoryboardSegue *)segue;

@end
