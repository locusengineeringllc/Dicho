//
//  DICHOTabBarViewController.m
//  Dicho
//
//  Created by Tyler Droll on 10/31/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import "DICHOTabBarViewController.h"

@interface DICHOTabBarViewController ()

@end

@implementation DICHOTabBarViewController

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
    NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
    if( [prefs integerForKey:@"loggedIn"]==1)
    {
        [self performSegueWithIdentifier:@"loggedInAlready" sender:self];
    }
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
