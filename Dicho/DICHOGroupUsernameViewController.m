//
//  DICHOGroupUsernameViewController.m
//  Dicho
//
//  Created by Tyler Droll on 8/3/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOGroupUsernameViewController.h"

@interface DICHOGroupUsernameViewController ()

@end

@implementation DICHOGroupUsernameViewController
@synthesize usernameTextField;
@synthesize progressAlert;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithGroupID:(NSString*)givenGroupID username:(NSString*)givenUsername{
    self = [super init];
    if( !self) return nil;
    self.title = @"Username";
    groupID = givenGroupID;
    originalUsername = givenUsername;
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

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];

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
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row==1){
        return 100;
    }
    else return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0){
        static NSString *CellIdentifier = @"textFieldCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 7, 270, 30)];
            usernameTextField.font = [UIFont fontWithName:@"ArialMT" size:14.0];
            usernameTextField.textAlignment = NSTextAlignmentLeft;
            usernameTextField.delegate = self;
            usernameTextField.text = originalUsername;
            usernameTextField.borderStyle = UITextBorderStyleRoundedRect;
            usernameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            usernameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            
            [cell.contentView addSubview:usernameTextField];
            
        }
        return cell;
    }else if(indexPath.row==1){
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 9, 181, 21)];
            firstLabel.text = @"-Username must be unique";
            firstLabel.font = [UIFont fontWithName:@"ArialMT" size:15.0];
            firstLabel.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:firstLabel];
            
            UILabel *secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 211, 21)];
            secondLabel.text = @"-Max of 15 characters";
            secondLabel.font = [UIFont fontWithName:@"ArialMT" size:15.0];
            secondLabel.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:secondLabel];
            
            UILabel *thirdLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 51, 187, 43)];
            thirdLabel.numberOfLines = 2;
            thirdLabel.text = @"-Only letters, numbers, and underscores allowed";
            thirdLabel.font = [UIFont fontWithName:@"ArialMT" size:15.0];
            thirdLabel.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:thirdLabel];
            
            
        }
        return cell;
    }else{
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            
            UILabel *changeLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, 11, 157, 21)];
            changeLabel.text = @"Change Username";
            changeLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0];
            changeLabel.textColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0];
            changeLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:changeLabel];
            
        }
        return cell;
    }

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==2){
        NSString *errorMessage = @"";
        bool usernameGood = YES;
        
        //username has bad characters
        NSCharacterSet *usernameCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"];
        usernameCharacterSet = [usernameCharacterSet invertedSet];
        NSRange r = [usernameTextField.text rangeOfCharacterFromSet:usernameCharacterSet];
        if (r.location != NSNotFound) {
            usernameGood = NO;
            //NSLog(@"the string contains illegal characters");
            errorMessage =[NSString stringWithFormat:@"%@ Username has invalid characters.", errorMessage];
        }
        
        //username is empty
        if(usernameTextField.text.length==0){
            usernameGood = NO;
            errorMessage =[NSString stringWithFormat:@"%@ Username is empty.", errorMessage];
        }
        
        //username is too long
        if(usernameTextField.text.length>15){
            usernameGood = NO;
            errorMessage =[NSString stringWithFormat:@"%@ Username is too long.", errorMessage];
        }
        
        //username is "Anonymous"
        NSString *lowerCaseUsername = [usernameTextField.text lowercaseString];
        if([lowerCaseUsername isEqualToString:@"anonymous"]){
            usernameGood = NO;
            errorMessage =[NSString stringWithFormat:@"%@ Username cannot be Anonymous.", errorMessage];
        }
        
        //check uniqueness
        if(usernameGood==YES){
            progressAlert = [[UIAlertView alloc] initWithTitle:@"Updating..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [progressAlert show];
            
            //perform uniqueness check
            NSString *username = usernameTextField.text;
            NSString *encodedUsername = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                              NULL,
                                                                                                              (__bridge CFStringRef) username,
                                                                                                              NULL,
                                                                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                              kCFStringEncodingUTF8));
            NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/changeGroupUsername.php?groupID=%@&username=%@", groupID, encodedUsername];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
            usernameConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
        }else{
            //make alert box
            UIAlertView *usernameAlert= [[UIAlertView alloc] initWithTitle:@"Unacceptable Username" message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [usernameAlert show];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    usernameData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [usernameData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    [self parseUsernameData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    [self handleUsernameFail];
}

-(void)parseUsernameData{
    NSString *strData = [[NSString alloc]initWithData:usernameData encoding:NSUTF8StringEncoding];
    strData = [strData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    if ([strData isEqualToString:@"1"]){
        progressAlert = [[UIAlertView alloc] initWithTitle:@"Username is not unique." message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    }else{
        progressAlert = [[UIAlertView alloc] initWithTitle:@"Username updated successfully." message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    }
    [progressAlert show];

}
-(void)handleUsernameFail{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    progressAlert= [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [progressAlert show];
}


@end
