//
//  DICHOGroupSettingsViewController.m
//  Dicho
//
//  Created by Tyler Droll on 8/3/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOGroupSettingsViewController.h"
#import "DICHOAsyncImageViewRound.h"
#import "DICHOGroupNameViewController.h"
#import "DICHOGroupUsernameViewController.h"
#import "DICHOGroupPictureViewController.h"
#import "DICHOGroupAdminViewController.h"
#import "DICHOGroupRequestsViewController.h"
#import "DICHOGroupRemoveViewController.h"

@interface DICHOGroupSettingsViewController ()

@end

@implementation DICHOGroupSettingsViewController
@synthesize notAdminAlert;
@synthesize deleteAlert;
@synthesize progressAlert;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)initWithGroupID:(NSString*)aGroupID name:(NSString*)aName username:(NSString*)aUsername image:(UIImage*)aImage{
    self = [super init];
    if( !self) return nil;
    self.title = @"Settings";
    groupID = aGroupID;
    name = aName;
    username = aUsername;
    groupImage = aImage;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    prefs= [NSUserDefaults standardUserDefaults];
    userID = [prefs objectForKey:@"userID"];
    adminUsername = [prefs objectForKey:@"username"];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];

    
    memberRequestsNumber = @"Loading...";
}
-(void) viewDidAppear:(BOOL)animated{
    NSString *loginStatus = [prefs objectForKey:@"loggedIn"];
    
    if([loginStatus isEqualToString:@"no"]){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        if(self.tabBarController.selectedIndex == 0){
            if([[prefs objectForKey:@"firstTimeToDicho"] isEqualToString:@"yes"]){
                [self.navigationController popToRootViewControllerAnimated:YES];
            }else{
                //call for groupSettingsInfo
                NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/getGroupSettingsInfo.php?groupID=%@", groupID];
                NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 15.0];
                settingsInfoConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            }
        }else if(self.tabBarController.selectedIndex == 3){
            if([[prefs objectForKey:@"firstTimeToHome"] isEqualToString:@"yes"]){
                [self.navigationController popToRootViewControllerAnimated:YES];
            }else{
                //call for groupSettingsInfo
                NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/getGroupSettingsInfo.php?groupID=%@", groupID];
                NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 15.0];
                settingsInfoConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
        return 4;
    else if(section==1)
        return 2;
    else return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0 && indexPath.row == 2){
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UILabel *contentTypeLabel;
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            contentTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 11, 100, 21)];
            contentTypeLabel.tag = 1;
            contentTypeLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:16.0];
            contentTypeLabel.textAlignment = NSTextAlignmentLeft;
            contentTypeLabel.text = @"Picture";
            [cell.contentView addSubview:contentTypeLabel];
            
        }else{            
            DICHOAsyncImageViewRound* oldImage = (DICHOAsyncImageViewRound*)[cell.contentView viewWithTag:5];
            [oldImage removeFromSuperview];
        }
        
        DICHOAsyncImageViewRound* askerImage = [[DICHOAsyncImageViewRound alloc]
                                                initWithFrame:CGRectMake(232, 2, 40, 40)];
        askerImage.tag = 5;
        //use askerID/username to pull and store userImage
        NSString *imageUrl;
        imageUrl= [NSString stringWithFormat:@"http://dichoapp.com/groupImages/%@.jpeg", groupID];
        [askerImage loadImageFromURL:[NSURL URLWithString:imageUrl]];
        [cell.contentView addSubview:askerImage];
                
        return cell;

    }else if(indexPath.section==2){
        static NSString *CellIdentifier = @"deleteCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UILabel *deleteLabel;
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            
            deleteLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 11, 200, 21)];
            deleteLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:16.0];
            deleteLabel.textAlignment = NSTextAlignmentCenter;
            deleteLabel.text = @"Delete Group";
            deleteLabel.textColor = [UIColor redColor];
            [cell.contentView addSubview:deleteLabel];
            
        }
        
        return cell;
        
    }else{
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UILabel *contentTypeLabel;
        UILabel *contentLabel;
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            contentTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 11, 139, 21)];
            contentTypeLabel.tag = 1;
            contentTypeLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:16.0];
            contentTypeLabel.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:contentTypeLabel];
            
            contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 11, 122, 21)];
            contentLabel.tag = 2;
            contentLabel.font = [UIFont fontWithName:@"ArialMT" size:16.0];
            contentLabel.textColor = [UIColor darkGrayColor];
            contentLabel.textAlignment = NSTextAlignmentRight;
            contentLabel.adjustsFontSizeToFitWidth = YES;
            [cell.contentView addSubview:contentLabel];

        }else{
            contentTypeLabel = (UILabel *)[cell.contentView viewWithTag:1];
            contentLabel = (UILabel *)[cell.contentView viewWithTag:2];
        }
        if(indexPath.section==0 && indexPath.row == 0){
            contentTypeLabel.text = @"Name";
            contentLabel.text = name;
        }else if(indexPath.section==0 && indexPath.row == 1){
            contentTypeLabel.text = @"Username";
            contentLabel.text = username;
        }else if(indexPath.section==0 && indexPath.row == 3){
            contentTypeLabel.text = @"Admin";
            contentLabel.text = adminUsername;
        }else if(indexPath.section==1 && indexPath.row == 0){
            contentTypeLabel.text = @"Member Requests";
            contentLabel.text = memberRequestsNumber;
            contentLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:16.0];
            contentLabel.textColor = [UIColor redColor];

        }else{
            contentTypeLabel.text = @"Remove Members";
            contentLabel.text = @"";
        }
                
        return cell;
    }
    
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0 && indexPath.row==0){
        DICHOGroupNameViewController *nextVC = [[DICHOGroupNameViewController alloc] initWithGroupID: groupID name:name];
        [self.navigationController pushViewController:nextVC animated:YES];
    }else if(indexPath.section==0 && indexPath.row==1){
        DICHOGroupUsernameViewController *nextVC = [[DICHOGroupUsernameViewController alloc] initWithGroupID:groupID username:username];
        [self.navigationController pushViewController:nextVC animated:YES];
    }else if(indexPath.section==0 && indexPath.row==2){
        DICHOGroupPictureViewController *nextVC = [[DICHOGroupPictureViewController alloc] initWithGroupID:groupID];
        [self.navigationController pushViewController:nextVC animated:YES];
    }else if(indexPath.section==0 && indexPath.row==3){
        DICHOGroupAdminViewController *nextVC = [[DICHOGroupAdminViewController alloc] initWithGroupID:groupID admin:adminUsername];
        [self.navigationController pushViewController:nextVC animated:YES];
    }else if(indexPath.section==1 && indexPath.row==0){
        DICHOGroupRequestsViewController *nextVC = [[DICHOGroupRequestsViewController alloc] initWithGroupID:groupID];
        [self.navigationController pushViewController:nextVC animated:YES];
    }else if(indexPath.section==1 && indexPath.row==1){
        DICHOGroupRemoveViewController *nextVC = [[DICHOGroupRemoveViewController alloc] initWithGroupID:groupID];
        [self.navigationController pushViewController:nextVC animated:YES];
    }else{
        deleteAlert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to delete this group?" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: @"Yes", @"No", nil];
        [deleteAlert show];
    }
}


#pragma mark - Connection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if(connection==settingsInfoConnection){
        settingsInfoData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(connection==settingsInfoConnection){
        [settingsInfoData appendData:data];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(connection==settingsInfoConnection){
        [self parseSettingsInfoData];
    }else if(connection==deleteGroupConnection){
        [self parseDeleteData];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if(connection==settingsInfoConnection){
        [self handleSettingsInfoFail];
    }else if(connection==deleteGroupConnection){
        [self handleDeleteFail];
    }
}

-(void)parseSettingsInfoData{
    NSString *returnedInfo = [[NSString alloc] initWithData:settingsInfoData encoding: NSUTF8StringEncoding];
    returnedInfo = [returnedInfo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSArray *infoArray = [returnedInfo componentsSeparatedByString:@"|"];
    
    username = [infoArray objectAtIndex:0];
    name = [infoArray objectAtIndex:1];
    adminID = [infoArray objectAtIndex:2];
    adminUsername = [infoArray objectAtIndex:3];
    memberRequestsNumber = [infoArray objectAtIndex:4];
    
    if([adminID isEqualToString:userID]){
        [self.tableView reloadData];
    }else{
        notAdminAlert = [[UIAlertView alloc] initWithTitle:@"You are not the admin of this group." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: @"Ok", nil];
        [notAdminAlert show];
    }
    
}
-(void)handleSettingsInfoFail{
    UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [fail show];
    [self.tableView reloadData];
}

-(void)parseDeleteData{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)handleDeleteFail{
    UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [fail show];
}



-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView == notAdminAlert){
        if(buttonIndex == 0){
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if(alertView == deleteAlert){
        if(buttonIndex == 0){
            progressAlert = [[UIAlertView alloc] initWithTitle:@"Deleting..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [progressAlert show];
            
            NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/deleteGroup.php?groupID=%@", groupID];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 10.0];
            deleteGroupConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        }
    }
}

@end
