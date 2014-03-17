//
//  BrowseViewController.h
//  StredmiOS
//
//  Created by Conner Fromknecht on 3/12/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrowseTableCell.h"
#import "SearchResultViewController.h"

@interface BrowseViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *browseSegCont;

@end
