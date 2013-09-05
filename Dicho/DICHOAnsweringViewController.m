//
//  DICHOAnsweringViewController.m
//  Dicho
//
//  Created by Tyler Droll on 11/17/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import "DICHOAnsweringViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DICHOAsyncImageViewRound.h"



@interface DICHOAnsweringViewController ()

@end

@implementation DICHOAnsweringViewController
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    progressAlert = [[UIAlertView alloc] initWithTitle:@"Loading..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [progressAlert show];
    
    prefs= [NSUserDefaults standardUserDefaults];
    userID = [prefs objectForKey:@"userID"];
    
    userIDsAnswering = [[NSMutableArray alloc] init];
    usernamesAnswering = [[NSMutableArray alloc] init];
    namesAnswering = [[NSMutableArray alloc] init];
    answeringStatuses = [[NSMutableArray alloc] init];
    
    //get list of userIDs he is asking
    NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/answeringUserIDs.php?answering=%@&displayedNumber=0", userID];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 15.0];
    answeringIDsConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(void)viewDidAppear:(BOOL)animated{
    NSString *loginStatus = [prefs objectForKey:@"loggedIn"];
    NSString *firstTimeStatus = [prefs objectForKey:@"firstTimeToHome"];
    
    if([loginStatus isEqualToString:@"no"]){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else if([firstTimeStatus isEqualToString:@"yes"]){
        [self.navigationController popToRootViewControllerAnimated:YES];
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
    return [userIDsAnswering count] + 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 58;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row<[userIDsAnswering count]){
        static NSString *CellIdentifier = @"answeringCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        UILabel *usernameLabel = (UILabel *) [cell viewWithTag:4];
        UILabel *nameLabel = (UILabel *) [cell viewWithTag:1];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }else{
            
            DICHOAsyncImageViewRound* oldImage = (DICHOAsyncImageViewRound*)[cell.contentView viewWithTag:5];
            [oldImage removeFromSuperview];
        }
        DICHOAsyncImageViewRound* askerImage = [[DICHOAsyncImageViewRound alloc]
                                                initWithFrame:CGRectMake(6, 8, 42, 42)];
        askerImage.tag = 5;
        //use askerID/username to pull and store userImage
        NSString *imageUrl;
        imageUrl= [NSString stringWithFormat:@"http://dichoapp.com/userImages/%@.jpeg", [userIDsAnswering objectAtIndex:indexPath.row]];
        [askerImage loadImageFromURL:[NSURL URLWithString:imageUrl]];
        [cell.contentView addSubview:askerImage];
        
        usernameLabel.text = [usernamesAnswering objectAtIndex:indexPath.row];
        nameLabel.text = [namesAnswering objectAtIndex:indexPath.row];
        
        UIButton *customAnswerButton = [UIButton buttonWithType:UIButtonTypeCustom];
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
        return cell;
        
    }else{
        static NSString *CellIdentifier = @"loadMoreCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==[userIDsAnswering count]){
        progressAlert = [[UIAlertView alloc] initWithTitle:@"Loading more..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [progressAlert show];
        
        NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/answeringUserIDs.php?answering=%@&displayedNumber=%d", userID, [userIDsAnswering count]];
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 15.0];
        answeringIDsConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

#pragma mark - Connection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if(connection==answeringIDsConnection){
        answeringIDsData = [[NSMutableData alloc] init];
    }else if(connection==infoConnection){
        infoData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(connection==answeringIDsConnection){
        [answeringIDsData appendData:data];
    }else if(connection==infoConnection){
        [infoData appendData:data];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(connection==answeringIDsConnection){
        [self parseAnsweringIDsData];
    }else if(connection==infoConnection){
        [self parseInfoData];
    }else if(connection==unansweringConnection){
        [self parseUnansweringData];
    }else if(connection==answeringConnection){
        [self parseAnsweringData];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if(connection==answeringIDsConnection){
        [self handleAnsweringIDsFail];
    }else if(connection==infoConnection){
        [self handleInfoFail];
    }else if(connection==unansweringConnection){
        [self handleAnsweringFail];
    }else if(connection==answeringConnection){
        [self handleAnsweringFail];
    }
}

-(void)parseAnsweringIDsData{
    userIDsAnsweringToBeAddedArray = [[NSMutableArray alloc] init];
    NSString *listOfUserIDs = [[NSString alloc] initWithData:answeringIDsData encoding: NSUTF8StringEncoding];
    listOfUserIDs = [listOfUserIDs stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([listOfUserIDs isEqualToString:@""]){
        [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
        UIAlertView *loadedAll = [[UIAlertView alloc] initWithTitle:@"Loaded all users." message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [loadedAll show];
    }else{
        NSArray *userIDsToBeAdded = [listOfUserIDs componentsSeparatedByString:@","];
        for(int i=0; i<userIDsToBeAdded.count; i++){
            [userIDsAnsweringToBeAddedArray addObject:[userIDsToBeAdded objectAtIndex:i]];
        }
        
        if([userIDsAnsweringToBeAddedArray count] >0){
            NSString *currentUserID = [userIDsAnsweringToBeAddedArray objectAtIndex:0];
            NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/getNamesFromUserID.php?givenID=%@", currentUserID];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
            infoConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        }
    }
}

-(void)handleAnsweringIDsFail{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [fail show];
}

-(void)parseInfoData{
    [userIDsAnswering addObject:[userIDsAnsweringToBeAddedArray objectAtIndex:0]];
    [userIDsAnsweringToBeAddedArray removeObjectAtIndex:0];
    
    NSString *userInfo = [[NSString alloc] initWithData:infoData encoding: NSUTF8StringEncoding];
    NSArray *userInfoParts = [userInfo componentsSeparatedByString:@","];
    
    [namesAnswering addObject:[userInfoParts objectAtIndex:0]];
    [usernamesAnswering addObject:[userInfoParts objectAtIndex:1]];
    //can add 1 because answering all
    [answeringStatuses addObject:@"1"];
    
    if([userIDsAnsweringToBeAddedArray count] >0){
        NSString *currentUserID = [userIDsAnsweringToBeAddedArray objectAtIndex:0];
        NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/getNamesFromUserID.php?givenID=%@", currentUserID];
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
        infoConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }else{
        [self.tableView reloadData];
        [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    }
}
-(void)handleInfoFail{
    [self.tableView reloadData];
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [fail show];
}

-(IBAction)answer:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[sender superview] superview]];
    answeringRow = indexPath.row;
    if([[answeringStatuses objectAtIndex:indexPath.row] isEqualToString:@"1"]){
        if([[userIDsAnswering objectAtIndex:indexPath.row] isEqualToString:@"1"]){
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"You can't unanswer Dicho!" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }else if([[userIDsAnswering objectAtIndex:indexPath.row] isEqualToString:userID]){
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"You can't unanswer yourself!" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }else{
            progressAlert = [[UIAlertView alloc] initWithTitle:@"Unanswering..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [progressAlert show];
            NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/unanswer.php?askerID=%@&answererID=%@", [userIDsAnswering objectAtIndex:indexPath.row], userID];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 10.0];
            unansweringConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        }
    }else if([[answeringStatuses objectAtIndex:indexPath.row] isEqualToString:@"0"]){
        progressAlert = [[UIAlertView alloc] initWithTitle:@"Answering..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [progressAlert show];
        NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/addAnswerer.php?askerID=%@&answererID=%@", [userIDsAnswering objectAtIndex:indexPath.row], userID];
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



@end
