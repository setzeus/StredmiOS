//
//  SearchResultViewController.h
//  StredmiOS
//
//  Created by Conner Fromknecht on 3/16/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchResultCell.h"

@interface SearchResultViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *searchArray;

-(id)initWithSearch:(NSArray*)query andTitle:(NSString *)title;

@end
