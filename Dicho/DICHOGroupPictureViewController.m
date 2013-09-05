//
//  DICHOGroupPictureViewController.m
//  Dicho
//
//  Created by Tyler Droll on 8/4/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOGroupPictureViewController.h"

@interface DICHOGroupPictureViewController ()

@end

@implementation DICHOGroupPictureViewController
@synthesize progressAlert;
@synthesize groupImageView;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)initWithGroupID:(NSString*)givenGroupID{
    self = [super init];
    if( !self) return nil;
    self.title = @"Picture";
    groupID = givenGroupID;
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
    groupImage = nil;
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
        return 110;
    }
    else return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0){
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            
            UILabel *changeLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, 11, 157, 21)];
            changeLabel.text = @"Select Picture";
            changeLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0];
            changeLabel.textColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0];
            changeLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:changeLabel];
            
        }
        return cell;
    }else if(indexPath.row==1){
        static NSString *CellIdentifier = @"textFieldCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            groupImageView = [[UIImageView alloc] initWithFrame:CGRectMake(105, 10, 90, 90)];
            groupImageView.backgroundColor = [UIColor lightGrayColor];
            groupImageView.contentMode = UIViewContentModeScaleAspectFill;
            groupImageView.clipsToBounds = YES;
            groupImageView.tag =1;
            [cell.contentView addSubview:groupImageView];
            
        }else{
            groupImageView = (UIImageView *)[cell.contentView viewWithTag:1];
        }
        groupImageView.image = groupImage;
        return cell;
    }else{
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            
            UILabel *changeLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, 11, 157, 21)];
            changeLabel.text = @"Change Picture";
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
    if(indexPath.row==0){
        UIImagePickerController * picker = [[UIImagePickerController alloc]init];
        picker.delegate=self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
    }else if(indexPath.row==2){
        if(groupImage!=nil){
            progressAlert= [[UIAlertView alloc] initWithTitle:@"Updating..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [progressAlert show];
            
            UIImage * image = groupImage;
            
            //resize image to fit more smoothly
            CGFloat widthFactor = image.size.width/120;
            CGFloat heightFactor = image.size.height/120;
            CGFloat scaleFactor;
            
            if(widthFactor<heightFactor)
                scaleFactor = widthFactor;
            else
                scaleFactor = heightFactor;
            
            CGSize desiredSize = CGSizeMake(image.size.width/scaleFactor, image.size.height/scaleFactor);
            UIGraphicsBeginImageContextWithOptions(desiredSize, NO, 0.0);
            [image drawInRect:CGRectMake(0,0,desiredSize.width,desiredSize.height)];
            UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            NSString *urlString = @"http://dichoapp.com/groupImages/uploadGroupImage.php";
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:urlString]];
            [request setHTTPMethod:@"POST"];
            [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
            [request setTimeoutInterval:15.0];
            
            NSString *boundary = @"---------------------------14737809831466499882746641449";
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
            [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
            
            NSMutableData *body = [NSMutableData data];
            NSData *imageData = UIImageJPEGRepresentation(newImage, 0.9);
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@.jpeg\"\r\n", groupID] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[NSData dataWithData:imageData]];
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [request setHTTPBody:body];
            imageConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        }
        
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    receivedImageData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedImageData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    [self parseImageData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    [self parseImageData];
}

-(void)parseImageData{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    progressAlert= [[UIAlertView alloc] initWithTitle:@"Picture updated successfully." message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [progressAlert show];

}

-(void)handleiImageFail{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    progressAlert= [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [progressAlert show];

}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
	groupImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [self.tableView reloadData];
}

@end
