//
//  DICHOSetsTutorial1ViewController.m
//  Dicho
//
//  Created by Tyler Droll on 9/12/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOSetsTutorial1ViewController.h"

@interface DICHOSetsTutorial1ViewController ()

@end

@implementation DICHOSetsTutorial1ViewController
@synthesize label;
@synthesize imageNumber;
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
    imageNumber = 1;
    label.text = @"1";
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handleSwipeLeft{
    //go up image number
    //if 7 then dismiss
    imageNumber = imageNumber + 1;
    if(imageNumber == 1){
        label.text = @"1";
    }else if(imageNumber == 2){
        label.text = @"2";
    }else if(imageNumber == 3){
        label.text = @"3";

    }else if(imageNumber == 4){
        label.text = @"4";

    }else if(imageNumber == 5){
        label.text = @"5";

    }else if(imageNumber == 6){
        label.text = @"6";

    }else if(imageNumber == 7){
        //dismiss
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];

    }
}

-(void)handleSwipeRight{
    
    //go down image number
    //if  to zero than dismiss
    imageNumber = imageNumber - 1;
    if(imageNumber == 0){
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }else if(imageNumber == 1){
        label.text = @"1";

    }else if(imageNumber == 2){
        label.text = @"2";

    }else if(imageNumber == 3){
        label.text = @"3";

    }else if(imageNumber == 4){
        label.text = @"4";

    }else if(imageNumber == 5){
        label.text = @"5";

    }else if(imageNumber == 6){
        label.text = @"6";

    }
}
@end
