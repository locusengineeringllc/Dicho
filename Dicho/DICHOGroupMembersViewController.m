//
//  DICHOGroupMembersViewController.m
//  Dicho
//
//  Created by Tyler Droll on 8/2/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOGroupMembersViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DICHOAsyncImageViewRound.h"
#import "DICHOSingleUserViewController.h"

@interface DICHOGroupMembersViewController ()

@end

@implementation DICHOGroupMembersViewController
@synthesize progressAlert;
@synthesize answeringRow;

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
    self.title = @"Members";
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

    self.view.userInteractionEnabled = NO;
    
    prefs= [NSUserDefaults standardUserDefaults];
    userID = [prefs objectForKey:@"userID"];
    
    memberIDs = [[NSMutableArray alloc] init];
    memberUsernames = [[NSMutableArray alloc] init];
    memberNames = [[NSMutableArray alloc] init];
    answeringStatuses = [[NSMutableArray alloc] init];
    userImagesArray = [[NSMutableArray alloc] init];
    imageQueue = [[NSOperationQueue alloc] init];
    imageQueue.maxConcurrentOperationCount = 12;
    
    //get list of memberIDs for the group
    NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/memberInfos.php?groupID=%@&displayedNumber=0&userID=%@", groupID, userID];
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
    return [memberIDs count] + 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 58;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row<[memberIDs count]){
        static NSString *CellIdentifier = @"memberCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UILabel *nameLabel;
        UILabel *usernameLabel;
        UIButton *customAnswerButton;
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

            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(56, 14, 252, 15)];
            nameLabel.tag = 1;
            nameLabel.text = [memberNames objectAtIndex:indexPath.row];
            nameLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:12.0];
            nameLabel.textColor = [UIColor blackColor];
            nameLabel.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:nameLabel];
            
            usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(56, 29, 201, 15)];
            usernameLabel.tag = 2;
            usernameLabel.text = [NSString stringWithFormat:@"@%@", [memberUsernames objectAtIndex:indexPath.row]];
            usernameLabel.font = [UIFont fontWithName:@"ArialMT" size:12.0];
            usernameLabel.textColor = [UIColor blackColor];
            usernameLabel.textAlignment = NSTextAlignmentLeft;
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
            customAnswerButton = [UIButton buttonWithType:UIButtonTypeCustom];
            customAnswerButton.tag = 4;
            [customAnswerButton addTarget:self action:@selector(answer:) forControlEvents:UIControlEventTouchUpInside];
            [customAnswerButton setFrame:CGRectMake(282, 17, 32, 24)];
            [customAnswerButton setUserInteractionEnabled:YES];
            customAnswerButton.layer.masksToBounds = NO;
            customAnswerButton.layer.cornerRadius = 5.0f;
            CAGradientLayer *btnGradient = [CAGradientLayer layer];
            btnGradient.frame = customAnswerButton.bounds;
            btnGradient.colors = [NSArray arrayWithObjects:
                                  (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                                  (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                                  nil];
            [customAnswerButton.layer insertSublayer:btnGradient atIndex:0];
            customAnswerButton.showsTouchWhenHighlighted = YES;
            
            if([[answeringStatuses objectAtIndex:indexPath.row] isEqualToString:@"1"]){
                [customAnswerButton setTitle:@"✓" forState:UIControlStateNormal];
                [customAnswerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                customAnswerButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0];
                customAnswerButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:20.0f];
            }else{
                [customAnswerButton setTitle:@"?+" forState:UIControlStateNormal];
                [customAnswerButton setTitleColor:[UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0] forState:UIControlStateNormal];
                
                customAnswerButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0f];
                customAnswerButton.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
                customAnswerButton.layer.borderColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0].CGColor;
                customAnswerButton.layer.borderWidth = 1.0;
            }
            [cell.contentView addSubview:customAnswerButton];
            
            
        }else{
            nameLabel = (UILabel *)[cell.contentView viewWithTag:1];
            usernameLabel = (UILabel *)[cell.contentView viewWithTag:2];
            userImageButton = (UIButton *)[cell.contentView viewWithTag:3];
            customAnswerButton = (UIButton *)[cell.contentView viewWithTag:4];
            userImageView = (UIImageView *)[cell.contentView viewWithTag:6];
        }
        
        userImageView.image = [userImagesArray objectAtIndex:indexPath.row];
        nameLabel.text = [memberNames objectAtIndex:indexPath.row];
        usernameLabel.text = [NSString stringWithFormat:@"@%@", [memberUsernames objectAtIndex:indexPath.row]];
        [userImageButton setFrame:CGRectMake(6, 8, 42, 42)];
        
        
        if([[answeringStatuses objectAtIndex:indexPath.row] isEqualToString:@"1"]){
            [customAnswerButton setTitle:@"✓" forState:UIControlStateNormal];
            [customAnswerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            customAnswerButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0];
            customAnswerButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:20.0f];
        }else{
            [customAnswerButton setTitle:@"?+" forState:UIControlStateNormal];
            [customAnswerButton setTitleColor:[UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0] forState:UIControlStateNormal];
            
            customAnswerButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0f];
            customAnswerButton.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
            customAnswerButton.layer.borderColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0].CGColor;
            customAnswerButton.layer.borderWidth = 1.0;
        }
        
        return cell;
        
    }else{
        static NSString *CellIdentifier = @"loadMoreCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UILabel *loadMoreLabel;
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            
            loadMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(99, 18, 122, 21)];
            loadMoreLabel.text = @"Load more...";
            loadMoreLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:17.0];
            loadMoreLabel.textColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0];
            loadMoreLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:loadMoreLabel];
        }
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==[memberIDs count]){
        self.view.userInteractionEnabled = NO;
        
        NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/memberInfos.php?groupID=%@&displayedNumber=%d&userID=%@", groupID, [memberIDs count], userID];
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 15.0];
        memberInfosConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
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
    }else if(connection==unansweringConnection){
        [self parseUnansweringData];
    }else if(connection==answeringConnection){
        [self parseAnsweringData];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if(connection==memberInfosConnection){
        [self handleMemberInfosFail];
    }else if(connection==unansweringConnection){
        [self handleAnsweringFail];
    }else if(connection==answeringConnection){
        [self handleAnsweringFail];
    }
}

-(void)parseMemberInfosData{
    NSString *returnedString = [[NSString alloc] initWithData:memberInfosData encoding: NSUTF8StringEncoding];
    returnedString = [returnedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([returnedString isEqualToString:@""]){
        self.view.userInteractionEnabled = YES;
        UIAlertView *loadedAll = [[UIAlertView alloc] initWithTitle:@"Loaded all members" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [loadedAll show];
    }else{
        int existingRows = [memberIDs count];

        NSArray *infoArray = [returnedString componentsSeparatedByString:@","];
        for(int i=0; i<infoArray.count-1; i=i+4){
            [memberIDs addObject:[infoArray objectAtIndex:i]];
            [memberNames addObject:[infoArray objectAtIndex:i+1]];
            [memberUsernames addObject:[infoArray objectAtIndex:i+2]];
            [answeringStatuses addObject:[infoArray objectAtIndex:i+3]];
            [userImagesArray addObject:[UIImage imageNamed:@"dichoTabBarIcon.png"]];
        }
        [self.tableView reloadData];
        self.tableView.userInteractionEnabled = YES;
        for(int i=existingRows; i<[memberIDs count]; i++){
            
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
    self.view.userInteractionEnabled = YES;

    UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [fail show];
}


-(IBAction)answer:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    answeringRow = indexPath.row;
    if([[answeringStatuses objectAtIndex:indexPath.row] isEqualToString:@"1"]){
        if([[memberIDs objectAtIndex:indexPath.row] isEqualToString:@"1"]){
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"You can't unanswer Dicho!" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }else if([[memberIDs objectAtIndex:indexPath.row] isEqualToString:userID]){
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"You can't unanswer yourself!" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }else{
            progressAlert = [[UIAlertView alloc] initWithTitle:@"Unanswering..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [progressAlert show];
            NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/unanswer.php?askerID=%@&answererID=%@", [memberIDs objectAtIndex:indexPath.row], userID];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 10.0];
            unansweringConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        }
    }else if([[answeringStatuses objectAtIndex:indexPath.row] isEqualToString:@"0"]){
        progressAlert = [[UIAlertView alloc] initWithTitle:@"Answering..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [progressAlert show];
        NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/addAnswerer.php?askerID=%@&answererID=%@", [memberIDs objectAtIndex:indexPath.row], userID];
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 10.0];
        answeringConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

-(void)parseUnansweringData{
    [answeringStatuses replaceObjectAtIndex:answeringRow withObject:@"0"];
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:answeringRow inSection:0];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
}
-(void)parseAnsweringData{
    [answeringStatuses replaceObjectAtIndex:answeringRow withObject:@"1"];
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:answeringRow inSection:0];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
}
-(void)handleAnsweringFail{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [fail show];
}

-(IBAction)goToUser:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    
    DICHOSingleUserViewController *nextVC = [[DICHOSingleUserViewController alloc] initWithUsername: [memberUsernames objectAtIndex:indexPath.row] askerID:[memberIDs objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:nextVC animated:YES];
    
}

@end
