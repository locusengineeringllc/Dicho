//
//  DICHOGroupNameViewController.m
//  Dicho
//
//  Created by Tyler Droll on 8/3/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOGroupNameViewController.h"

@interface DICHOGroupNameViewController ()

@end

@implementation DICHOGroupNameViewController
@synthesize nameTextField;
@synthesize progressAlert;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)initWithGroupID:(NSString*)givenGroupID name:(NSString*)givenName{
    self = [super init];
    if( !self) return nil;
    self.title = @"Name";
    groupID = givenGroupID;
    originalName = givenName;
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
        return 85;
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
            
            nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 7, 270, 30)];
            nameTextField.font = [UIFont fontWithName:@"ArialMT" size:14.0];
            nameTextField.textAlignment = NSTextAlignmentLeft;
            nameTextField.delegate = self;
            nameTextField.text = originalName;
            nameTextField.borderStyle = UITextBorderStyleRoundedRect;
            nameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;

            [cell.contentView addSubview:nameTextField];
            
        }
        return cell;
    }else if(indexPath.row==1){
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, 228, 44)];
            firstLabel.numberOfLines = 2;
            firstLabel.text = @"-Only letters, numbers, hyphens, apostrophes, and spaces";
            firstLabel.font = [UIFont fontWithName:@"ArialMT" size:15.0];
            firstLabel.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:firstLabel];
            
            UILabel *secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 51, 209, 21)];
            secondLabel.text = @"-Max of 20 characters";
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
            changeLabel.text = @"Change Name";
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
            UIAlertView *namesAlert= [[UIAlertView alloc] initWithTitle:@"Unacceptable Name" message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [namesAlert show];
        }else{
            progressAlert= [[UIAlertView alloc] initWithTitle:@"Updating..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [progressAlert show];
            NSString *name = nameTextField.text;
            NSString *encodedName = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                          NULL,
                                                                                                          (__bridge CFStringRef) name,
                                                                                                          NULL,
                                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                          kCFStringEncodingUTF8));
            
            //send php
            NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/changeGroupName.php?groupID=%@&name=%@", groupID, encodedName];
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
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *namesAlert= [[UIAlertView alloc] initWithTitle:@"Name updated successfully." message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [namesAlert show];
}
-(void)handleNameFail{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    progressAlert= [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [progressAlert show];

}

@end
