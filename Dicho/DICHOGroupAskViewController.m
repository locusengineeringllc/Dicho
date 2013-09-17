//
//  DICHOGroupAskViewController.m
//  Dicho
//
//  Created by Tyler Droll on 8/3/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOGroupAskViewController.h"
#import "QuartzCore/CALayer.h"

@interface DICHOGroupAskViewController ()

@end

@implementation DICHOGroupAskViewController
@synthesize typeQuestion;
@synthesize characterLabel;
@synthesize anonymousBar;
@synthesize isAnonymous;
@synthesize firstAnswerTextField;
@synthesize secondAnswerTextField;
@synthesize textField1Label;
@synthesize textField2Label;
@synthesize addPictureButton;
@synthesize photoLabel;
@synthesize clearImageView;
@synthesize selectedImage;
@synthesize hasPicture;
@synthesize removePictureButton;
@synthesize submitAlert;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)initWithGroupID:(NSString*)givenGroupID{
    self = [super init];
    if( !self) return nil;
    self.title = @"Ask a Dicho";
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
    userID = [prefs objectForKey:@"userID"];
    isAnonymous = 0;
    hasPicture = 0;
    
    self.view.backgroundColor = [UIColor colorWithRed:0.88 green:0.96 blue:1.0 alpha:1.0];
    [self resignFirstResponder];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    //create and add Ask button
    UIBarButtonItem *askButton = [[UIBarButtonItem alloc] initWithTitle:@"Ask"
                                                                  style:UIBarButtonItemStyleBordered target:self action:@selector(ask:)];
    
    self.navigationItem.rightBarButtonItem = askButton;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    //create and add anonymousBar
     NSArray *itemArray = [NSArray arrayWithObjects: @"Show Who I Am", @"Hide Who I Am", nil];
    anonymousBar = [[UISegmentedControl alloc] initWithItems:itemArray];
    anonymousBar.frame = CGRectMake(0, 64, 320, 29);
    anonymousBar.segmentedControlStyle = UISegmentedControlStyleBar;
    anonymousBar.selectedSegmentIndex = 0;
    anonymousBar.tintColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0];
    [self.view addSubview:anonymousBar];
    
    //create and add textView and its characterlabel
    typeQuestion = [[UITextView alloc] initWithFrame:CGRectMake(0, 93, 320, 80)];
    typeQuestion.font = [UIFont fontWithName:@"ArialMT" size:14.0];
    typeQuestion.textAlignment = NSTextAlignmentLeft;
    typeQuestion.keyboardType = UIKeyboardTypeASCIICapable;
    typeQuestion.delegate = self;
    [self.view addSubview:typeQuestion];
    [typeQuestion becomeFirstResponder];
    
    characterLabel = [[UILabel alloc] initWithFrame:CGRectMake(258, 174, 50, 25)];
    characterLabel.text = @"140";
    characterLabel.font = [UIFont fontWithName:@"ArialMT" size:16.0];
    characterLabel.textColor = [UIColor colorWithRed:0.0 green:0.25 blue:0.5 alpha:1.0];
    characterLabel.textAlignment = NSTextAlignmentRight;
    characterLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:characterLabel];

    //create and add textfields and their character labels
    firstAnswerTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, 179, 135, 30)];
    firstAnswerTextField.font = [UIFont fontWithName:@"ArialMT" size:14.0];
    firstAnswerTextField.textAlignment = NSTextAlignmentLeft;
    firstAnswerTextField.delegate = self;
    firstAnswerTextField.borderStyle = UITextBorderStyleRoundedRect;
    firstAnswerTextField.keyboardType = UIKeyboardTypeASCIICapable;
    firstAnswerTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [firstAnswerTextField addTarget:self action:@selector(textField1Changed:) forControlEvents:UIControlEventEditingChanged];
    firstAnswerTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:firstAnswerTextField];
    
    textField1Label = [[UILabel alloc] initWithFrame:CGRectMake(143, 188, 48, 21)];
    textField1Label.text = @"17";
    textField1Label.font = [UIFont fontWithName:@"ArialMT" size:16.0];
    textField1Label.textColor = [UIColor colorWithRed:0.0 green:0.25 blue:0.5 alpha:1.0];
    textField1Label.textAlignment = NSTextAlignmentLeft;
    textField1Label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:textField1Label];
    
    secondAnswerTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, 217, 135, 30)];
    secondAnswerTextField.font = [UIFont fontWithName:@"ArialMT" size:14.0];
    secondAnswerTextField.textAlignment = NSTextAlignmentLeft;
    secondAnswerTextField.delegate = self;
    secondAnswerTextField.borderStyle = UITextBorderStyleRoundedRect;
    secondAnswerTextField.keyboardType = UIKeyboardTypeASCIICapable;
    secondAnswerTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [secondAnswerTextField addTarget:self action:@selector(textField2Changed:) forControlEvents:UIControlEventEditingChanged];
    secondAnswerTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:secondAnswerTextField];
    
    textField2Label = [[UILabel alloc] initWithFrame:CGRectMake(143, 226, 48, 21)];
    textField2Label.text = @"17";
    textField2Label.font = [UIFont fontWithName:@"ArialMT" size:16.0];
    textField2Label.textColor = [UIColor colorWithRed:0.0 green:0.25 blue:0.5 alpha:1.0];
    textField2Label.textAlignment = NSTextAlignmentLeft;
    textField2Label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:textField2Label];
    
    //create and add picture button and label
    addPictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addPictureButton addTarget:self action:@selector(addPicture:) forControlEvents:UIControlEventTouchUpInside];
    [addPictureButton setFrame:CGRectMake(223, 188, 44, 36)];
    [addPictureButton setBackgroundImage:[UIImage imageNamed:@"dicho_camera.png"] forState:UIControlStateNormal];
    [self.view addSubview:addPictureButton];
    
    photoLabel = [[UILabel alloc] initWithFrame:CGRectMake(224, 217, 42, 21)];
    photoLabel.text = @"Photo";
    photoLabel.font = [UIFont fontWithName:@"ArialMT" size:16.0];
    photoLabel.textColor = [UIColor colorWithRed:0.0 green:0.25 blue:0.5 alpha:1.0];
    photoLabel.textAlignment = NSTextAlignmentCenter;
    photoLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:photoLabel];

    //create and add the two imageViews and X button
    clearImageView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 258, 200, 160)];
    clearImageView.backgroundColor = [UIColor colorWithRed:0.94 green:0.98 blue:0.94 alpha:1.0];
    clearImageView.image = nil;
    clearImageView.layer.cornerRadius = 5.0;
    [self.view addSubview:clearImageView];

    selectedImage = [[UIImageView alloc] initWithFrame:CGRectMake(60, 258, 200, 160)];
    selectedImage.backgroundColor = [UIColor colorWithRed:0.94 green:0.98 blue:1.0 alpha:1.0];
    selectedImage.image = nil;
    selectedImage.contentMode = UIViewContentModeScaleAspectFit;
    selectedImage.clipsToBounds = YES;
    selectedImage.layer.cornerRadius = 5.0;
    [self.view addSubview:selectedImage];
    
    removePictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [removePictureButton addTarget:self action:@selector(removePicture:) forControlEvents:UIControlEventTouchUpInside];
    [removePictureButton setFrame:CGRectMake(242, 243, 35, 35)];
    [removePictureButton setImage:nil forState:UIControlStateNormal];
    removePictureButton.enabled = NO;
    [self.view addSubview:removePictureButton];
    
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

- (IBAction)ask:(id)sender {
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
    NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/dichoImages/submitGroupQuestion.php?groupID=%@&questionSubmitted=%@&userID=%@&firstAnswer=%@&secondAnswer=%@&anonymous=%d&hasPicture=%d", groupID, encodedQuestion, userID, encodedFirstAnswer, encodedSecondAnswer, isAnonymous, hasPicture];
    
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
    
    
    
    self.navigationItem.rightBarButtonItem.enabled=NO;
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

-(void)textViewDidChange:(UITextView *)typeQuestion{
    int charactersLeft = 140 - self.typeQuestion.text.length;
    characterLabel.text = [NSString stringWithFormat:@"%d", charactersLeft];
    if(firstAnswerTextField.text.length>0&&firstAnswerTextField.text.length<18&&self.typeQuestion.text.length>0&&self.typeQuestion.text.length<141&&secondAnswerTextField.text.length>0&&secondAnswerTextField.text.length<18){
        if ([self.typeQuestion.text rangeOfString:@"|"].location==NSNotFound&&[firstAnswerTextField.text rangeOfString:@"|"].location==NSNotFound&&[secondAnswerTextField.text rangeOfString:@"|"].location==NSNotFound) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        } else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
    else
        self.navigationItem.rightBarButtonItem.enabled = NO;
}

-(IBAction)textField1Changed:(id)sender{
    int length = firstAnswerTextField.text.length;
    textField1Label.text = [NSString stringWithFormat:@"%d", 17-length];
    if(length>0&&length<18&&typeQuestion.text.length>0&&typeQuestion.text.length<141&&secondAnswerTextField.text.length>0&&secondAnswerTextField.text.length<18)
        if ([typeQuestion.text rangeOfString:@"|"].location==NSNotFound&&[firstAnswerTextField.text rangeOfString:@"|"].location==NSNotFound&&[secondAnswerTextField.text rangeOfString:@"|"].location==NSNotFound) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        } else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
        else
            self.navigationItem.rightBarButtonItem.enabled = NO;
    
}

-(IBAction)textField2Changed:(id)sender{
    int length = secondAnswerTextField.text.length;
    textField2Label.text = [NSString stringWithFormat:@"%d", 17-length];
    if(length>0&&length<18&&typeQuestion.text.length>0&&typeQuestion.text.length<141&&firstAnswerTextField.text.length>0&&firstAnswerTextField.text.length<18)
        if ([typeQuestion.text rangeOfString:@"|"].location==NSNotFound&&[firstAnswerTextField.text rangeOfString:@"|"].location==NSNotFound&&[secondAnswerTextField.text rangeOfString:@"|"].location==NSNotFound) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        } else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
        else
            self.navigationItem.rightBarButtonItem.enabled = NO;

}

-(void)dismissKeyboard {
    [typeQuestion resignFirstResponder];
    [firstAnswerTextField resignFirstResponder];
    [secondAnswerTextField resignFirstResponder];
}

- (IBAction)addPicture:(id)sender {
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    picker.delegate=self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
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

- (IBAction)removePicture:(id)sender {
    selectedImage.image = nil;
    [removePictureButton setImage:nil forState:UIControlStateNormal];
    removePictureButton.enabled = NO;
    clearImageView.layer.shadowColor = [UIColor clearColor].CGColor;
}

@end
