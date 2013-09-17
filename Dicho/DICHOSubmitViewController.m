//
//  DICHOSubmitViewController.m
//  Dicho
//
//  Created by Tyler Droll on 9/22/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import "DICHOSubmitViewController.h"
#import "QuartzCore/CALayer.h"

@interface DICHOSubmitViewController ()

@end

@implementation DICHOSubmitViewController
@synthesize typeQuestion;
@synthesize characterLabel;
@synthesize submitButton;
@synthesize anonymousBar;
@synthesize navigationBar;
@synthesize firstAnswerTextField;
@synthesize secondAnswerTextField;
@synthesize textField1Label;
@synthesize textField2Label;
@synthesize selectedImage;
@synthesize removePictureButton;
@synthesize isAnonymous;
@synthesize hasPicture;
@synthesize submitAlert;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) viewDidAppear:(BOOL)animated{
    NSString *loginStatus = [prefs objectForKey:@"loggedIn"];
    NSString *firstTimeStatus = [prefs objectForKey:@"firstTimeToSubmit"];

    if([loginStatus isEqualToString:@"no"]){
        [self.tabBarController setSelectedIndex:4];
    }else if([firstTimeStatus isEqualToString:@"yes"]){
        [self clearButton:self];
        [prefs setObject:@"no" forKey:@"firstTimeToSubmit"];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    prefs= [NSUserDefaults standardUserDefaults];

	// Do any additional setup after loading the view.
    [self resignFirstResponder];
    [typeQuestion becomeFirstResponder];
    submitButton.enabled = NO;
    navigationBar.tintColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0];
    
    anonymousBar.tintColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    [removePictureButton setImage:nil forState:UIControlStateNormal];
    removePictureButton.enabled = NO;
    isAnonymous = 0;
    hasPicture = 0;
    
    //create clear imageview to add shadow to
    clearImageView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 258, 200, 160)]; //create ImageView
    clearImageView.backgroundColor = [UIColor colorWithRed:0.94 green:0.98 blue:0.94 alpha:1.0];
    clearImageView.image = nil;
    [self.view addSubview:clearImageView];
    [self.view sendSubviewToBack:clearImageView];
    
    //round the corners
    selectedImage.layer.cornerRadius = 5.0;
    clearImageView.layer.cornerRadius = 5.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    submitData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    //[_responseData appendData:data];
    [submitData appendData:data];
    
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    [self parseSubmitData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    [self handleSubmitFail];        
}

- (IBAction)submitButton:(id)sender {
    submitAlert= [[UIAlertView alloc] initWithTitle:@"Asking..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [submitAlert show];
                [typeQuestion resignFirstResponder];
                
                NSString *question = typeQuestion.text;
                question = [question stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
                NSString *encodedQuestion = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                                  NULL,
                                                                                                                  (__bridge CFStringRef) question,
                                                                                                                  NULL,
                                                                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                                  kCFStringEncodingUTF8));
                
                
                NSString *firstAnswerString = firstAnswerTextField.text;
                NSString *encodedFirstAnswer = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                                     NULL,
                                                                                                                     (__bridge CFStringRef) firstAnswerString,
                                                                                                                     NULL,
                                                                                                                     (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                                     kCFStringEncodingUTF8));
                
                NSString *secondAnswerString = secondAnswerTextField.text;
                NSString *encodedSecondAnswer = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                                      NULL,
                                                                                                                      (__bridge CFStringRef) secondAnswerString,
                                                                                                                      NULL,
                                                                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                                      kCFStringEncodingUTF8));
                
                //check for picture
                if(selectedImage.image == nil){
                    hasPicture = 0;
                }else{
                    hasPicture = 1;
                }
                
                //check for anonymous
                if(anonymousBar.selectedSegmentIndex==0){
                    isAnonymous = 0;
                }else{
                    isAnonymous = 1;
                }
                
                //put text in the url and post the picture data if needed
                NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/dichoImages/submitQuestion.php?questionSubmitted=%@&userID=%d&firstAnswer=%@&secondAnswer=%@&anonymous=%d&hasPicture=%d", encodedQuestion, [prefs integerForKey:@"userID"], encodedFirstAnswer, encodedSecondAnswer, isAnonymous, hasPicture];
                
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                [request setURL:[NSURL URLWithString:strURL]];
                [request setHTTPMethod:@"POST"];
                [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
                [request setTimeoutInterval:15.0];
                
                NSString *boundary = @"---------------------------14737809831466499882746641449";
                NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
                [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
                
                NSMutableData *body = [NSMutableData data];
                                
                //check for picture and handle if so
                if(hasPicture == 1){
                    NSData *imageData = UIImageJPEGRepresentation(selectedImage.image, .5);
                   
                    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[@"Content-Disposition: form-data; name=\"userfile\"; filename=\".jpeg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[NSData dataWithData:imageData]];
                    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                }
                
                [request setHTTPBody:body];
                submitConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
                
                
                
            submitButton.enabled=NO;
            [self dismissKeyboard];
}

-(void)parseSubmitData{
    NSString *strData = [[NSString alloc]initWithData:submitData encoding:NSUTF8StringEncoding];
    [submitAlert dismissWithClickedButtonIndex:0 animated:YES];

    if([strData isEqualToString:@"1"]){
        submitAlert= [[UIAlertView alloc] initWithTitle:@"Dicho asked successfully." message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    }else{
        submitAlert= [[UIAlertView alloc] initWithTitle:@"Error asking Dicho." message:@"Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    }
    [submitAlert show];
   

}

-(void)handleSubmitFail{
    [submitAlert dismissWithClickedButtonIndex:0 animated:YES];
    submitAlert= [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [submitAlert show];
}

- (IBAction)clearButton:(id)sender {
    submitButton.enabled=NO;
    [self dismissKeyboard];
    typeQuestion.text = nil;
    firstAnswerTextField.text = nil;
    secondAnswerTextField.text = nil;
    characterLabel.text = @"140";
    textField1Label.text = @"17";
    textField2Label.text = @"17";
    selectedImage.image = nil;
    [removePictureButton setImage:nil forState:UIControlStateNormal];
    removePictureButton.enabled = NO;
    clearImageView.layer.shadowColor = [UIColor clearColor].CGColor;
    
}


-(void)textViewDidChange:(UITextView*)typeQuestion{
    int charactersLeft = 140 - self.typeQuestion.text.length;
    characterLabel.text = [NSString stringWithFormat:@"%d", charactersLeft];
    if(firstAnswerTextField.text.length>0&&firstAnswerTextField.text.length<18&&self.typeQuestion.text.length>0&&self.typeQuestion.text.length<141&&secondAnswerTextField.text.length>0&&secondAnswerTextField.text.length<18){
        if ([self.typeQuestion.text rangeOfString:@"|"].location==NSNotFound&&[firstAnswerTextField.text rangeOfString:@"|"].location==NSNotFound&&[secondAnswerTextField.text rangeOfString:@"|"].location==NSNotFound) {
            submitButton.enabled=YES;
        } else {
            submitButton.enabled = NO;
        }
    }
    else
        submitButton.enabled=NO;
}

-(IBAction)textField1Changed:(id)sender{
    int length = firstAnswerTextField.text.length;
    textField1Label.text = [NSString stringWithFormat:@"%d", 17-length];
    if(length>0&&length<18&&typeQuestion.text.length>0&&typeQuestion.text.length<141&&secondAnswerTextField.text.length>0&&secondAnswerTextField.text.length<18)
        if ([typeQuestion.text rangeOfString:@"|"].location==NSNotFound&&[firstAnswerTextField.text rangeOfString:@"|"].location==NSNotFound&&[secondAnswerTextField.text rangeOfString:@"|"].location==NSNotFound) {
            submitButton.enabled=YES;
        } else {
            submitButton.enabled = NO;
        }
        else
        submitButton.enabled=NO;
    
}

-(IBAction)textField2Changed:(id)sender{
    int length = secondAnswerTextField.text.length;
    textField2Label.text = [NSString stringWithFormat:@"%d", 17-length];
    if(length>0&&length<18&&typeQuestion.text.length>0&&typeQuestion.text.length<141&&firstAnswerTextField.text.length>0&&firstAnswerTextField.text.length<18)
        if ([typeQuestion.text rangeOfString:@"|"].location==NSNotFound&&[firstAnswerTextField.text rangeOfString:@"|"].location==NSNotFound&&[secondAnswerTextField.text rangeOfString:@"|"].location==NSNotFound) {
            submitButton.enabled=YES;
        } else {
            submitButton.enabled = NO;
        }
        else
        submitButton.enabled=NO;
}
    
    

- (IBAction)addPicture:(id)sender {
    UIActionSheet *photoSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Camera Roll", nil];
    [photoSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        //take photo
        UIImagePickerController * picker = [[UIImagePickerController alloc]init];
        picker.delegate=self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];

    } else if (buttonIndex == 1) {
        //camera roll
        UIImagePickerController * picker = [[UIImagePickerController alloc]init];
        picker.delegate=self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];

    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
	selectedImage.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
        clearImageView.layer.shadowColor = [UIColor blackColor].CGColor;
        clearImageView.layer.shadowOffset = CGSizeMake(0, 1);
        clearImageView.layer.shadowOpacity = 1;
        clearImageView.layer.shadowRadius = 4.0;
        clearImageView.clipsToBounds = NO;

    [removePictureButton setImage:[UIImage imageNamed:@"blackXicon.png"] forState:UIControlStateNormal];
    removePictureButton.enabled = YES;
    [self dismissKeyboard];
}

-(void)dismissKeyboard {
    [typeQuestion resignFirstResponder];
    [firstAnswerTextField resignFirstResponder];
    [secondAnswerTextField resignFirstResponder];
}
- (IBAction)removePicture:(id)sender {
    selectedImage.image = nil;
    [removePictureButton setImage:nil forState:UIControlStateNormal];
    removePictureButton.enabled = NO;
    clearImageView.layer.shadowColor = [UIColor clearColor].CGColor;

}



@end
