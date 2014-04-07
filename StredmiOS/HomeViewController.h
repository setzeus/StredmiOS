//
//  HomeViewController.h
//  StredmiOS
//
//  Created by Conner Fromknecht on 3/15/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayButton.h"
#import "PlayerView.h"
#import "HomeView.h"

@interface HomeViewController : UIViewController <UIGestureRecognizerDelegate, UIToolbarDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *stredmLabel;
@property (strong, nonatomic) IBOutlet UILabel *pronunciationLabel;

@property (strong, nonatomic) PlayerView *playerView;
@property (strong, nonatomic) IBOutlet HomeView *homeView;

@end
