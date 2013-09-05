//
//  DICHOCreateAccountViewController.m
//  Dicho
//
//  Created by Tyler Droll on 12/20/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import "DICHOCreateAccountViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface DICHOCreateAccountViewController ()

@end

@implementation DICHOCreateAccountViewController
@synthesize usernameTextField;
@synthesize password1TextField;
@synthesize password2TextField;
@synthesize nameTextField;
@synthesize emailTextField;
@synthesize passwordMatchLabel;
@synthesize createAlert;
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
    //[_responseData appendData:data];
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

- (IBAction)checkUniqueUsername:(id)sender {
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
        NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/checkUsernameUniqueness2.php?proposedUsername=%@", encodedUsername];
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


- (IBAction)createButton:(id)sender {
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
    
    //passwords don't match
    if(![password1TextField.text isEqualToString:password2TextField.text]){
        errorMessage =[NSString stringWithFormat:@"%@ Passwords don't match.", errorMessage];
        infoGood = NO;
    }else{
        //password too short
        if(password1TextField.text.length<6){
            errorMessage =[NSString stringWithFormat:@"%@ Password is too short.", errorMessage];
            infoGood = NO;
        }
        //password too long
        if(password1TextField.text.length>16){
            errorMessage =[NSString stringWithFormat:@"%@ Password is too long.", errorMessage];
            infoGood = NO;
        }
        //password has invalid characters
        NSCharacterSet *passwordCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890`~!@#$%^&*()-_=+[{]}\\;:',<.>/?"];
        //no quotes
        passwordCharacterSet = [passwordCharacterSet invertedSet];
        NSRange r = [password1TextField.text rangeOfCharacterFromSet:passwordCharacterSet];
        if (r.location != NSNotFound) {
            infoGood = NO;
            errorMessage =[NSString stringWithFormat:@"%@ Password has invalid characters.", errorMessage];
        }
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

    //email is empty
    if(emailTextField.text.length==0){
        errorMessage =[NSString stringWithFormat:@"%@ E-mail address is empty.", errorMessage];
        infoGood=NO;
    }
    //email is too long
    if(emailTextField.text.length>40){
        errorMessage =[NSString stringWithFormat:@"%@ E-mail address is too long.", errorMessage];
        infoGood = NO;
    }
    //email is invalid?
    
    NSString *emailRegex = @"[A-Z0-9a-z!#$%'*+-/=?^_`{}~._]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if(![emailTest evaluateWithObject:emailTextField.text]){
        infoGood=NO;
        errorMessage =[NSString stringWithFormat:@"%@ E-mail address has bad form.", errorMessage];
    }

    
    if(infoGood==NO){
        createAlert= [[UIAlertView alloc] initWithTitle:@"Entries are not good" message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [createAlert show];
    }else{
        createAlert= [[UIAlertView alloc] initWithTitle:@"Creating..." message:errorMessage delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [createAlert show];
        //create account
        //http format textfields
        NSString *username = usernameTextField.text;
        NSString *encodedUsername = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                          NULL,
                                                                                                          (__bridge CFStringRef) username,
                                                                                                          NULL,
                                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                          kCFStringEncodingUTF8));
        NSString *password = password1TextField.text;
        NSString *encodedPassword = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                          NULL,
                                                                                                          (__bridge CFStringRef) password,
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
        NSString *email = emailTextField.text;
        NSString *encodedEmail = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                       NULL,
                                                                                                       (__bridge CFStringRef) email,
                                                                                                       NULL,
                                                                                                       (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                       kCFStringEncodingUTF8));
        //send php
        NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/createAccount.php?un=%@&pw=%@&name=%@&em=%@", encodedUsername, encodedPassword, encodedName, encodedEmail];
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
        createConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

-(void)parseCreateData{
    NSString *strData = [[NSString alloc] initWithData:createData encoding:NSUTF8StringEncoding];
    strData = [strData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([strData isEqualToString:@"1"]){
        [createAlert dismissWithClickedButtonIndex:0 animated:YES];
        createAlert= [[UIAlertView alloc] initWithTitle:@"Sorry, username is already taken..." message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [createAlert show];
    }else{
        [createAlert dismissWithClickedButtonIndex:0 animated:YES];
        createAlert= [[UIAlertView alloc] initWithTitle:@"Account created successfully." message:@"Please log in to select a profile picture and begin asking and answering dichos. Thank you for using Dicho. Enjoy!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [createAlert show];
    }
    

}
-(void)handleCreateFail{
    [createAlert dismissWithClickedButtonIndex:0 animated:YES];
    createAlert= [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [createAlert show];
}

- (IBAction)password1Changed:(id)sender {
    if([password1TextField.text isEqualToString:password2TextField.text]){
        passwordMatchLabel.text = @"Match!";
        passwordMatchLabel.textColor = [UIColor greenColor];
    }else{
        passwordMatchLabel.text = @"No match";
        passwordMatchLabel.textColor = [UIColor redColor];
    }
}

- (IBAction)password2Changed:(id)sender {
    if([password1TextField.text isEqualToString:password2TextField.text]){
        passwordMatchLabel.text = @"Match!";
        passwordMatchLabel.textColor = [UIColor greenColor];
    }else{
        passwordMatchLabel.text = @"No match";
        passwordMatchLabel.textColor = [UIColor redColor];
    }
}

@end
