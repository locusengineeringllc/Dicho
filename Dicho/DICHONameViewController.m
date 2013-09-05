//
//  DICHONameViewController.m
//  Dicho
//
//  Created by Tyler Droll on 12/29/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import "DICHONameViewController.h"

@interface DICHONameViewController ()

@end

@implementation DICHONameViewController
@synthesize namesAlert;
@synthesize nameTextField;
@synthesize nameLabel;
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

    nameLabel.text = [prefs objectForKey:@"name"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section==1&&indexPath.row==2){
        NSString *errorMessage = @"";
        bool infoGood = YES;
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
            namesAlert= [[UIAlertView alloc] initWithTitle:@"Unacceptable Name" message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [namesAlert show];
        }else{
            namesAlert= [[UIAlertView alloc] initWithTitle:@"Updating..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [namesAlert show];
            NSString *name = nameTextField.text;
            NSString *encodedName = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                          NULL,
                                                                                                          (__bridge CFStringRef) name,
                                                                                                          NULL,
                                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                          kCFStringEncodingUTF8));
            
            //send php
            NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/changeName.php?userID=%@&name=%@", [prefs objectForKey:@"userID"], encodedName];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
            nameConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        }
    }
        
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    nameData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [nameData appendData:data];    
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    [self parseNameData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    [self handleNameFail];
}

-(void)parseNameData{
    NSString *strData = [[NSString alloc]initWithData:nameData encoding:NSUTF8StringEncoding];
    strData = [strData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([strData isEqualToString:@"1"]){
        //update prefs and namelabel
        [prefs setObject:nameTextField.text forKey:@"name"];
        nameLabel.text = nameTextField.text;
        [namesAlert dismissWithClickedButtonIndex:0 animated:YES];
        namesAlert= [[UIAlertView alloc] initWithTitle:@"Name updated successfully." message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    }else{
        [namesAlert dismissWithClickedButtonIndex:0 animated:YES];
        namesAlert= [[UIAlertView alloc] initWithTitle:@"Error updating name." message:@"Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    }
    [namesAlert show];
}
-(void)handleNameFail{
    [namesAlert dismissWithClickedButtonIndex:0 animated:YES];
    namesAlert= [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [namesAlert show];
}

@end
