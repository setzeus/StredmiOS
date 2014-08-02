//
//  TracklistTableViewController.h
//  StredmiOS
//
//  Created by Conner Fromknecht on 7/22/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TracklistTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray* tracklist;
@property (strong, nonatomic) NSMutableArray* startTimes;

-(id)initWithTracklist:(NSMutableArray *)tracklist andStartTimes:(NSMutableArray *)startTimes;

@end