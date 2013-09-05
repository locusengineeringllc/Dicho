//
//  DICHOEmailAddressViewController.m
//  Dicho
//
//  Created by Tyler Droll on 12/29/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import "DICHOEmailAddressViewController.h"

@interface DICHOEmailAddressViewController ()

@end

@implementation DICHOEmailAddressViewController
@synthesize emailLabel;
@synthesize emailTextField;
@synthesize emailAlert;
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
    emailLabel.text = [prefs objectForKey:@"email"];
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
        bool emailGood = YES;
        
        //email is empty
        if(emailTextField.text.length==0){
            errorMessage =[NSString stringWithFormat:@"%@ E-mail address is empty.", errorMessage];
            emailGood=NO;
        }
        //email is too long
        if(emailTextField.text.length>40){
            errorMessage =[NSString stringWithFormat:@"%@ E-mail address is too long.", errorMessage];
            emailGood = NO;
        }
        //email is invalid?
        NSString *emailRegex = @"[A-Z0-9a-z!#$%'*+-/=?^_`{}~._]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        if(![emailTest evaluateWithObject:emailTextField.text]){
            emailGood=NO;
            errorMessage =[NSString stringWithFormat:@"%@ E-mail address has bad form.", errorMessage];
        }
        if(emailGood==YES){
            emailAlert= [[UIAlertView alloc] initWithTitle:@"Updating..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [emailAlert show];
            //send email
            NSString *email = emailTextField.text;
            NSString *encodedEmail = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                           NULL,
                                                                                                           (__bridge CFStringRef) email,
                                                                                                           NULL,
                                                                                                           (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                           kCFStringEncodingUTF8));
            NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/changeEmail.php?userID=%@&email=%@", [prefs objectForKey:@"userID"], encodedEmail];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
            emailConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        }else{
            emailAlert= [[UIAlertView alloc] initWithTitle:@"E-mail invalid." message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [emailAlert show];
        }

    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    emailData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [emailData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    [self parseEmailData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    [self handleEmailFail];
}

-(void)parseEmailData{
    NSString *strData = [[NSString alloc]initWithData:emailData encoding:NSUTF8StringEncoding];
    strData = [strData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([strData isEqualToString:@"1"]){
        //update prefs and namelabel
        [prefs setObject:emailTextField.text forKey:@"email"];
        emailLabel.text = emailTextField.text;
        [emailAlert dismissWithClickedButtonIndex:0 animated:YES];
        emailAlert= [[UIAlertView alloc] initWithTitle:@"E-mail updated successfully." message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    }else{
        [emailAlert dismissWithClickedButtonIndex:0 animated:YES];
        emailAlert= [[UIAlertView alloc] initWithTitle:@"Error updating e-mail." message:@"Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    }
    [emailAlert show];
}
-(void)handleEmailFail{
    [emailAlert dismissWithClickedButtonIndex:0 animated:YES];
    emailAlert= [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [emailAlert show];

}
@end
