//
//  TracklistTableViewController.m
//  StredmiOS
//
//  Created by Conner Fromknecht on 7/22/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import "TracklistTableViewController.h"
#import "JNAppDelegate.h"

#import <Foundation/Foundation.h>
#import <CoreMedia/CMTime.h>


@implementation TracklistTableViewController

-(id)initWithTracklist:(NSMutableArray *)tracklist andStartTimes:(NSMutableArray *)startTimes {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        self.title = @"Tracklist";
        self.tableView.backgroundColor = [UIColor darkGrayColor];
        
        self.tracklist = tracklist;
        self.startTimes = startTimes;
    }
    
    return self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tracklist.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentiifier = @"tracklistCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentiifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentiifier];
    }
    
    cell.tintColor = [UIColor colorWithWhite:0.1 alpha:0.5];
    
    cell.textLabel.numberOfLines = 1;
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    cell.textLabel.text = [self.tracklist objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    
    cell.detailTextLabel.numberOfLines = 1;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    cell.detailTextLabel.text = [self.startTimes objectAtIndex:indexPath.row];
    cell.detailTextLabel.textColor = [UIColor lightTextColor];
    
    cell.backgroundColor = [UIColor darkGrayColor];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *startTime = [self.startTimes objectAtIndex:indexPath.row];
    NSArray *splitStart = [startTime componentsSeparatedByString:@":"];
    
    NSString *minuteString = [splitStart objectAtIndex:0];
    NSString *secondsString = [splitStart objectAtIndex:1];
    NSInteger minutes = [minuteString intValue];
    NSInteger seconds = [secondsString intValue];
    NSInteger startSeconds = minutes*60 + seconds;
    
    JNAppDelegate *jnad = (JNAppDelegate *) [[UIApplication sharedApplication] delegate];
    CMTime duration = [[jnad.playerView.playerLayer.player currentItem] duration];
    NSInteger durationSeconds = CMTimeGetSeconds(duration);
    
    float percentage = startSeconds/(float)durationSeconds;
    NSLog(@"percentage: %f", percentage);
    
    jnad.playerView.playButton.percentageOfSong = percentage;
    [jnad.playerView.playButton redrawButton];
    jnad.playerView.justScrubbed = true;
    [jnad.playerView playPush:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end