//
//  DICHOSearchUsernameViewController.m
//  Dicho
//
//  Created by Tyler Droll on 12/11/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import "DICHOSearchUsernameViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DICHOAsyncImageViewRound.h"
#import "DICHOSingleUserViewController.h"

@interface DICHOSearchUsernameViewController ()

@end

@implementation DICHOSearchUsernameViewController
@synthesize usernameSearchBar;
@synthesize searchResultsTable;
@synthesize searchAlert;
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
    [usernameSearchBar becomeFirstResponder];
    usernameSearchBar.tintColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0];
    
    resultsIDsArray = [[NSMutableArray alloc] init];
    resultsNamesArray = [[NSMutableArray alloc] init];
    resultsUsernamesArray = [[NSMutableArray alloc] init];
    userImagesArray = [[NSMutableArray alloc] init];
    imageQueue = [[NSOperationQueue alloc] init];
    imageQueue.maxConcurrentOperationCount = 6;
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
    [usernameSearchBar resignFirstResponder];
    
    NSString *givenUsernameSearch = usernameSearchBar.text;
    NSString *encodedUsernameSearch = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                        NULL,
                                                                                                        (__bridge CFStringRef) givenUsernameSearch,
                                                                                                        NULL,
                                                                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                        kCFStringEncodingUTF8));
    NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/searchUsername2.php?givenSearch=%@", encodedUsernameSearch];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 10.0];
    searchConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return resultsNamesArray.count+1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 58;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == [resultsNamesArray count]){
        static NSString *endCellIdentifier = @"endCell";
        UITableViewCell *endCell = [tableView dequeueReusableCellWithIdentifier:endCellIdentifier];
        UILabel *endCellLabel = (UILabel *) [endCell viewWithTag:1];
        
        if (endCell == nil) {
            endCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:endCellIdentifier];
        }
        
        endCellLabel.text = @"End of Results";
        return endCell;
    }else{
        static NSString *topCellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:topCellIdentifier];
        UILabel *fullnameLabel = (UILabel *) [cell viewWithTag:1];
        UILabel *usernameLabel = (UILabel *) [cell viewWithTag:2];
        UIImageView *userImageView = (UIImageView *) [cell viewWithTag:3];
        userImageView.layer.cornerRadius = 5.0;

        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:topCellIdentifier];
        }
        
        userImageView.image = [userImagesArray objectAtIndex:indexPath.row];
        usernameLabel.text = [NSString stringWithFormat:@"@%@", [resultsUsernamesArray objectAtIndex:indexPath.row]];
        fullnameLabel.text = [resultsNamesArray objectAtIndex:indexPath.row];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DICHOSingleUserViewController *nextVC = [[DICHOSingleUserViewController alloc] initWithUsername: [resultsUsernamesArray objectAtIndex:indexPath.row] askerID:[resultsIDsArray objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:nextVC animated:YES];
}


#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if(connection==searchConnection){
        searchData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(connection==searchConnection){
        [searchData appendData:data];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(connection==searchConnection){
        [self parseSearchData];
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if(connection==searchConnection){
        [self handleSearchFail];
    }
}

-(void)parseSearchData{
    NSString *returnedString = [[NSString alloc] initWithData:searchData encoding: NSUTF8StringEncoding];
    returnedString = [returnedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    [imageQueue cancelAllOperations];
    resultsIDsArray = [NSMutableArray arrayWithObjects: nil];
    resultsNamesArray = [NSMutableArray arrayWithObjects: nil];
    resultsUsernamesArray = [NSMutableArray arrayWithObjects: nil];
    [userImagesArray removeAllObjects];
    if([returnedString isEqualToString:@""]){
        [searchResultsTable reloadData];
        [searchAlert dismissWithClickedButtonIndex:0 animated:YES];
    }else{
        NSArray *infoArray = [returnedString componentsSeparatedByString:@","];
        for(int i=0; i<infoArray.count-1; i=i+3){
            [resultsIDsArray addObject:[infoArray objectAtIndex:i]];
            [resultsNamesArray addObject:[infoArray objectAtIndex:i+1]];
            [resultsUsernamesArray addObject:[infoArray objectAtIndex:i+2]];
            [userImagesArray addObject:[UIImage imageNamed:@"dichoTabBarIcon.png"]];
        }
        [searchResultsTable reloadData];
        [searchAlert dismissWithClickedButtonIndex:0 animated:YES];
        for(int i=0; i<[resultsIDsArray count]; i++){
            
            NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                    selector:@selector(loadUserImage:)
                                                                                      object:[NSNumber numberWithInt:i]];
            [imageQueue addOperation:operation];
            
        }
    }
}

-(void)loadUserImage:(NSNumber*)aRowNumber{
    int rowNumber = [aRowNumber intValue];
    NSURL * imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://dichoapp.com/userImages/%@.jpeg", [resultsIDsArray objectAtIndex:rowNumber]]];
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
        [userImagesArray replaceObjectAtIndex:rowNumber withObject:newImage];
        
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

@end
