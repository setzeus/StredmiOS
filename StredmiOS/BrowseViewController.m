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
@property (strong, nonatomic) NSMutableArray *searchArray;

@property (strong, nonatomic) NSMutableArray *artistArray;
@property (strong, nonatomic) NSMutableArray *eventArray;
@property (strong, nonatomic) NSMutableArray *radioArray;
@property (strong, nonatomic) NSMutableArray *genreArray;

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

-(NSData*)dataFromURL:(NSString *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    NSError* error;
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (error != nil) {
//        [[Mixpanel sharedInstance] track:@"Data Request Error" properties:@{@"Error" : error.description}];
        [NSException exceptionWithName:@"Error Requesting Data" reason:error.description userInfo:nil];
    }
    return data;
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
    NSMutableDictionary* responseDict;
    if (data) responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (responseDict) {
        if ([[responseDict objectForKey:@"status"]  isEqual: @"success"]) {
            NSMutableDictionary *payload = [responseDict objectForKey:@"payload"];
            if (payload) {
                NSString *type = [payload objectForKey:@"type"];
                NSMutableArray *array = [payload objectForKey:type];
                if (array) return array;
            }
        }
    }
    NSLog(@"[DiscoverVC]: API Failure");
    if (error) return [NSMutableArray arrayWithObjects:error.description, nil];
    return [NSMutableArray arrayWithObjects:@{@"event" : @"No Results",
                                              @"artist" : @"",
                                              @"match_type" : @"artist"}, nil];
}

- (void)changeBrowseMode {
    self.currentMode = (NSInteger)self.browseSegCont.selectedSegmentIndex;
    [self.tableView reloadData];
    NSLog(@"scrollsToTop: %d", [self.tableView scrollsToTop]);
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
    switch (self.currentMode) {
        case 0:
//            [[Mixpanel sharedInstance] track:@"Artist Tab"];
            break;
            
        case 1:
//            [[Mixpanel sharedInstance] track:@"Event Tab"];
            break;
            
        case 2:
//            [[Mixpanel sharedInstance] track:@"Radio  Tab"];
            break;
            
        case 3:
//            [[Mixpanel sharedInstance] track:@"Genre Tab"];
            break;
            
        default:
            break;
    }
}

-(NSArray *)searchArray {
    NSString *searchURL = [NSString stringWithFormat:@"http://setmine.com/api/v/7/search?search=%@", self.searchString];
    _searchArray = [self safeJSONParseArray:searchURL];
    return _searchArray;
}

-(NSArray *)artistArray {
    if ( _artistArray != nil ) return _artistArray;
    NSString *artistURL = @"http://setmine.com/api/v/7/artist";
    _artistArray = [self safeJSONParseArray:artistURL];
    return _artistArray;
}

-(NSArray *)eventArray {
    if ( _eventArray != nil ) return _eventArray;
    NSString *eventURL = @"http://setmine.com/api/v/7/festival";
    _eventArray = [self safeJSONParseArray:eventURL];
    return _eventArray;
}

-(NSArray *)radioArray {
    if ( _radioArray != nil ) return _radioArray;
    NSString *radioURL = @"http://setmine.com/api/v/7/mix";
    _radioArray = [self safeJSONParseArray:radioURL];
    return _radioArray;
}

-(NSArray *)genreArray {
    if ( _genreArray != nil ) return _genreArray;
    NSString *genreURL = @"http://setmine.com/api/v/7/genre";
    _genreArray = [self safeJSONParseArray:genreURL];
    return _genreArray;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentMode = (NSInteger)self.browseSegCont.selectedSegmentIndex;
    [self.browseSegCont addTarget:self action:@selector( changeBrowseMode ) forControlEvents:UIControlEventValueChanged];
    
//    [[Mixpanel sharedInstance] track:@"Browse Page"];
    
    
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
            cell.idNum = (NSInteger)[[self.eventArray objectAtIndex:indexPath.row] objectForKey:@"id"];
            break;
        case 2:
            cell.textLabel.text = [[self.radioArray objectAtIndex:indexPath.row] objectForKey:@"radiomix"];
            cell.idNum = (NSInteger)[[self.radioArray objectAtIndex:indexPath.row] objectForKey:@"id"];
            break;
        case 3:
            cell.textLabel.text = [[self.genreArray objectAtIndex:indexPath.row] objectForKey:@"genre"];
            cell.idNum = (NSInteger)[[self.genreArray objectAtIndex:indexPath.row] objectForKey:@"id"];
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

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", ];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    NSArray* indexArray;
    NSString* key;
    switch (self.currentMode) {
        case 0:
            indexArray = self.artistArray;
            key = @"artist";
            break;
        case 1:
            indexArray = self.eventArray;
            key = @"event";
            break;
        case 2:
            indexArray = self.radioArray;
            key = @"radiomix";
            break;
        case 3:
            indexArray = self.genreArray;
            key = @"genre";
            break;
        default:
            break;
    }
    NSInteger newRow = [self indexForFirstChar:title inArray:indexArray withKey:key];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:newRow inSection:0];
    [tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    return index;
}

- (NSInteger)indexForFirstChar:(NSString *)character inArray:(NSArray *)array withKey:(NSString *)key {
    for (int i = 0; i < [array count]; ++i) {
        NSString* str = [[array objectAtIndex:i] objectForKey:key];
        str = [str substringWithRange:[str rangeOfComposedCharacterSequenceAtIndex:0]];
        int comp = [str compare:character options:NSCaseInsensitiveSearch];
        if ((comp >= NSOrderedSame) || i >= [array count]-1) {
            return i;
        }
    }
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
