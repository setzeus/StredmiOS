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

-(id)initWithSearch:(NSMutableArray *)query andTitle:(NSString * )title{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.searchArray = [NSMutableArray arrayWithArray:query];
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
    
    
    if ([songObject respondsToSelector:@selector(objectForKey:)]) {
        NSString* url = [NSString stringWithFormat:@"http://stredm.com/uploads/%@", [songObject objectForKey:@"imageURL"]];
        [cell.imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
        
        NSLog(@"cell at row: %d", indexPath.row);
        NSString *matchType = [songObject objectForKey:@"match_type"];
        if ( [matchType isEqual: @"artist"] )
            cell.textLabel.text = [songObject objectForKey:@"event"];
        else
            cell.textLabel.text = [songObject objectForKey:matchType];
        cell.detailTextLabel.text = [songObject objectForKey:@"artist"];
    } else {
        [cell.imageView setImage:[UIImage new]];
        NSLog(@"FAILURE IN SEARCH\n%@", songObject);
    }
    
    return cell;
}

-(UIImage*)localImageOrPull:(NSString*)url {
    NSString* libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSURL *imagePath = [NSURL URLWithString:[NSString stringWithFormat:@"http://stredm.com/uploads/%@", url]];
    NSString *imageFile = [[libraryDirectory stringByAppendingPathComponent:@"Caches/"] stringByAppendingPathComponent:url];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile])
        return [UIImage imageWithData:[NSData dataWithContentsOfFile:imageFile]];
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:imagePath]];
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

-(NSData*)dataFromURL:(NSString *)url {
    NSError* error;
    NSString *string = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSISOLatin1StringEncoding error:&error];
    if (error != nil){
        [[Mixpanel sharedInstance] track:@"Data Request Error" properties:@{@"Error" : error.description}];
        [NSException exceptionWithName:@"Error Requesting Data" reason:error.description userInfo:nil];
    }
     return [string dataUsingEncoding:NSUTF8StringEncoding];
}

-(NSMutableArray *)safeJSONParseArray:(NSString *)url {
    NSData* data;
    @try {
        data = [self dataFromURL:url];
    }
    @catch (NSException *exception) {
        return [NSMutableArray arrayWithObjects:exception.description, nil];
    }
    NSError *error;
    NSMutableArray* array;
    if (data) array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (array) return array;
    else if (error) return [NSMutableArray arrayWithObjects:error.description, nil];
    return [NSMutableArray arrayWithObjects:@{@"event" : @"No Results",
                                              @"artist" : @"",
                                              @"match_type" : @"artist"}, nil];
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
