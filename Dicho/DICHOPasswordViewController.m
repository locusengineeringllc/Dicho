//
//  DICHOPasswordViewController.m
//  Dicho
//
//  Created by Tyler Droll on 12/29/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import "DICHOPasswordViewController.h"

@interface DICHOPasswordViewController ()

@end

@implementation DICHOPasswordViewController
@synthesize currentPasswordTextField;
@synthesize proposedPassword1TextField;
@synthesize proposedPassword2TextField;
@synthesize matchLabel;
@synthesize passwordAlert;
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==2){
        NSString *errorMessage = @"";
        bool proposedPasswordGood = YES;
        //if current password is wrong
        if(![currentPasswordTextField.text isEqualToString:[prefs objectForKey:@"password"]]){
            proposedPasswordGood=NO;
            errorMessage =[NSString stringWithFormat:@"%@ Incorrect current password.", errorMessage];
        }
        
        //passwords don't match
        if(![proposedPassword1TextField.text isEqualToString:proposedPassword2TextField.text]){
            errorMessage =[NSString stringWithFormat:@"%@ Proposed passwords don't match.", errorMessage];
            proposedPasswordGood = NO;
        }else{
            //password too short
            if(proposedPassword1TextField.text.length<6){
                errorMessage =[NSString stringWithFormat:@"%@ Proposed password is too short.", errorMessage];
                proposedPasswordGood = NO;
            }
            //password too long
            if(proposedPassword1TextField.text.length>16){
                errorMessage =[NSString stringWithFormat:@"%@ Proposed password is too long.", errorMessage];
                proposedPasswordGood = NO;
            }
            //password has invalid characters
            NSCharacterSet *passwordCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890`~!@#$%^&*()-_=+[{]}\\;:',<.>/?"];
            //no quotes
            passwordCharacterSet = [passwordCharacterSet invertedSet];
            NSRange r = [proposedPassword1TextField.text rangeOfCharacterFromSet:passwordCharacterSet];
            if (r.location != NSNotFound) {
                proposedPasswordGood = NO;
                errorMessage =[NSString stringWithFormat:@"%@ Proposed password has invalid characters.", errorMessage];
            }
        }
        if(proposedPasswordGood==YES){
            passwordAlert= [[UIAlertView alloc] initWithTitle:@"Updating..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [passwordAlert show];
            NSString *password = proposedPassword1TextField.text;
            NSString *encodedPassword = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                                         NULL,
                                                                                                                         (__bridge CFStringRef) password,
                                                                                                                         NULL,
                                                                                                                         (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                                         kCFStringEncodingUTF8));
            NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/changePassword.php?userID=%@&password=%@", [prefs objectForKey:@"userID"], encodedPassword];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
            passwordConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];            
        }else{
            passwordAlert= [[UIAlertView alloc] initWithTitle:@"Password entries are not good" message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [passwordAlert show];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    passwordData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [passwordData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    [self parsePasswordData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    [self handlePasswordFail];
}
-(void)parsePasswordData{
    NSString *strData = [[NSString alloc]initWithData:passwordData encoding:NSUTF8StringEncoding];
    strData = [strData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([strData isEqualToString:@"1"]){
        //update prefs and namelabel
        [prefs setObject:proposedPassword1TextField.text forKey:@"password"];
        [passwordAlert dismissWithClickedButtonIndex:0 animated:YES];
        passwordAlert= [[UIAlertView alloc] initWithTitle:@"Password updated successfully." message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    }else{
        [passwordAlert dismissWithClickedButtonIndex:0 animated:YES];
        passwordAlert= [[UIAlertView alloc] initWithTitle:@"Error updating password." message:@"Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    }
    [passwordAlert show];
}
-(void)handlePasswordFail{
    [passwordAlert dismissWithClickedButtonIndex:0 animated:YES];
    passwordAlert= [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [passwordAlert show];

}

- (IBAction)proposedPassword1Changed:(id)sender {
    if([proposedPassword1TextField.text isEqualToString:proposedPassword2TextField.text]){
        matchLabel.text = @"Match!";
        matchLabel.textColor = [UIColor greenColor];
    }else{
        matchLabel.text = @"No match";
        matchLabel.textColor = [UIColor redColor];
    }
}

- (IBAction)proposedPassword2Changed:(id)sender {
    if([proposedPassword1TextField.text isEqualToString:proposedPassword2TextField.text]){
        matchLabel.text = @"Match!";
        matchLabel.textColor = [UIColor greenColor];
    }else{
        matchLabel.text = @"No match";
        matchLabel.textColor = [UIColor redColor];
    }
}
@end
