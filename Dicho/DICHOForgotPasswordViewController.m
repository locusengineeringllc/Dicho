//
//  DICHOForgotPasswordViewController.m
//  Dicho
//
//  Created by Tyler Droll on 12/31/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import "DICHOForgotPasswordViewController.h"

@interface DICHOForgotPasswordViewController ()

@end

@implementation DICHOForgotPasswordViewController
@synthesize usernameTextField;
@synthesize forgotPasswordAlert;
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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==1){
        forgotPasswordAlert= [[UIAlertView alloc] initWithTitle:@"Sending..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [forgotPasswordAlert show];
        NSString *username = usernameTextField.text;
        NSString *encodedUsername = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                          NULL,
                                                                                                          (__bridge CFStringRef) username,
                                                                                                          NULL,
                                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                          kCFStringEncodingUTF8));
        NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/forgotPassword.php?username=%@", encodedUsername];
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
        fpConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    fpData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [fpData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    [self parseFPData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    [self handleFPFail];
}

-(void)parseFPData{
    NSString *strData = [[NSString alloc]initWithData:fpData encoding:NSUTF8StringEncoding];
    strData = [strData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [forgotPasswordAlert dismissWithClickedButtonIndex:0 animated:YES];
    if([strData isEqualToString:@"1"]){
        forgotPasswordAlert= [[UIAlertView alloc] initWithTitle:@"Username not found." message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [forgotPasswordAlert show];
    }else{
        forgotPasswordAlert= [[UIAlertView alloc] initWithTitle:@"Password Recovery" message:[NSString stringWithFormat:@"Password sent to %@. It might be directed to your spam folder.", strData] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [forgotPasswordAlert show];
    }
}
-(void)handleFPFail{
    [forgotPasswordAlert dismissWithClickedButtonIndex:0 animated:YES];
    forgotPasswordAlert= [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [forgotPasswordAlert show];
}
@end
