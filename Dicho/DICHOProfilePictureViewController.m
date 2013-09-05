//
//  DICHOProfilePictureViewController.m
//  Dicho
//
//  Created by Tyler Droll on 12/29/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import "DICHOProfilePictureViewController.h"

@interface DICHOProfilePictureViewController ()

@end

@implementation DICHOProfilePictureViewController
@synthesize currentPicture;
@synthesize selectedPicture;
@synthesize pictureAlert;
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

    currentPicture.image = nil;

}

-(void)viewDidAppear:(BOOL)animated{
    NSURL * imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://dichoapp.com/userImages/%@.jpeg", [prefs objectForKey:@"userID"]]];
    NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
    
    if(imageData != nil){
        UIImage * image = [UIImage imageWithData:imageData];
        
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
        currentPicture.image = newImage;
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==1&&indexPath.row==0){
        UIImagePickerController * picker = [[UIImagePickerController alloc]init];
        picker.delegate=self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
    }else if(indexPath.section==2){
        //check if has selected image
        if(selectedPicture.image==nil){
            pictureAlert= [[UIAlertView alloc] initWithTitle:@"No Picture Selected" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [pictureAlert show];
        }else{
            pictureAlert= [[UIAlertView alloc] initWithTitle:@"Updating..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [pictureAlert show];
            
            
            UIImage * image = selectedPicture.image;
            
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
            

            NSString *urlString = @"http://dichoapp.com/userImages/uploadUserImage.php";
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
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@.jpeg\"\r\n", [prefs objectForKey:@"userID"]] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[NSData dataWithData:imageData]];
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [request setHTTPBody:body];
            pictureConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
        }
    }
        
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    pictureData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [pictureData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    [self parsePictureData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    [self handlePictureFail];
}

-(void)parsePictureData{
    NSString *strData = [[NSString alloc]initWithData:pictureData encoding:NSUTF8StringEncoding];
    strData = [strData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([strData isEqualToString:@"1"]){
        //update pictureView
        currentPicture.image = selectedPicture.image;
        [pictureAlert dismissWithClickedButtonIndex:0 animated:YES];
        pictureAlert= [[UIAlertView alloc] initWithTitle:@"Picture updated successfully." message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    }else{
        [pictureAlert dismissWithClickedButtonIndex:0 animated:YES];
        pictureAlert= [[UIAlertView alloc] initWithTitle:@"Error updating picture." message:@"Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    }
    [pictureAlert show];
}
-(void)handlePictureFail{
    [pictureAlert dismissWithClickedButtonIndex:0 animated:YES];
    pictureAlert= [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [pictureAlert show];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
	selectedPicture.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
}

@end
