//
//  DICHOCreateGroupViewController.m
//  Dicho
//
//  Created by Tyler Droll on 8/1/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOCreateGroupViewController.h"

@interface DICHOCreateGroupViewController ()

@end

@implementation DICHOCreateGroupViewController
@synthesize usernameTextField;
@synthesize nameTextField;
@synthesize createAlert;

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
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    prefs= [NSUserDefaults standardUserDefaults];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if(connection==uniqueConnection){
        uniqueData = [[NSMutableData alloc] init];
    }else if(connection==createConnection){
        createData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    if(connection==uniqueConnection){
        [uniqueData appendData:data];
    }else if(connection==createConnection){
        [createData appendData:data];
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
    if(connection==uniqueConnection){
        [self parseUniqueData];
    }else if(connection==createConnection){
        [self parseCreateData];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    if(connection==uniqueConnection){
        [self handleUniqueFail];
    }else if(connection==createConnection){
        [self handleCreateFail];
    }
}


- (IBAction)checkUsernameUniqueness:(id)sender {
    NSString *uniquenessMessage = @"";
    bool usernameGood = YES;
    
    //username has bad characters
    NSCharacterSet *usernameCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"];
    usernameCharacterSet = [usernameCharacterSet invertedSet];
    NSRange r = [usernameTextField.text rangeOfCharacterFromSet:usernameCharacterSet];
    if (r.location != NSNotFound) {
        usernameGood = NO;
        uniquenessMessage =[NSString stringWithFormat:@"%@ Username has invalid characters.", uniquenessMessage];
    }
    
    //username is empty
    if(usernameTextField.text.length==0){
        usernameGood = NO;
        uniquenessMessage =[NSString stringWithFormat:@"%@ Username is empty.", uniquenessMessage];
    }
    
    //username is too long
    if(usernameTextField.text.length>15){
        usernameGood = NO;
        uniquenessMessage =[NSString stringWithFormat:@"%@ Username is too long.", uniquenessMessage];
    }
    
    //username is "Anonymous"
    NSString *lowerCaseUsername = [usernameTextField.text lowercaseString];
    if([lowerCaseUsername isEqualToString:@"anonymous"]){
        usernameGood = NO;
        uniquenessMessage =[NSString stringWithFormat:@"%@ Username cannot be Anonymous.", uniquenessMessage];
    }
    
    //check uniqueness
    if(usernameGood==YES){
        createAlert= [[UIAlertView alloc] initWithTitle:@"Checking..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [createAlert show];
        //perform uniqueness check
        NSString *username = usernameTextField.text;
        NSString *encodedUsername = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                          NULL,
                                                                                                          (__bridge CFStringRef) username,
                                                                                                          NULL,
                                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                          kCFStringEncodingUTF8));
        NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/checkGroupUsernameUniqueness.php?proposedUsername=%@", encodedUsername];
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
        uniqueConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }else{
        //make alert box
        createAlert= [[UIAlertView alloc] initWithTitle:@"Uniqueness Check" message:uniquenessMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [createAlert show];
    }
    
    
}

-(void)parseUniqueData{
    NSString *strData = [[NSString alloc]initWithData:uniqueData encoding:NSUTF8StringEncoding];
    strData = [strData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [createAlert dismissWithClickedButtonIndex:0 animated:YES];
    if ([strData isEqualToString:@"1"]){
        createAlert= [[UIAlertView alloc] initWithTitle:@"Username is unique!" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    }else if([strData isEqualToString:@"0"]){
        createAlert= [[UIAlertView alloc] initWithTitle:@"Sorry, username is already taken..." message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    }else{
        createAlert= [[UIAlertView alloc] initWithTitle:@"Error." message:@"Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    }
    [createAlert show];
}
-(void)handleUniqueFail{
    [createAlert dismissWithClickedButtonIndex:0 animated:YES];
    createAlert= [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [createAlert show];
}

- (IBAction)createGroup:(id)sender {
    NSString *errorMessage = @"";
    bool infoGood = YES;
    bool usernameGood = YES;
    
    
    //username has bad characters
    NSCharacterSet *usernameCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"];
    usernameCharacterSet = [usernameCharacterSet invertedSet];
    NSRange r = [usernameTextField.text rangeOfCharacterFromSet:usernameCharacterSet];
    if (r.location != NSNotFound) {
        infoGood = NO;
        usernameGood = NO;
        errorMessage =[NSString stringWithFormat:@"%@ Username has invalid characters.", errorMessage];
        
    }
    
    //username is empty
    if(usernameTextField.text.length==0){
        infoGood = NO;
        usernameGood = NO;
        errorMessage =[NSString stringWithFormat:@"%@ Username is empty.", errorMessage];
    }
    
    //username is too long
    if(usernameTextField.text.length>15){
        usernameGood = NO;
        errorMessage =[NSString stringWithFormat:@"%@ Username is too long.", errorMessage];
        infoGood = NO;
    }
    
    //username is "Anonymous"
    NSString *lowerCaseUsername = [usernameTextField.text lowercaseString];
    if([lowerCaseUsername isEqualToString:@"anonymous"]){
        usernameGood = NO;
        infoGood = NO;
        errorMessage =[NSString stringWithFormat:@"%@ Username cannot be Anonymous.", errorMessage];
    }
    
    
    //name is empty
    if(nameTextField.text.length==0){
        errorMessage =[NSString stringWithFormat:@"%@ Name is empty.", errorMessage];
        infoGood = NO;
    }
    //name too long
    if(nameTextField.text.length>20){
        errorMessage =[NSString stringWithFormat:@"%@ Name is too long.", errorMessage];
        infoGood = NO;
    }
    //name has invalid characters
    NSCharacterSet *nameCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-' "];
    nameCharacterSet = [nameCharacterSet invertedSet];
    NSRange n = [nameTextField.text rangeOfCharacterFromSet:nameCharacterSet];
    if (n.location != NSNotFound) {
        infoGood = NO;
        errorMessage =[NSString stringWithFormat:@"%@ Name has invalid characters.", errorMessage];
    }
    
    
    if(infoGood==NO){
        createAlert= [[UIAlertView alloc] initWithTitle:@"Entries are not good" message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [createAlert show];
    }else{
        createAlert= [[UIAlertView alloc] initWithTitle:@"Creating..." message:errorMessage delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [createAlert show];
        //do account submit with encoded fields
        NSString *username = usernameTextField.text;
        NSString *encodedUsername = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                          NULL,
                                                                                                          (__bridge CFStringRef) username,
                                                                                                          NULL,
                                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                          kCFStringEncodingUTF8));
        NSString *name = nameTextField.text;
        NSString *encodedName = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                      NULL,
                                                                                                      (__bridge CFStringRef) name,
                                                                                                      NULL,
                                                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                      kCFStringEncodingUTF8));
        //send php
        NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/createGroup.php?un=%@&name=%@&userID=%@", encodedUsername, encodedName, [prefs objectForKey:@"userID"]];
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 30.0];
        createConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

-(void)parseCreateData{
    NSString *returnedString = [[NSString alloc]initWithData:createData encoding:NSUTF8StringEncoding];
    returnedString = [returnedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([returnedString isEqualToString:@"1"]){
        [createAlert dismissWithClickedButtonIndex:0 animated:YES];
        createAlert= [[UIAlertView alloc] initWithTitle:@"Sorry, username is already taken..." message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [createAlert show];
        //not unique
        
    }else{
        [createAlert dismissWithClickedButtonIndex:0 animated:YES];
        createAlert= [[UIAlertView alloc] initWithTitle:@"Group created successfully." message:@"You are the default admin. Please go to group settings to set a profile picture. You can also accept join requests and remove unwanted members here." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [createAlert show];
    }
    
}
-(void)handleCreateFail{
    [createAlert dismissWithClickedButtonIndex:0 animated:YES];
    createAlert= [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [createAlert show];
}

@end
