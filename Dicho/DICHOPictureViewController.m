//
//  DICHOPictureViewController.m
//  Dicho
//
//  Created by Tyler Droll on 8/31/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOPictureViewController.h"

@interface DICHOPictureViewController ()

@end

@implementation DICHOPictureViewController
@synthesize imageView;
@synthesize dismissButton;
@synthesize statusLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithDichoID:(NSString*)aDichoID{
    self = [super init];
    if( !self) return nil;
    selectedDichoID = aDichoID;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    //add button for dismiss
    dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
    dismissButton.frame = CGRectMake(100, self.view.bounds.size.height-80, 120, 80);
    [dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
    [dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    dismissButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:16.0];
    [dismissButton addTarget:self action:@selector(dismissView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dismissButton];
    
    //add label that says loading?
    statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 320, self.view.bounds.size.height-110)];
    statusLabel.text = @"Loading...";
    statusLabel.textAlignment = NSTextAlignmentCenter;
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.font = [UIFont fontWithName:@"ArialMT" size:16.0];
    [self.view addSubview:statusLabel];
    
    //add nil imageview
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, 320, self.view.bounds.size.height-110)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:imageView];

    
    //call to get image! -handle good and bad connection?
    NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/dichoImages/%@.jpeg", selectedDichoID];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 60.0];
    imageConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Connection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    imageData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [imageData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self handleGoodImage];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self handleImageFail];
}

-(void)handleGoodImage{
    if(imageData == nil){
        statusLabel.text = @"No image to display";
    }else{
        statusLabel.text = @"";
        imageView.image = [UIImage imageWithData: imageData];
    }
}

-(void)handleImageFail{
    statusLabel.text = @"Unable to load image";
}

-(IBAction)dismissView:(id)sender{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

@end
