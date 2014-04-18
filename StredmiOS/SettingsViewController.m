//
//  SettingsViewController.m
//  StredmiOS
//
//  Created by Conner Fromknecht on 4/18/14.
//  Copyright (c) 2014 Stredm. All rights reserved.
//

#import "SettingsViewController.h"
#import <MediaPlayer/MPVolumeView.h>

#import <MixPanel/Mixpanel.h>

@interface SettingsViewController ()

@end

@implementation SettingsViewController

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
    
    [[Mixpanel sharedInstance] track:@"Settings Page"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)pushNot1:(id)sender {
    [[Mixpanel sharedInstance] track:@"PushNot Download"];
}

-(void)pushNot2:(id)sender {
    [[Mixpanel sharedInstance] track:@"PushNot Vibrate"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return section + 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Volume";
            
        case 1:
            return @"Push Notifications";
            
        case 2:
            return @"About";
            
        default:
            return @"";
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
    switch (indexPath.section) {
        case 0:
            if ([cell.contentView viewWithTag:5739]) {
                [[cell.contentView viewWithTag:5739] removeFromSuperview];
            } else if ([cell.contentView viewWithTag:5740]) {
                [[cell.contentView viewWithTag:5740] removeFromSuperview];
            }
            
            if (![cell.contentView viewWithTag:2348]) {
                MPVolumeView *slider = [[MPVolumeView alloc] initWithFrame:CGRectMake(15, 13, cell.frame.size.width-30, cell.frame.size.height-26)];
                slider.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
                slider.tag = 2348;
                [cell.contentView addSubview:slider];
            }
            
            cell.textLabel.text = @"";
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            break;
            
        case 1:
            if ([cell.contentView viewWithTag:2348]) {
                [[cell.contentView viewWithTag:2348] removeFromSuperview];
            }
            
            
            if (indexPath.row == 0) {
                if ([cell.contentView viewWithTag:5740]) {
                    [[cell.contentView viewWithTag:5740] removeFromSuperview];
                }
                
                if (![cell.contentView viewWithTag:5739]) {
                    [self addSwitchToCell:cell withTag:5739 andAction:@selector(pushNot1:)];

                }
                
                cell.textLabel.text = @"Download Complete";
            } else if (indexPath.row == 1){
                if ([cell.contentView viewWithTag:5739]) {
                    [[cell.contentView viewWithTag:5739] removeFromSuperview];
                }
                if (![cell.contentView viewWithTag:5740]) {
                    [self addSwitchToCell:cell withTag:5740 andAction:@selector(pushNot2:)];
                }
                
                cell.textLabel.text = @"Vibrate";
            } else {
                cell.textLabel.text = @"";
            }
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

            break;
            
        case 2:
            if ([cell.contentView viewWithTag:2348]) {
                [[cell.contentView viewWithTag:2348] removeFromSuperview];
            } else if ([cell.contentView viewWithTag:5739]) {
                [[cell.contentView viewWithTag:5739] removeFromSuperview];
            } else if ([cell.contentView viewWithTag:5740]) {
                [[cell.contentView viewWithTag:5740] removeFromSuperview];
            }
            
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Contact Us";
                [[Mixpanel sharedInstance] track:@"Contact Us Page"];
            } else if (indexPath.row == 1) {
                cell.textLabel.text = @"Legal";
                [[Mixpanel sharedInstance] track:@"Legal Page"];
            } else if (indexPath.row == 2) {
                cell.textLabel.text = @"Share";
                [[Mixpanel sharedInstance] track:@"Share View"];
            } else {
                cell.textLabel.text = @"";
            }
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
            break;
            
        default:
            break;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Contact Us"] animated:YES];
        } else if (indexPath.row == 1) {
            [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Legal"] animated:YES];
        } else if (indexPath.row == 2) {
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObjects:@"Check out stredm.com", nil] applicationActivities:nil];
            activityVC.excludedActivityTypes = @[UIActivityTypeAirDrop, UIActivityTypeAddToReadingList, UIActivityTypePrint, UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll];
            [self presentViewController:activityVC animated:YES completion:^(void){
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }];
        }
    }
}

-(void)addSwitchToCell:(UITableViewCell*)cell withTag:(NSInteger)tag andAction:(SEL)action {
    UISwitch* onOff = [[UISwitch alloc] init];
    onOff.onTintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    onOff.frame = CGRectMake(cell.frame.size.width-onOff.frame.size.width-15, 6.5, onOff.frame.size.width, onOff.frame.size.height);
    onOff.tag = tag;
    [onOff addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    [cell addSubview:onOff];
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
