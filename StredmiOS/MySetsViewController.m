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

@interface MySetsViewController ()

@property (strong, nonatomic) NSArray *downloadsArray;

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

-(NSArray *)downloadsArray {

    if(_downloadsArray != nil) return _downloadsArray;

    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];

    NSString *documentsDirectory = documentsDirectoryURL.path;
    NSLog(@"%@",documentsDirectory);
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"sets.plist"];
    NSLog(@"%@",appFile);

    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:appFile];
    NSLog(@"file exists: %hhd",fileExists);
    if(fileExists) {
        NSDictionary *myDict = [[NSDictionary alloc] initWithContentsOfFile:appFile];
        NSLog(@"Data : %@ ",myDict);
        _downloadsArray = [NSArray arrayWithObject:myDict];
        NSLog(@"Data : %@ ",_downloadsArray);
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
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MySetsTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ( cell == nil ) {
        cell = [[MySetsTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    id songObject = [self.downloadsArray objectAtIndex:indexPath.row];

    NSString* url = [NSString stringWithFormat:@"%@%@", @"http://stredm.com/uploads/", [songObject objectForKey:@"imageURL"]];
    cell.textLabel.text = [songObject objectForKey:@"event"];
    cell.detailTextLabel.text = [songObject objectForKey:@"artist"];
    [cell.imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];

    return cell;
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
