//
//  DICHOGroupAdminViewController.m
//  Dicho
//
//  Created by Tyler Droll on 8/4/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOGroupAdminViewController.h"

@interface DICHOGroupAdminViewController ()

@end

@implementation DICHOGroupAdminViewController
@synthesize adminTextField;
@synthesize progressAlert;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithGroupID:(NSString*)givenGroupID admin:(NSString*)givenAdmin{
    self = [super init];
    if( !self) return nil;
    self.title = @"Admin";
    groupID = givenGroupID;
    originalAdmin = givenAdmin;
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
        return 60;
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
            
            adminTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 7, 270, 30)];
            adminTextField.font = [UIFont fontWithName:@"ArialMT" size:14.0];
            adminTextField.textAlignment = NSTextAlignmentLeft;
            adminTextField.delegate = self;
            adminTextField.text = originalAdmin;
            adminTextField.borderStyle = UITextBorderStyleRoundedRect;
            adminTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            adminTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            
            [cell.contentView addSubview:adminTextField];
            
        }
        return cell;
    }else if(indexPath.row==1){
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 9, 280, 21)];
            firstLabel.text = @"-Enter username of desired admin";
            firstLabel.font = [UIFont fontWithName:@"ArialMT" size:15.0];
            firstLabel.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:firstLabel];
            
            UILabel *secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 280, 21)];
            secondLabel.text = @"-User must be member of group";
            secondLabel.font = [UIFont fontWithName:@"ArialMT" size:15.0];
            secondLabel.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:secondLabel];
            
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
            changeLabel.text = @"Change Admin";
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
        NSRange r = [adminTextField.text rangeOfCharacterFromSet:usernameCharacterSet];
        if (r.location != NSNotFound) {
            usernameGood = NO;
            //NSLog(@"the string contains illegal characters");
            errorMessage =[NSString stringWithFormat:@"%@ Username has invalid characters.", errorMessage];
        }
        
        //username is empty
        if(adminTextField.text.length==0){
            usernameGood = NO;
            errorMessage =[NSString stringWithFormat:@"%@ Username is empty.", errorMessage];
        }
        
        //username is too long
        if(adminTextField.text.length>15){
            usernameGood = NO;
            errorMessage =[NSString stringWithFormat:@"%@ Username is too long.", errorMessage];
        }
        
        //username is "Anonymous"
        NSString *lowerCaseUsername = [adminTextField.text lowercaseString];
        if([lowerCaseUsername isEqualToString:@"anonymous"]){
            usernameGood = NO;
            errorMessage =[NSString stringWithFormat:@"%@ Username cannot be Anonymous.", errorMessage];
        }
        
        //check uniqueness
        if(usernameGood==YES){
            progressAlert = [[UIAlertView alloc] initWithTitle:@"Updating..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [progressAlert show];
            
            //send proposed admin
            NSString *username = adminTextField.text;
            NSString *encodedUsername = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                              NULL,
                                                                                                              (__bridge CFStringRef) username,
                                                                                                              NULL,
                                                                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                              kCFStringEncodingUTF8));
            NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/changeGroupAdmin.php?groupID=%@&username=%@", groupID, encodedUsername];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
            adminConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
        }else{
            //make alert box
            UIAlertView *usernameAlert= [[UIAlertView alloc] initWithTitle:@"Unacceptable Username" message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [usernameAlert show];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    adminData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [adminData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    [self parseAdminData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    [self handleAdminFail];
}

-(void)parseAdminData{
    NSString *strData = [[NSString alloc]initWithData:adminData encoding:NSUTF8StringEncoding];
    strData = [strData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    if ([strData isEqualToString:@"1"]){
        progressAlert = [[UIAlertView alloc] initWithTitle:@"Cannot find user in the group." message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    }else{
        progressAlert = [[UIAlertView alloc] initWithTitle:@"Admin updated successfully." message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    }
    [progressAlert show];
    
}
-(void)handleAdminFail{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    progressAlert= [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [progressAlert show];
}

@end
