//
//  SearchResultViewController.h
//  StredmiOS
//
//  Created by Conner Fromknecht on 3/16/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchResultCell.h"

@interface SearchResultViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate, NSURLSessionTaskDelegate>

@property (strong, nonatomic) NSArray *searchArray;

@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) NSMutableArray *contentsList;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (nonatomic, copy) NSString* savedSearchTerm;

-(id)initWithSearch:(NSArray*)query andTitle:(NSString *)title;
-(IBAction)close:(id)sender;

@end
