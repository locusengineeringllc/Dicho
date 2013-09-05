//
//  DICHOShowLikesViewController.m
//  Dicho
//
//  Created by Tyler Droll on 8/20/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOShowLikesViewController.h"
#import "DICHOSingleUserViewController.h"

@interface DICHOShowLikesViewController ()

@end

@implementation DICHOShowLikesViewController
@synthesize loadedAll;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithCommentID:(NSString *)aCommentID{
    self = [super init];
    if( !self) return nil;
    self.title = @"Likes";
    selectedCommentID = aCommentID;
    loadedAll = NO;
    return self;
}

-(void) viewDidAppear:(BOOL)animated{
    NSString *loginStatus = [prefs objectForKey:@"loggedIn"];
    
    if([loginStatus isEqualToString:@"no"]){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        if(self.tabBarController.selectedIndex == 0){
            if([[prefs objectForKey:@"firstTimeToDicho"] isEqualToString:@"yes"]){
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }else if(self.tabBarController.selectedIndex == 2){
            if([[prefs objectForKey:@"firstTimeToSearch"] isEqualToString:@"yes"]){
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }else if(self.tabBarController.selectedIndex == 3){
            if([[prefs objectForKey:@"firstTimeToHome"] isEqualToString:@"yes"]){
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    prefs= [NSUserDefaults standardUserDefaults];

    self.tableView.userInteractionEnabled = NO;
    
    userIDsArray = [[NSMutableArray alloc] init];
    usernamesArray = [[NSMutableArray alloc] init];
    
    //get list of comments info
    NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/getCommentLikes.php?commentID=%@&displayedNumber=0", selectedCommentID];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 15.0];
    likersConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [userIDsArray count] + 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == [userIDsArray count])
        return 50;
    else return 30;    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row<[userIDsArray count]){
        static NSString *CellIdentifier = @"likerCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
        UILabel *username;
            
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
                
            username = [[UILabel alloc] initWithFrame:CGRectMake(5, 4, 150, 21)];
            username.tag = 1;
            username.text = [usernamesArray objectAtIndex:indexPath.row];
            username.font = [UIFont fontWithName:@"Arial-BoldMT" size:14.0];
            username.adjustsFontSizeToFitWidth = YES;
            username.textColor = [UIColor blackColor];
            username.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:username];
                
        }else{
            username = (UILabel *)[cell.contentView viewWithTag:1];
        }
        username.text = [usernamesArray objectAtIndex:indexPath.row];
            
        return cell;
            
    }else{
        static NSString *CellIdentifier = @"loadMoreCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
        UILabel *loadMoreLabel;
            
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                
            loadMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 14, 220, 21)];
            loadMoreLabel.tag = 1;
            loadMoreLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0];
            loadMoreLabel.textColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0];
            loadMoreLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:loadMoreLabel];
                
        }else{
            loadMoreLabel = (UILabel *)[cell.contentView viewWithTag:1];
        }
        if(loadedAll==YES){
            loadMoreLabel.text = @"Loaded all likes";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }else{
            loadMoreLabel.text = @"Load more likes...";
        }

        return cell;
            
    }
    
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //go to user or load more!
    if(indexPath.row == [userIDsArray count]){
        if(loadedAll == NO){
            self.tableView.userInteractionEnabled = NO;
            
            NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/getCommentLikes.php?commentID=%@&displayedNumber=%d", selectedCommentID, [userIDsArray count]];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 15.0];
            likersConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        }
    }else{
        DICHOSingleUserViewController *nextVC = [[DICHOSingleUserViewController alloc] initWithUsername: [usernamesArray objectAtIndex:indexPath.row] askerID:[userIDsArray objectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:nextVC animated:YES];
    }
}

#pragma mark - Connection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if(connection==likersConnection){
        likersData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(connection==likersConnection){
        [likersData appendData:data];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(connection==likersConnection){
        [self parseLikersData];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if(connection==likersConnection){
        [self handleConnectionFail];
    }
}

-(void)parseLikersData{
    NSString *returnedString = [[NSString alloc] initWithData:likersData encoding: NSUTF8StringEncoding];
    returnedString = [returnedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([returnedString isEqualToString:@""]){
        self.tableView.userInteractionEnabled = YES;
        loadedAll = YES;
        [self.tableView reloadData];
    }else{
        
        NSArray *infoArray = [returnedString componentsSeparatedByString:@"|"];
        for(int i=0; i<infoArray.count-1; i=i+2){
            [usernamesArray addObject:[infoArray objectAtIndex:i]];
            [userIDsArray addObject:[infoArray objectAtIndex:i+1]];
        }
        [self.tableView reloadData];
        self.tableView.userInteractionEnabled = YES;
    
    }
}

-(void)handleConnectionFail{
    self.tableView.userInteractionEnabled = YES;
    UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [fail show];
}
@end
