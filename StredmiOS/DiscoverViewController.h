//
//  DiscoverViewController.h
//  StredmiOS
//
//  Created by john on 3/18/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiscoverTableCell.h"
#import "SearchResultViewController.h"

@interface DiscoverViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *discoverSegCont;

@end
