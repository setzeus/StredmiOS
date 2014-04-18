//
//  BrowseViewController.m
//  StredmiOS
//
//  Created by Conner Fromknecht on 3/12/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import "BrowseViewController.h"
#import "JNAppDelegate.h"

#import <Mixpanel/Mixpanel.h>

@interface BrowseViewController ()

@property (nonatomic) NSInteger currentMode;

@property (strong, nonatomic) NSString *searchString;
@property (strong, nonatomic) NSArray *searchArray;

@property (strong, nonatomic) NSArray *artistArray;
@property (strong, nonatomic) NSArray *eventArray;
@property (strong, nonatomic) NSArray *radioArray;
@property (strong, nonatomic) NSArray *genreArray;

@end

@implementation BrowseViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.currentMode = (NSInteger)self.browseSegCont.selectedSegmentIndex;
        [self.browseSegCont addTarget:self action:@selector( changeBrowseMode ) forControlEvents:UIControlEventValueChanged];
    }
    return self;
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

- (void)changeBrowseMode {
    self.currentMode = (NSInteger)self.browseSegCont.selectedSegmentIndex;
    [self.tableView reloadData];
    
    switch (self.currentMode) {
        case 0:
            [[Mixpanel sharedInstance] track:@"Artist Tab"];
            break;
            
        case 1:
            [[Mixpanel sharedInstance] track:@"Event Tab"];
            break;
            
        case 2:
            [[Mixpanel sharedInstance] track:@"Radio  Tab"];
            break;
            
        case 3:
            [[Mixpanel sharedInstance] track:@"Genre Tab"];
            break;
            
        default:
            break;
    }
}


-(NSArray *)searchArray {
    NSString *searchURL = [NSString stringWithFormat:@"http://stredm.com/scripts/mobile/search.php?label=%@", self.searchString];
    _searchArray = [self safeJSONParseArray:searchURL];
    return _searchArray;
}

-(NSArray *)artistArray {
    if ( _artistArray != nil ) return _artistArray;
    NSString *artistURL = @"http://stredm.com/scripts/mobile/artists.php";
    _artistArray = [self safeJSONParseArray:artistURL];
    return _artistArray;
}

-(NSArray *)eventArray {
    if ( _eventArray != nil ) return _eventArray;
    NSString *eventURL = @"http://stredm.com/scripts/mobile/events.php";
    _eventArray = [self safeJSONParseArray:eventURL];
    return _eventArray;
}

-(NSArray *)radioArray {
    if ( _radioArray != nil ) return _radioArray;
    NSString *radioURL = @"http://stredm.com/scripts/mobile/radiomixes.php";
    _radioArray = [self safeJSONParseArray:radioURL];
    return _radioArray;
}

-(NSArray *)genreArray {
    if ( _genreArray != nil ) return _genreArray;
    NSString *genreURL = @"http://stredm.com/scripts/mobile/genres.php";
    _genreArray = [self safeJSONParseArray:genreURL];
    return _genreArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentMode = (NSInteger)self.browseSegCont.selectedSegmentIndex;
    [self.browseSegCont addTarget:self action:@selector( changeBrowseMode ) forControlEvents:UIControlEventValueChanged];
    
    
//    [self.tableView registerClass: [BrowseTableCell class] forCellReuseIdentifier:@"BrowseTableCell"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
   // UIImage *segmentedBackground = [UIImage imageNamed:@"GearImage.png"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        switch (self.currentMode) {
            case 0:
                return [self.artistArray count];
            case 1:
                return [self.eventArray count];
            case 2:
                return [self.radioArray count];
            case 3:
                return [self.genreArray count];
            default:
                return 0;
        }

    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BrowseTableCell";
    BrowseTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
//    if ( cell == nil ) {
//        cell = [[BrowseTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//    }
    
    switch (self.currentMode) {
        case 0:
            cell.textLabel.text = [[self.artistArray objectAtIndex:indexPath.row] objectForKey:@"artist"];
            cell.idNum = (NSInteger)[[self.artistArray objectAtIndex:indexPath.row] objectForKey:@"id"];
            break;
        case 1:
            cell.textLabel.text = [[self.eventArray objectAtIndex:indexPath.row] objectForKey:@"event"];
            cell.idNum = (NSInteger)[[self.artistArray objectAtIndex:indexPath.row] objectForKey:@"id"];
            break;
        case 2:
            cell.textLabel.text = [[self.radioArray objectAtIndex:indexPath.row] objectForKey:@"radiomix"];
            cell.idNum = (NSInteger)[[self.artistArray objectAtIndex:indexPath.row] objectForKey:@"id"];
            break;
        case 3:
            cell.textLabel.text = [[self.genreArray objectAtIndex:indexPath.row] objectForKey:@"genre"];
            cell.idNum = (NSInteger)[[self.artistArray objectAtIndex:indexPath.row] objectForKey:@"id"];
            break;
        default:
            cell.textLabel.text = @"An error occured";
    }
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"BrowseToSearch"]) {
        SearchResultViewController *srvc = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        switch (self.currentMode) {
            case 0:
                self.searchString = [[self.artistArray objectAtIndex:indexPath.row] objectForKey:@"artist"];
                break;
            case 1:
                self.searchString = [[self.eventArray objectAtIndex:indexPath.row] objectForKey:@"event"];
                break;
            case 2:
                self.searchString = [[self.radioArray objectAtIndex:indexPath.row] objectForKey:@"radiomix"];
                break;
            case 3:
                self.searchString = [[self.genreArray objectAtIndex:indexPath.row] objectForKey:@"genre"];
                break;
                
            default:
                self.searchString = @"";
        }
        srvc.title = self.searchString;
        srvc.searchArray = self.searchArray;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
