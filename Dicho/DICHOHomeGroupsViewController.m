//
//  DICHOHomeGroupsViewController.m
//  Dicho
//
//  Created by Tyler Droll on 8/1/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOHomeGroupsViewController.h"
#import "DICHOAsyncImageViewRound.h"
#import "DICHOSingleGroupViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface DICHOHomeGroupsViewController ()

@end

@implementation DICHOHomeGroupsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewDidAppear:(BOOL)animated{
    NSString *loginStatus = [prefs objectForKey:@"loggedIn"];
    NSString *firstTimeStatus = [prefs objectForKey:@"firstTimeToHome"];
    
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

    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.94 green:0.98 blue:1.0 alpha:1.0];

    groupsIDsArray = [[NSMutableArray alloc] init];
    groupsNamesArray = [[NSMutableArray alloc] init];
    groupsUsernamesArray = [[NSMutableArray alloc] init];
    groupImagesArray = [[NSMutableArray alloc] init];
    imageQueue = [[NSOperationQueue alloc] init];
    imageQueue.maxConcurrentOperationCount = 8;

    
    ///call for group IDs here
    NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/getOwnGroups.php?userID=%@", [prefs objectForKey:@"userID"]];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 10.0];
    groupInfosConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [groupsIDsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"groupCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UILabel *groupNameLabel = (UILabel *) [cell viewWithTag:1];
    UILabel *groupUsernameLabel = (UILabel *) [cell viewWithTag:2];
    UIImageView *groupImageView = (UIImageView *) [cell viewWithTag:3];
    groupImageView.layer.cornerRadius = 5.0;

    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    groupImageView.image = [groupImagesArray objectAtIndex:indexPath.row];
    groupNameLabel.text = [groupsNamesArray objectAtIndex:indexPath.row];
    groupUsernameLabel.text = [NSString stringWithFormat:@"@%@", [groupsUsernamesArray objectAtIndex:indexPath.row]];
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    DICHOSingleGroupViewController *nextVC = [[DICHOSingleGroupViewController alloc] initWithGroupName:[groupsNamesArray objectAtIndex:indexPath.row] groupID:[groupsIDsArray objectAtIndex:indexPath.row]];
    
    [self.navigationController pushViewController:nextVC animated:YES];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if(connection==groupInfosConnection){
        groupInfosData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(connection==groupInfosConnection){
        [groupInfosData appendData:data];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(connection==groupInfosConnection){
        [self parseGroupInfosData];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if(connection==groupInfosConnection){
        [self handleGroupInfosFail];
    }
}

-(void)parseGroupInfosData{
    //get back and trim
    NSString *returnedString = [[NSString alloc] initWithData:groupInfosData encoding: NSUTF8StringEncoding];
    returnedString = [returnedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(![returnedString isEqualToString:@""]){
        NSArray *infoArray = [returnedString componentsSeparatedByString:@","];
        for(int i=0; i<infoArray.count-1; i=i+3){
            [groupsIDsArray addObject:[infoArray objectAtIndex:i]];
            [groupsNamesArray addObject:[infoArray objectAtIndex:i+1]];
            [groupsUsernamesArray addObject:[infoArray objectAtIndex:i+2]];
            [groupImagesArray addObject:[UIImage imageNamed:@"dichoTabBarIcon.png"]];
        }
        [self.tableView reloadData];
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
        CGFloat widthFactor = image.size.width/42;
        CGFloat heightFactor = image.size.height/42;
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
        
        [self.tableView performSelectorOnMainThread:@selector(reloadRowsAtIndexPaths:withRowAnimation:) withObject:rowsToReload waitUntilDone:NO];
        
    }
}

-(void)handleGroupInfosFail{
    UIAlertView *groupIDsFail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [groupIDsFail show];
}

- (IBAction)createGroup:(id)sender {
    [self performSegueWithIdentifier:@"groupsToCreateGroup" sender:self];
}
@end
