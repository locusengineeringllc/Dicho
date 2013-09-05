//
//  DICHOGroupRemoveViewController.m
//  Dicho
//
//  Created by Tyler Droll on 8/6/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOGroupRemoveViewController.h"
#import "DICHOAsyncImageViewRound.h"
#import "DICHOSingleUserViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface DICHOGroupRemoveViewController ()

@end

@implementation DICHOGroupRemoveViewController
@synthesize progressAlert;
@synthesize removingRow;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)initWithGroupID:(NSString *)givenGroupID{
    self = [super init];
    if( !self) return nil;
    self.title = @"Remove Members";
    groupID = givenGroupID;
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
            }else{
                [imageQueue setSuspended:NO];
            }
        }else if(self.tabBarController.selectedIndex == 3){
            if([[prefs objectForKey:@"firstTimeToHome"] isEqualToString:@"yes"]){
                [self.navigationController popToRootViewControllerAnimated:YES];
            }else{
                [imageQueue setSuspended:NO];
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    prefs= [NSUserDefaults standardUserDefaults];

    memberIDs = [[NSMutableArray alloc] init];
    usernames = [[NSMutableArray alloc] init];
    names = [[NSMutableArray alloc] init];
    userImagesArray = [[NSMutableArray alloc] init];
    imageQueue = [[NSOperationQueue alloc] init];
    imageQueue.maxConcurrentOperationCount = 12;
    
    //get list of userIDs
    NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/memberInfosRemove.php?groupID=%@", groupID];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 15.0];
    memberInfosConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
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
    return [memberIDs count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 58;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"removeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *nameLabel;
    UILabel *usernameLabel;
    UIButton *removeButton;
    UIButton *userImageButton;
    UIImageView *userImageView;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 8, 42, 42)];
        userImageView.tag = 6;
        userImageView.backgroundColor = [UIColor lightGrayColor];
        userImageView.contentMode = UIViewContentModeScaleAspectFill;
        userImageView.clipsToBounds = YES;
        userImageView.layer.cornerRadius = 5.0;
        [cell.contentView addSubview:userImageView];

        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(56, 14, 220, 15)];
        nameLabel.tag = 1;
        nameLabel.text = [names objectAtIndex:indexPath.row];
        nameLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:12.0];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:nameLabel];
        
        usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(56, 29, 220, 15)];
        usernameLabel.tag = 2;
        usernameLabel.text = [NSString stringWithFormat:@"@%@", [usernames objectAtIndex:indexPath.row]];
        usernameLabel.font = [UIFont fontWithName:@"ArialMT" size:12.0];
        usernameLabel.textColor = [UIColor blackColor];
        usernameLabel.textAlignment = NSTextAlignmentLeft;
        usernameLabel.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:usernameLabel];
        
        //create, format, and add userimagebutton
        userImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        userImageButton.tag = 3;
        [userImageButton setFrame:CGRectMake(6, 8, 42, 42)];
        userImageButton.showsTouchWhenHighlighted = YES;
        [userImageButton setTitle:nil forState:UIControlStateNormal];
        [userImageButton addTarget:self action:@selector(goToUser:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:userImageButton];
        
        
        //create, formant, and add customAnswerButton
        removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        removeButton.tag = 4;
        [removeButton addTarget:self action:@selector(removeMember:) forControlEvents:UIControlEventTouchUpInside];
        [removeButton setFrame:CGRectMake(282, 14, 32, 30)];
        [removeButton setUserInteractionEnabled:YES];
        removeButton.layer.masksToBounds = NO;
        removeButton.layer.cornerRadius = 5.0f;
        CAGradientLayer *btnGradient = [CAGradientLayer layer];
        btnGradient.frame = removeButton.bounds;
        btnGradient.colors = [NSArray arrayWithObjects:
                              (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                              (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                              nil];
        [removeButton.layer insertSublayer:btnGradient atIndex:0];
        removeButton.showsTouchWhenHighlighted = YES;
        [removeButton setTitle:@"X" forState:UIControlStateNormal];
        [removeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        removeButton.backgroundColor = [UIColor redColor];
        removeButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:24.0f];
        [cell.contentView addSubview:removeButton];
        
    }else{        
        nameLabel = (UILabel *)[cell.contentView viewWithTag:1];
        usernameLabel = (UILabel *)[cell.contentView viewWithTag:2];
        userImageButton = (UIButton *)[cell.contentView viewWithTag:3];
        removeButton = (UIButton *)[cell.contentView viewWithTag:4];
        userImageView = (UIImageView *)[cell.contentView viewWithTag:6];
        
    }
    
    userImageView.image = [userImagesArray objectAtIndex:indexPath.row];
    nameLabel.text = [names objectAtIndex:indexPath.row];
    usernameLabel.text = [NSString stringWithFormat:@"@%@", [usernames objectAtIndex:indexPath.row]];
    [userImageButton setFrame:CGRectMake(6, 8, 42, 42)];
    
    return cell;
}

#pragma mark - Connection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if(connection==memberInfosConnection){
        memberInfosData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(connection==memberInfosConnection){
        [memberInfosData appendData:data];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(connection==memberInfosConnection){
        [self parseMemberInfosData];
    }else if(connection==removeMemberConnection){
        [self parseRemoveData];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if(connection==memberInfosConnection){
        [self handleMemberInfosFail];
    }else if(connection==removeMemberConnection){
        [self handleRemoveFail];
    }
}

-(void)parseMemberInfosData{
    NSString *infoString = [[NSString alloc] initWithData:memberInfosData encoding: NSUTF8StringEncoding];
    infoString = [infoString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([infoString isEqualToString:@""]){
        
    }else{
        NSArray *infoArray = [infoString componentsSeparatedByString:@","];
        for(int i=0; i<infoArray.count-1; i=i+3){
            [memberIDs addObject:[infoArray objectAtIndex:i]];
            [names addObject:[infoArray objectAtIndex:i+1]];
            [usernames addObject:[infoArray objectAtIndex:i+2]];
            [userImagesArray addObject:[UIImage imageNamed:@"dichoTabBarIcon.png"]];
        }
        [self.tableView reloadData];
        for(int i=0; i<[memberIDs count]; i++){
            
            NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                    selector:@selector(loadUserImage:)
                                                                                      object:[NSNumber numberWithInt:i]];
            [imageQueue addOperation:operation];
            
        }

    }
    
}

-(void)loadUserImage:(NSNumber*)aRowNumber{
    int rowNumber = [aRowNumber intValue];
    NSURL * imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://dichoapp.com/userImages/%@.jpeg", [memberIDs objectAtIndex:rowNumber]]];
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
        [userImagesArray replaceObjectAtIndex:rowNumber withObject:newImage];
        
        NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:rowNumber inSection:0];
        NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
        
        [self.tableView performSelectorOnMainThread:@selector(reloadRowsAtIndexPaths:withRowAnimation:) withObject:rowsToReload waitUntilDone:NO];
    }
}

-(void)handleMemberInfosFail{
    UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [fail show];
}

- (IBAction)removeMember:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    if([[memberIDs objectAtIndex:indexPath.row] isEqualToString:[prefs objectForKey:@"userID"]]){
        UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Can't remove yourself!" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [fail show];
    }else{
        progressAlert = [[UIAlertView alloc] initWithTitle:@"Removing..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [progressAlert show];
        
        removingRow = indexPath.row;
        
        NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/removeMember.php?groupID=%@&memberID=%@", groupID, [memberIDs objectAtIndex:indexPath.row]];
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 10.0];
        removeMemberConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}
-(void)parseRemoveData{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    
    [memberIDs removeObjectAtIndex:removingRow];
    [names removeObjectAtIndex:removingRow];
    [usernames removeObjectAtIndex:removingRow];
    [userImagesArray removeObjectAtIndex:removingRow];
    [self.tableView reloadData];
    
}
-(void)handleRemoveFail{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [fail show];
}

-(IBAction)goToUser:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    
    DICHOSingleUserViewController *nextVC = [[DICHOSingleUserViewController alloc] initWithUsername: [usernames objectAtIndex:indexPath.row] askerID:[memberIDs objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:nextVC animated:YES];
    
}

@end
