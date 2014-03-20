//
//  SearchResultViewController.m
//  StredmiOS
//
//  Created by Conner Fromknecht on 3/16/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import "SearchResultViewController.h"
#import "JNAppDelegate.h"


@interface SearchResultViewController ()


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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchArray count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    JNAppDelegate *jnad = (JNAppDelegate*)[[UIApplication sharedApplication] delegate];
    jnad.playerView.playlistArray = self.searchArray;
    [jnad.playerView playSong:indexPath.row];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"SearchResultCell";
    SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        
    NSString *matchType = [[self.searchArray objectAtIndex:indexPath.row] objectForKey:@"match_type"];
    if ( [matchType isEqual: @"artist"]) {
        cell.textLabel.text = [[self.searchArray objectAtIndex:indexPath.row] objectForKey:@"event"];
        cell.detailTextLabel.text = @"";
    } else if ( [matchType isEqual:@"event"] || [matchType isEqual:@"radiomix"] ) {
        cell.textLabel.text = [[self.searchArray objectAtIndex:indexPath.row] objectForKey:@"artist"];
        cell.detailTextLabel.text = @"";
    }
    else {
        cell.textLabel.text = [[self.searchArray objectAtIndex:indexPath.row] objectForKey:@"artist"];
        cell.detailTextLabel.text = [[self.searchArray objectAtIndex:indexPath.row] objectForKey:@"event"];
    }
    return cell;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
