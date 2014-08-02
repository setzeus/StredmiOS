//
//  MySetsViewController.m
//  StredmiOS
//
//  Created by john on 4/18/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import "MySetsViewController.h"
#import "JNAppDelegate.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <Mixpanel/Mixpanel.h>

#import "SearchResultCell.h"

@interface MySetsViewController ()

@property (strong, nonatomic) NSMutableArray *downloadsArray;

@end

@implementation MySetsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[Mixpanel sharedInstance] track:@"My Sets Page"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:self.tableView.separatorInset];
    }
}

-(void)reloadCallback {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

-(NSArray*)downloadsArray{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [paths objectAtIndex:0];
    NSString *appFile = [documentPath stringByAppendingPathComponent:@"sets.plist"];
    
    NSLog(@"exisits?: %@", appFile);
    if([[NSFileManager defaultManager] fileExistsAtPath:appFile]) {
        NSLog(@"App File Exists");
        _downloadsArray = [NSArray arrayWithContentsOfFile:appFile];
    }

    return _downloadsArray;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.downloadsArray count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    JNAppDelegate *jnad = (JNAppDelegate*)[[UIApplication sharedApplication] delegate];
    jnad.playerView.playlistArray = self.downloadsArray;
    
    [jnad.playerView playSong:indexPath.row];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(UIImage*)localImageOrPull:(NSString*)url {
    NSString* libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSURL *imagePath = [NSURL URLWithString:[NSString stringWithFormat:@"http://stredm.com/uploads/%@", url]];
    NSString *imageFile = [[libraryDirectory stringByAppendingPathComponent:@"Caches/"] stringByAppendingPathComponent:url];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageFile])
        return [UIImage imageWithData:[NSData dataWithContentsOfFile:imageFile]];
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:imagePath]];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SearchResultCell";
    SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ( cell == nil ) {
        cell = [[SearchResultCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    id songObject = [self.downloadsArray objectAtIndex:indexPath.row];
    
    [cell.imageView setImage:[self localImageOrPull:[songObject objectForKey:@"imageURL"]]];

    
    NSString *matchType = [songObject objectForKey:@"match_type"];
    if ( [matchType isEqual: @"artist"] )
        cell.textLabel.text = [songObject objectForKey:@"event"];
    else if (matchType)
        cell.textLabel.text = [songObject objectForKey:matchType];
    else
        cell.textLabel.text = [songObject objectForKey:@"event"];
    cell.detailTextLabel.text = [songObject objectForKey:@"artist"];
    
    if (![self fileIsCached:[songObject objectForKey:@"songURL"]]) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Adding - %@", cell.detailTextLabel.text];
        cell.detailTextLabel.font = [UIFont italicSystemFontOfSize:12.0f];
    }
    else {
        cell.detailTextLabel.font = [UIFont italicSystemFontOfSize:12.0f];
    }
    
    return cell;
}

-(BOOL)fileIsCached:(NSString*)url {
    NSString* libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *imageFile = [[libraryDirectory stringByAppendingPathComponent:@"Caches/"] stringByAppendingPathComponent:url];
    return [[NSFileManager defaultManager] fileExistsAtPath:imageFile];
}

-(void)dealloc {
    JNAppDelegate* jnad = (JNAppDelegate*) [[UIApplication sharedApplication] delegate];
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
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
