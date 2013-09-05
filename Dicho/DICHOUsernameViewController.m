//
//  DICHOUsernameViewController.m
//  Dicho
//
//  Created by Tyler Droll on 6/3/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOUsernameViewController.h"

@interface DICHOUsernameViewController ()

@end

@implementation DICHOUsernameViewController
@synthesize usernameAlert;
@synthesize usernameLabel;
@synthesize usernameTextField;
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
    self.title = @"Username";
    prefs = [NSUserDefaults standardUserDefaults];
    usernameLabel.text = [prefs objectForKey:@"username"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section==1&&indexPath.row==1){
        NSString *uniquenessMessage = @"";
        bool usernameGood = YES;
        
        //username has bad characters
        NSCharacterSet *usernameCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"];
        usernameCharacterSet = [usernameCharacterSet invertedSet];
        NSRange r = [usernameTextField.text rangeOfCharacterFromSet:usernameCharacterSet];
        if (r.location != NSNotFound) {
            usernameGood = NO;
            //NSLog(@"the string contains illegal characters");
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
            usernameAlert= [[UIAlertView alloc] initWithTitle:@"Checking..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [usernameAlert show];
            
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
            firstUniqueConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
        }else{
            //make alert box
        usernameAlert= [[UIAlertView alloc] initWithTitle:@"Uniqueness Check" message:uniquenessMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [usernameAlert show];
        }
    }else if(indexPath.section==1&&indexPath.row==3){
        NSString *uniquenessMessage = @"";
        bool usernameGood = YES;
        
        //username has bad characters
        NSCharacterSet *usernameCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"];
        usernameCharacterSet = [usernameCharacterSet invertedSet];
        NSRange r = [usernameTextField.text rangeOfCharacterFromSet:usernameCharacterSet];
        if (r.location != NSNotFound) {
            usernameGood = NO;
            //NSLog(@"the string contains illegal characters");
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
        
        //submit username for change
        if(usernameGood==YES){
            usernameAlert= [[UIAlertView alloc] initWithTitle:@"Updating..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [usernameAlert show];
            
            //perform uniqueness check
            NSString *username = usernameTextField.text;
            NSString *encodedUsername = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                              NULL,
                                                                                                              (__bridge CFStringRef) username,
                                                                                                              NULL,
                                                                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                              kCFStringEncodingUTF8));
            NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/changeUsername2.php?username=%@&userID=%@", encodedUsername, [prefs objectForKey:@"userID"]];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
            usernameConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
        }else{
            //make alert box
            usernameAlert= [[UIAlertView alloc] initWithTitle:@"Unacceptable username" message:uniquenessMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [usernameAlert show];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if(connection==firstUniqueConnection){
        firstUniqueData = [[NSMutableData alloc] init];
    }else if(connection==usernameConnection){
        usernameData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    //[_responseData appendData:data];
    if(connection==firstUniqueConnection){
        [firstUniqueData appendData:data];
    }else if(connection==usernameConnection){
        [usernameData appendData:data];
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
    if(connection==firstUniqueConnection){
        [self parseFirstUniqueData];
    }else if(connection==usernameConnection){
        [self parseUsernameData];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    if(connection==firstUniqueConnection){
        [self handleFirstUniqueFail];
    }else if(connection==usernameConnection){
        [self handleUsernameFail];
    }
}

-(void)parseFirstUniqueData{
    NSString *strData = [[NSString alloc]initWithData:firstUniqueData encoding:NSUTF8StringEncoding];
    [usernameAlert dismissWithClickedButtonIndex:0 animated:YES];
    if ([strData isEqualToString:@"1"]){
        usernameAlert= [[UIAlertView alloc] initWithTitle:@"Username is unique!" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    }else if([strData isEqualToString:@"0"]){
        usernameAlert= [[UIAlertView alloc] initWithTitle:@"Sorry, username is already taken..." message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    }else{
        usernameAlert= [[UIAlertView alloc] initWithTitle:@"Error." message:@"Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    }
    [usernameAlert show];
}

-(void)handleFirstUniqueFail{
    [usernameAlert dismissWithClickedButtonIndex:0 animated:YES];
    usernameAlert= [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [usernameAlert show];
}


-(void)parseUsernameData{
    NSString *strData = [[NSString alloc]initWithData:usernameData encoding:NSUTF8StringEncoding];
    strData = [strData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([strData isEqualToString:@"1"]){
        [usernameAlert dismissWithClickedButtonIndex:0 animated:YES];
        usernameAlert= [[UIAlertView alloc] initWithTitle:@"Sorry, username is already taken..." message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [usernameAlert show];
    }else{
        //update prefs and namelabel
        [prefs setObject:usernameTextField.text forKey:@"username"];
        usernameLabel.text = usernameTextField.text;
        [usernameAlert dismissWithClickedButtonIndex:0 animated:YES];
        usernameAlert= [[UIAlertView alloc] initWithTitle:@"Username updated successfully." message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [usernameAlert show];
    }
    
}

-(void)handleUsernameFail{
    [usernameAlert dismissWithClickedButtonIndex:0 animated:YES];
    usernameAlert= [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [usernameAlert show];
}
@end
