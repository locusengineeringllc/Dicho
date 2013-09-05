//
//  DICHOSearchGroupsViewController.m
//  Dicho
//
//  Created by Tyler Droll on 8/7/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOSearchGroupsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DICHOAsyncImageViewRound.h"

@interface DICHOSearchGroupsViewController ()

@end

@implementation DICHOSearchGroupsViewController
@synthesize groupSearchBar;
@synthesize searchResultsTable;
@synthesize searchAlert;
@synthesize joiningRow;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) viewDidAppear:(BOOL)animated{
    NSString *loginStatus = [prefs objectForKey:@"loggedIn"];
    NSString *firstTimeStatus = [prefs objectForKey:@"firstTimeToSearch"];
    
    if([loginStatus isEqualToString:@"no"]){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else if([firstTimeStatus isEqualToString:@"yes"]){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [imageQueue setSuspended:NO];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    prefs= [NSUserDefaults standardUserDefaults];
    userID = [prefs objectForKey:@"userID"];
    [groupSearchBar becomeFirstResponder];
    groupSearchBar.tintColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0];
    
    groupsIDsArray = [[NSMutableArray alloc] init];
    namesArray = [[NSMutableArray alloc] init];
    usernamesArray = [[NSMutableArray alloc] init];
    groupImagesArray = [[NSMutableArray alloc] init];
    imageQueue = [[NSOperationQueue alloc] init];
    imageQueue.maxConcurrentOperationCount = 8;

}

- (void)viewWillDisappear:(BOOL)animated {
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == self) {
        // View is disappearing because a new view controller was pushed onto the stack
        [imageQueue setSuspended:YES];
    } else if ([viewControllers indexOfObject:self] == NSNotFound) {
        // View is disappearing because it was popped from the stack
        [imageQueue cancelAllOperations];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    searchAlert = [[UIAlertView alloc] initWithTitle:@"Searching..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [searchAlert show];
    [groupSearchBar resignFirstResponder];
    
    NSString *givenGroupUsernameSearch = groupSearchBar.text;
    NSString *encodedGroupUsernameSearch = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                            NULL,
                                                                                                            (__bridge CFStringRef) givenGroupUsernameSearch,
                                                                                                            NULL,
                                                                                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                            kCFStringEncodingUTF8));
    NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/searchGroupUsername.php?givenSearch=%@&userID=%@", encodedGroupUsernameSearch, userID];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 10.0];
    searchConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return groupsIDsArray.count+1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 58;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == [groupsIDsArray count]){
        static NSString *endCellIdentifier = @"endCell";
        UITableViewCell *endCell = [tableView dequeueReusableCellWithIdentifier:endCellIdentifier];
        UILabel *endCellLabel = (UILabel *) [endCell viewWithTag:1];
        
        if (endCell == nil) {
            endCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:endCellIdentifier];
        }
        
        endCellLabel.text = @"End of Results";
        return endCell;
    }else{
        static NSString *topCellIdentifier = @"groupCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:topCellIdentifier];
        UILabel *fullnameLabel = (UILabel *) [cell viewWithTag:1];
        UILabel *usernameLabel = (UILabel *) [cell viewWithTag:2];
        UIImageView *groupImageView = (UIImageView *) [cell viewWithTag:3];
        groupImageView.layer.cornerRadius = 5.0;

        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:topCellIdentifier];
        }
        groupImageView.image = [groupImagesArray objectAtIndex:indexPath.row];
        
        //create, formant, and add joinButton
        UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        joinButton.tag = 4;
        [joinButton setFrame:CGRectMake(267, 14, 48, 30)];
        [joinButton addTarget:self action:@selector(join:) forControlEvents:UIControlEventTouchUpInside];
        [joinButton setUserInteractionEnabled:YES];
        joinButton.layer.masksToBounds = NO;
        joinButton.layer.cornerRadius = 5.0f;
        CAGradientLayer *btnGradient = [CAGradientLayer layer];
        btnGradient.frame = joinButton.bounds;
        btnGradient.colors = [NSArray arrayWithObjects:
                              (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                              (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                              nil];
        [joinButton.layer insertSublayer:btnGradient atIndex:0];
        joinButton.showsTouchWhenHighlighted = YES;
        
        [joinButton setTitle:@"JOIN" forState:UIControlStateNormal];
        [joinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        joinButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0];
        joinButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:12.0f];
        [cell.contentView addSubview:joinButton];

        
        usernameLabel.text = [NSString stringWithFormat:@"@%@", [usernamesArray objectAtIndex:indexPath.row]];
        fullnameLabel.text = [namesArray objectAtIndex:indexPath.row];
        
        return cell;
    }
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if(connection==searchConnection){
        searchData = [[NSMutableData alloc] init];
    }else if(connection==joinConnection){
        joinData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(connection==searchConnection){
        [searchData appendData:data];
    }else if(connection==joinConnection){
        [joinData appendData:data];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(connection==searchConnection){
        [self parseSearchData];
    }else if(connection==joinConnection){
        [self parseJoinData];
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if(connection==searchConnection){
        [self handleSearchFail];
    }else if(connection==joinConnection){
        [self handleJoinFail];
    }
}

-(void)parseSearchData{
    NSString *returnedString = [[NSString alloc] initWithData:searchData encoding: NSUTF8StringEncoding];
    returnedString = [returnedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [imageQueue cancelAllOperations];
    groupsIDsArray = [NSMutableArray arrayWithObjects: nil];
    namesArray = [NSMutableArray arrayWithObjects: nil];
    usernamesArray = [NSMutableArray arrayWithObjects: nil];
    [groupImagesArray removeAllObjects];
    
    if([returnedString isEqualToString:@""]){
        [searchResultsTable reloadData];
        [searchAlert dismissWithClickedButtonIndex:0 animated:YES];
    }else{
        NSArray *infoArray = [returnedString componentsSeparatedByString:@","];
        for(int i=0; i<infoArray.count-1; i=i+3){
            [groupsIDsArray addObject:[infoArray objectAtIndex:i]];
            [namesArray addObject:[infoArray objectAtIndex:i+1]];
            [usernamesArray addObject:[infoArray objectAtIndex:i+2]];
            [groupImagesArray addObject:[UIImage imageNamed:@"dichoTabBarIcon.png"]];
        }
        [searchResultsTable reloadData];
        [searchAlert dismissWithClickedButtonIndex:0 animated:YES];
        for(int i=0; i<[groupsIDsArray count]; i++){
            
            NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                    selector:@selector(loadGroupImage:)
                                                                                      object:[NSNumber numberWithInt:i]];
            [imageQueue addOperation:operation];
            
        }
    }
}

-(void)loadGroupImage:(NSNumber*)aRowNumber{
    int rowNumber = [aRowNumber intValue];
    NSURL * imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://dichoapp.com/groupImages/%@.jpeg", [groupsIDsArray objectAtIndex:rowNumber]]];
    NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
    
    if(imageData != nil){
        UIImage * image = [UIImage imageWithData:imageData];
        
        //resize image to let tableview scroll more smoothly
        CGFloat widthFactor = image.size.width/40;
        CGFloat heightFactor = image.size.height/40;
        CGFloat scaleFactor;
        
        if(widthFactor<heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        CGSize desiredSize = CGSizeMake(image.size.width/scaleFactor, image.size.height/scaleFactor);
        UIGraphicsBeginImageContextWithOptions(desiredSize, NO, 0.0);
        [image drawInRect:CGRectMake(0,0,desiredSize.width,desiredSize.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [groupImagesArray replaceObjectAtIndex:rowNumber withObject:newImage];
        
        NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:rowNumber inSection:0];
        NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
        
        [self.searchResultsTable performSelectorOnMainThread:@selector(reloadRowsAtIndexPaths:withRowAnimation:) withObject:rowsToReload waitUntilDone:NO];
    }
}

-(void)handleSearchFail{
    [searchAlert dismissWithClickedButtonIndex:0 animated:YES];
    searchAlert = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [searchAlert show];
}

-(IBAction)join:(id)sender{
    searchAlert = [[UIAlertView alloc] initWithTitle:@"Sending request..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [searchAlert show];
    
    NSIndexPath *indexPath = [searchResultsTable indexPathForCell:(UITableViewCell*)[[sender superview] superview]];
    joiningRow = indexPath.row;
    
    
    NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/groupJoinRequest.php?groupID=%@&userID=%@", [groupsIDsArray objectAtIndex:indexPath.row], userID];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 10.0];
    joinConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(void)parseJoinData{
    [searchAlert dismissWithClickedButtonIndex:0 animated:YES];
    
    [groupsIDsArray removeObjectAtIndex:joiningRow];
    [namesArray removeObjectAtIndex:joiningRow];
    [usernamesArray removeObjectAtIndex:joiningRow];
    [searchResultsTable reloadData];
    
    searchAlert = [[UIAlertView alloc] initWithTitle:@"Request Sent" message:@"The group's admin must approve your request." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [searchAlert show];
    
    
}

-(void)handleJoinFail{
    [searchAlert dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [fail show];

}


@end
