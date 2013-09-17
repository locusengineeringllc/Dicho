//
//  DICHOLoadViewController.m
//  Dicho
//
//  Created by Tyler Droll on 9/17/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOLoadViewController.h"

@interface DICHOLoadViewController ()

@end

@implementation DICHOLoadViewController

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
}

-(void)viewDidAppear:(BOOL)animated{
    NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
    NSString *firstTimeStatus = [prefs objectForKey:@"firstTimeOpening"];
    
    if(![firstTimeStatus isEqualToString:@"0"]){
        [self performSegueWithIdentifier:@"loadToApp" sender:self];
    }else{
        [self performSegueWithIdentifier:@"loadTo0" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
