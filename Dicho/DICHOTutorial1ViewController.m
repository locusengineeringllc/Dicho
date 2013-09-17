//
//  DICHOTutorial1ViewController.m
//  Dicho
//
//  Created by Tyler Droll on 9/3/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOTutorial1ViewController.h"
//IM CHANGING THIS FILLLLEEEEE
//okkk
@interface DICHOTutorial1ViewController ()

@end

@implementation DICHOTutorial1ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(handleSwipeLeft)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]
                                            initWithTarget:self
                                            action:@selector(handleSwipeRight)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
    NSString *firstTimeStatus = [prefs objectForKey:@"firstTimeOpening"];
    
    if(![firstTimeStatus isEqualToString:@"0"]){
        [self performSegueWithIdentifier:@"1toApp" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handleSwipeLeft{
    [self performSegueWithIdentifier:@"1to2" sender:self];
}

-(void)handleSwipeRight{
    [self performSegueWithIdentifier:@"1to0" sender:self];
    
}

@end
