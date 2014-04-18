//
//  SearchResultViewController.m
//  StredmiOS
//
//  Created by Conner Fromknecht on 3/16/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import "SearchResultViewController.h"
#import "JNAppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import <Mixpanel/Mixpanel.h>

@interface SearchResultViewController ()

@property (strong, nonatomic) NSOperationQueue* searchQueue;

@end

@implementation SearchResultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithSearch:(NSArray *)query andTitle:(NSString * )title{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.searchArray = [NSArray arrayWithArray:query];
        self.title = title;
    }
    
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:self.tableView.separatorInset];
    }
    self.searchQueue = [[NSOperationQueue alloc] init];
    [self.searchQueue setMaxConcurrentOperationCount:1];
    
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return ![[self searchDisplayController] searchResultsTableView].dragging;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self setSavedSearchTerm:[[[self searchDisplayController] searchBar] text]];
    [self setSearchResults:nil];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    
    if ([searchString isEqualToString:@""] == YES) {
        [self.searchResults removeAllObjects];
        return YES;
    } else {
        [self.searchQueue cancelAllOperations];
        [self.searchQueue addOperationWithBlock:^{
            NSArray *results = [self safeJSONParseArray:[NSString stringWithFormat:@"http://stredm.com/scripts/mobile/search.php?label=%@", searchString]];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                // Modify your instance variables here on the main
                // UI thread.
//                [self.searchResults removeAllObjects];
                self.searchResults = [NSMutableArray arrayWithArray:results];
                
                // Reload your search results table data.
                [controller.searchResultsTableView reloadData];
            }];
        }];
        
        return NO;
    }
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self setSavedSearchTerm:nil];
    
    [[self mainTableView] reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows;
    
    if (tableView == [[self searchDisplayController] searchResultsTableView])
        rows = [[self searchResults] count];
    else
        rows = [[self searchArray] count];
    
    return rows;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    JNAppDelegate *jnad = (JNAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (tableView == [[self searchDisplayController] searchResultsTableView]) {
        jnad.playerView.playlistArray = self.searchResults;
    } else {
        jnad.playerView.playlistArray = self.searchArray;
    }
    [jnad.playerView playSong:indexPath.row];
    
    
    [[Mixpanel sharedInstance] track:@"Specific Set Play"];
    
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SearchResultCell";
    SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if ( cell == nil ) {
        cell = [[SearchResultCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    id songObject;
    if (tableView == [[self searchDisplayController] searchResultsTableView]) {
        songObject = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        songObject = [self.searchArray objectAtIndex:indexPath.row];
    }

    NSString *matchType = [songObject objectForKey:@"match_type"];
    if ( [matchType isEqual: @"artist"] )
        cell.textLabel.text = [songObject objectForKey:@"event"];
    else
        cell.textLabel.text = [songObject objectForKey:matchType];
    cell.detailTextLabel.text = [songObject objectForKey:@"artist"];
    
    NSString* url = [NSString stringWithFormat:@"http://stredm.com/uploads/%@", [songObject objectForKey:@"imageURL"]];
    [cell.imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
    
    return cell;
}

-(void)close:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self savedSearchTerm]) {
        [[[self searchDisplayController] searchBar] setText:[self savedSearchTerm]];
    }
    
    if ([[self searchDisplayController] searchBar]) {
        
    }
 
    
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSData *)dataFromURL:(NSString *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if ( error != nil ) [NSException raise:@"Error retrieving data" format:@"Could not reach %@", url];
    return data;
}

-(NSArray *)safeJSONParseArray:(NSString *)url {
    NSArray *array = nil;
    NSData *data = nil;
    @try {
        data = [self dataFromURL:url];
    }
    @catch (NSException *exception) {
        data = nil;
    }
    @finally {
        NSError *error;
        array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if ( error != nil ) array = [NSArray arrayWithObjects:@"An error occured", nil];
        return array;
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
