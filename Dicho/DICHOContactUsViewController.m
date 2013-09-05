//
//  DICHOContactUsViewController.m
//  Dicho
//
//  Created by Tyler Droll on 9/3/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOContactUsViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface DICHOContactUsViewController ()

@end

@implementation DICHOContactUsViewController
@synthesize contactTextView;
@synthesize contactAlert;
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
    self.title = @"Contact Us";
    
    //give the textview a border
    contactTextView.layer.borderWidth = 1.0f;
    contactTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    contactTextView.layer.cornerRadius = 5;
    
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
        
        //text too long
        if(contactTextView.text.length>5000){
            
            UIAlertView *tooLongAlert = [[UIAlertView alloc] initWithTitle:@"Message too long" message:@"5000 character limit." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [tooLongAlert show];
            
        }else{
            contactAlert= [[UIAlertView alloc] initWithTitle:@"Sending..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [contactAlert show];
            
            NSString *cleanedMessage = [contactTextView.text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];

            NSString *encodedMessage = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                          NULL,
                                                                                                          (__bridge CFStringRef) cleanedMessage,
                                                                                                          NULL,
                                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                          kCFStringEncodingUTF8));
            
            NSString * post = [[NSString alloc] initWithFormat:@"&message=%@", encodedMessage];
            NSData * postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:NO];
            NSString * postLength = [NSString stringWithFormat:@"%d",[postData length]];
            NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.dichoapp.com/files/contactUs.php"]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:postData];
            contactConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
        }
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    contactData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [contactData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    [self parseContactData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    [self handleContactFail];
}



-(void)parseContactData{
    [contactAlert dismissWithClickedButtonIndex:0 animated:YES];
    contactAlert= [[UIAlertView alloc] initWithTitle:@"Sent!" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [contactAlert show];

}

-(void)handleContactFail{
    [contactAlert dismissWithClickedButtonIndex:0 animated:YES];
    contactAlert= [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [contactAlert show];
}

@end
