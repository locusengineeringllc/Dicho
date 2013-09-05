//
//  DICHOGroupRequestsViewController.m
//  Dicho
//
//  Created by Tyler Droll on 8/5/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOGroupRequestsViewController.h"
#import "DICHOAsyncImageViewRound.h"
#import "DICHOSingleUserViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface DICHOGroupRequestsViewController ()

@end

@implementation DICHOGroupRequestsViewController
@synthesize progressAlert;
@synthesize actingRow;

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
    self.title = @"Requests";
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

    userIDsRequesting = [[NSMutableArray alloc] init];
    usernames = [[NSMutableArray alloc] init];
    names = [[NSMutableArray alloc] init];
    userImagesArray = [[NSMutableArray alloc] init];
    imageQueue = [[NSOperationQueue alloc] init];
    imageQueue.maxConcurrentOperationCount = 12;
    
    UIBarButtonItem *acceptAllButton = [[UIBarButtonItem alloc] initWithTitle:@"Accept All"
                                                                  style:UIBarButtonItemStyleBordered target:self action:@selector(acceptAll:)];
    
    self.navigationItem.rightBarButtonItem = acceptAllButton;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0];
    self.navigationItem.rightBarButtonItem.enabled = NO;

    //get list of userInfos
    NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/requesterInfos.php?groupID=%@", groupID];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 15.0];
    requesterInfosConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
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
    return [userIDsRequesting count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 58;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"requestCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *nameLabel;
    UILabel *usernameLabel;
    UIButton *acceptButton;
    UIButton *denyButton;
    UIButton *userImageButton;
    UIImageView *userImageView;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 8, 42, 42)];
        userImageView.tag = 6;
        userImageView.backgroundColor = [UIColor lightGrayColor];
        userImageView.contentMode = UIViewContentModeScaleAspectFill;
        userImageView.clipsToBounds = YES;
        userImageView.layer.cornerRadius = 5.0;
        [cell.contentView addSubview:userImageView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(98, 14, 182, 15)];
        nameLabel.tag = 1;
        nameLabel.text = [names objectAtIndex:indexPath.row];
        nameLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:12.0];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:nameLabel];
        
        usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(98, 29, 182, 15)];
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
        [userImageButton setFrame:CGRectMake(50, 8, 42, 42)];
        userImageButton.showsTouchWhenHighlighted = YES;
        [userImageButton setTitle:nil forState:UIControlStateNormal];
        [userImageButton addTarget:self action:@selector(goToUser:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:userImageButton];
        
        //create, formant, and add customAnswerButton
        acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
        acceptButton.tag = 4;
        [acceptButton addTarget:self action:@selector(accept:) forControlEvents:UIControlEventTouchUpInside];
        [acceptButton setFrame:CGRectMake(6, 14, 32, 30)];

        [acceptButton setUserInteractionEnabled:YES];
        acceptButton.layer.masksToBounds = NO;
        acceptButton.layer.cornerRadius = 5.0f;
        CAGradientLayer *btnGradient2 = [CAGradientLayer layer];
        btnGradient2.frame = acceptButton.bounds;
        btnGradient2.colors = [NSArray arrayWithObjects:
                               (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                               (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                               nil];
        [acceptButton.layer insertSublayer:btnGradient2 atIndex:0];
        acceptButton.showsTouchWhenHighlighted = YES;
        
        [acceptButton setTitle:@"✓" forState:UIControlStateNormal];
        [acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        acceptButton.backgroundColor = [UIColor greenColor];
        acceptButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:30.0f];
        [cell.contentView addSubview:acceptButton];

        
        //create, formant, and add customAnswerButton
        denyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        denyButton.tag = 5;
        [denyButton addTarget:self action:@selector(deny:) forControlEvents:UIControlEventTouchUpInside];
        [denyButton setFrame:CGRectMake(282, 14, 32, 30)];
        [denyButton setUserInteractionEnabled:YES];
        denyButton.layer.masksToBounds = NO;
        denyButton.layer.cornerRadius = 5.0f;
        CAGradientLayer *btnGradient = [CAGradientLayer layer];
        btnGradient.frame = denyButton.bounds;
        btnGradient.colors = [NSArray arrayWithObjects:
                              (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                              (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                              nil];
        [denyButton.layer insertSublayer:btnGradient atIndex:0];
        denyButton.showsTouchWhenHighlighted = YES;
        [denyButton setTitle:@"X" forState:UIControlStateNormal];
        [denyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        denyButton.backgroundColor = [UIColor redColor];
        denyButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:24.0f];
        [cell.contentView addSubview:denyButton];
        
    }else{
        
        nameLabel = (UILabel *)[cell.contentView viewWithTag:1];
        usernameLabel = (UILabel *)[cell.contentView viewWithTag:2];
        userImageButton = (UIButton *)[cell.contentView viewWithTag:3];
        acceptButton = (UIButton *)[cell.contentView viewWithTag:4];
        denyButton = (UIButton *)[cell.contentView viewWithTag:5];
        userImageView = (UIImageView *)[cell.contentView viewWithTag:6];
        
    }
    
    userImageView.image = [userImagesArray objectAtIndex:indexPath.row];
    nameLabel.text = [names objectAtIndex:indexPath.row];
    usernameLabel.text = [NSString stringWithFormat:@"@%@", [usernames objectAtIndex:indexPath.row]];
    [userImageButton setFrame:CGRectMake(50, 8, 42, 42)];
    
    
    return cell;
}

#pragma mark - Connection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if(connection==requesterInfosConnection){
        requesterInfosData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(connection==requesterInfosConnection){
        [requesterInfosData appendData:data];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(connection==requesterInfosConnection){
        [self parseRequesterInfosData];
    }else if(connection==denyConnection){
        [self parseDenyData];
    }else if(connection==acceptConnection){
        [self parseAcceptData];
    }else if(connection==acceptAllConnection){
        [self parseAcceptAllData];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if(connection==requesterInfosConnection){
        [self handleRequesterInfosFail];
    }else if(connection==denyConnection){
        [self handleDenyFail];
    }else if(connection==acceptConnection){
        [self handleAcceptFail];
    }else if(connection==acceptAllConnection){
        [self handleAcceptAllFail];
    }
}

-(void)parseRequesterInfosData{
    NSString *infoString = [[NSString alloc] initWithData:requesterInfosData encoding: NSUTF8StringEncoding];
    infoString = [infoString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([infoString isEqualToString:@""]){
        UIAlertView *noRequests = [[UIAlertView alloc] initWithTitle:@"No requests to review." message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [noRequests show];
    }else{
        NSArray *infoArray = [infoString componentsSeparatedByString:@","];
        for(int i=0; i<infoArray.count-1; i=i+3){
            [userIDsRequesting addObject:[infoArray objectAtIndex:i]];
            [names addObject:[infoArray objectAtIndex:i+1]];
            [usernames addObject:[infoArray objectAtIndex:i+2]];
            [userImagesArray addObject:[UIImage imageNamed:@"dichoTabBarIcon.png"]];
        }
        [self.tableView reloadData];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        for(int i=0; i<[userIDsRequesting count]; i++){
            
            NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                    selector:@selector(loadUserImage:)
                                                                                      object:[NSNumber numberWithInt:i]];
            [imageQueue addOperation:operation];
            
        }

    }
    
}

-(void)loadUserImage:(NSNumber*)aRowNumber{
    int rowNumber = [aRowNumber intValue];
    NSURL * imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://dichoapp.com/userImages/%@.jpeg", [userIDsRequesting objectAtIndex:rowNumber]]];
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

-(void)handleRequesterInfosFail{
    UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [fail show];
}

- (IBAction)acceptAll:(id)sender{
    progressAlert = [[UIAlertView alloc] initWithTitle:@"Accepting all..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [progressAlert show];
        
    NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/acceptAllRequests.php?groupID=%@", groupID];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 10.0];
    acceptAllConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

}
-(void)parseAcceptAllData{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    
    [userIDsRequesting removeAllObjects];
    [names removeAllObjects];
    [usernames removeAllObjects];
    [userImagesArray removeAllObjects];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self.tableView reloadData];
    

}
-(void)handleAcceptAllFail{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];

    UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [fail show];
}



- (IBAction)accept:(id)sender{
    progressAlert = [[UIAlertView alloc] initWithTitle:@"Accepting..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [progressAlert show];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    actingRow = indexPath.row;
    
    NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/acceptRequest.php?groupID=%@&memberID=%@", groupID, [userIDsRequesting objectAtIndex:indexPath.row]];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 10.0];
    acceptConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

}
-(void)parseAcceptData{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    
    [userIDsRequesting removeObjectAtIndex:actingRow];
    [names removeObjectAtIndex:actingRow];
    [usernames removeObjectAtIndex:actingRow];
    [userImagesArray removeObjectAtIndex:actingRow];
    [self.tableView reloadData];

}
-(void)handleAcceptFail{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [fail show];
}


- (IBAction)deny:(id)sender{
    progressAlert = [[UIAlertView alloc] initWithTitle:@"Denying..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [progressAlert show];
   
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    actingRow = indexPath.row;
    
    NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/denyRequest.php?groupID=%@&memberID=%@", groupID, [userIDsRequesting objectAtIndex:indexPath.row]];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 10.0];
    denyConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

}
-(void)parseDenyData{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];

    [userIDsRequesting removeObjectAtIndex:actingRow];
    [names removeObjectAtIndex:actingRow];
    [usernames removeObjectAtIndex:actingRow];
    [userImagesArray removeObjectAtIndex:actingRow];
    [self.tableView reloadData];
    
}
-(void)handleDenyFail{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [fail show];
}



-(IBAction)goToUser:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    
    DICHOSingleUserViewController *nextVC = [[DICHOSingleUserViewController alloc] initWithUsername: [usernames objectAtIndex:indexPath.row] askerID:[userIDsRequesting objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:nextVC animated:YES];
    
}

@end
