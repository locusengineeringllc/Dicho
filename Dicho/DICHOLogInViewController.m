//
//  DICHOLogInViewController.m
//  Dicho
//
//  Created by Tyler Droll on 10/31/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import "DICHOLogInViewController.h"
#import <Parse/Parse.h>

@interface DICHOLogInViewController ()

@end

@implementation DICHOLogInViewController
@synthesize logInTable;
@synthesize loginAlert;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    prefs= [NSUserDefaults standardUserDefaults];


	// Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
            return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==0&&indexPath.row== 0){
        static NSString *CellIdentifier = @"usernameCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        UILabel *usernameLabel = (UILabel *) [cell viewWithTag:1];
        [usernameLabel setText:@"Username"];
        return cell;
    }else if(indexPath.section==0&&indexPath.row==1) {
        static NSString *Cell2Identifier = @"passwordCell";
        UITableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:Cell2Identifier];
        UILabel *passwordLabel = (UILabel *) [cell2 viewWithTag:1];
        [passwordLabel setText:@"Password"];
        return cell2;
    
    }else if(indexPath.section==1&&indexPath.row== 0){
        static NSString *Cell3Identifier = @"logInButtonCell";
        UITableViewCell *cell3 = [tableView dequeueReusableCellWithIdentifier:Cell3Identifier];
        UILabel *logInLabel = (UILabel *) [cell3 viewWithTag:1];
        [logInLabel setText:@"Log In"];
        return cell3;
    }else{
        static NSString *Cell3Identifier = @"logInButtonCell";
        UITableViewCell *cell3 = [tableView dequeueReusableCellWithIdentifier:Cell3Identifier];
        UILabel *logInLabel = (UILabel *) [cell3 viewWithTag:1];
        [logInLabel setText:@"Forgot Password"];
        return cell3;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==1&&indexPath.row==0){
        
        //get username text
        NSIndexPath *usernamePath = [NSIndexPath indexPathForRow:0 inSection:0];
        UITableViewCell *usernameCell = [tableView cellForRowAtIndexPath:usernamePath];
        UITextField *usernameField = (UITextField *) [usernameCell viewWithTag:2];
        username = usernameField.text;
        NSString *encodedUsername = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                          NULL,
                                                                                                          (__bridge CFStringRef) username,
                                                                                                          NULL,
                                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                          kCFStringEncodingUTF8));
        
       
        //get password text
        NSIndexPath *passwordPath = [NSIndexPath indexPathForRow:1 inSection:0];
        UITableViewCell *passwordCell = [tableView cellForRowAtIndexPath:passwordPath];
        UITextField *passwordField = (UITextField *) [passwordCell viewWithTag:2];
        password = passwordField.text;
        NSString *encodedPassword = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                          NULL,
                                                                                                          (__bridge CFStringRef) password,
                                                                                                          NULL,
                                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                          kCFStringEncodingUTF8));
        
        loginAlert = [[UIAlertView alloc] initWithTitle:@"Logging in..." message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
        [loginAlert show];
        
        //try to log in with givens
        NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/LogIn.php?un=%@&pw=%@", encodedUsername, encodedPassword];
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
        loginConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        

    }else if(indexPath.section==1&&indexPath.row==1){
        [self performSegueWithIdentifier:@"logInToForgotPassword" sender:self];
    }
    
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    //_responseData = [[NSMutableData alloc] init];
    if(connection==loginConnection){
        loginData = [[NSMutableData alloc] init];
    }else if(connection==userInfoConnection){
        userInfoData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    //[_responseData appendData:data];
    if(connection==loginConnection){
        [loginData appendData:data];
    }else if(connection==userInfoConnection){
        [userInfoData appendData:data];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    if(connection==loginConnection){
        [self handleGoodLogin];
    }else if(connection==userInfoConnection){
        [self handleGoodUserInfo];
    }   
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    if(connection==loginConnection){
        [self handleLoginFail];
    }else if(connection==userInfoConnection){
        [self handleUserInfoFail];
    }
}

-(void)handleGoodLogin{
    NSString *logInSuccess = [[NSString alloc] initWithData:loginData encoding: NSUTF8StringEncoding];
    
    if ([logInSuccess isEqualToString:@"\n1"]){
        //NSLog(@"log in successful");
        NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/getAccountInfoFromUsername.php?un=%@", username];
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
        userInfoConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }else if([logInSuccess isEqualToString:@"\n2"]){
        //NSLog(@"wrong password!");
        [loginAlert dismissWithClickedButtonIndex:0 animated:YES];
        loginAlert= [[UIAlertView alloc] initWithTitle:@"Wrong password!" message:@"Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [loginAlert show];
    }else if([logInSuccess isEqualToString:@"\n3"]){
        //NSLog(@"username not found");
        [loginAlert dismissWithClickedButtonIndex:0 animated:YES];
        loginAlert= [[UIAlertView alloc] initWithTitle:@"Username not found!" message:@"Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [loginAlert show];
    }
}
-(void)handleLoginFail{
    [loginAlert dismissWithClickedButtonIndex:0 animated:YES];
    loginAlert = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [loginAlert show];
}

-(void)handleGoodUserInfo{
    NSString *strResult = [[NSString alloc] initWithData:userInfoData encoding: NSUTF8StringEncoding];
    strResult = [strResult stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSArray *userInfoStringComponents = [strResult componentsSeparatedByString:@"|"];
    
    [prefs setObject:[userInfoStringComponents objectAtIndex:0] forKey:@"userID"];
    [prefs setObject:[userInfoStringComponents objectAtIndex:1] forKey:@"name"];
    [prefs setObject:[userInfoStringComponents objectAtIndex:2] forKey:@"username"];
    [prefs setObject:[userInfoStringComponents objectAtIndex:3] forKey:@"password"];
    [prefs setObject:[userInfoStringComponents objectAtIndex:4] forKey:@"email"];
    [prefs setObject:@"yes" forKey:@"loggedIn"];
    [prefs setObject:@"yes" forKey:@"firstTimeToDicho"];
    [prefs setObject:@"yes" forKey:@"firstTimeToSubmit"];
    [prefs setObject:@"yes" forKey:@"firstTimeToSearch"];
    [prefs setObject:@"yes" forKey:@"firstTimeToHome"];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:[NSString stringWithFormat:@"c%@c", [prefs objectForKey:@"userID"]] forKey:@"channels"];
    [currentInstallation saveInBackground];
    [prefs setObject:@"1" forKey:@"hasSetPushChannel"];
    
    [loginAlert dismissWithClickedButtonIndex:0 animated:YES];
    [self.navigationController popToRootViewControllerAnimated:TRUE];
    
}

-(void)handleUserInfoFail{
    [loginAlert dismissWithClickedButtonIndex:0 animated:YES];
    loginAlert = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [loginAlert show];
}

@end
