//
//  DICHOAskedViewController.h
//  Dicho
//
//  Created by Tyler Droll on 11/28/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Reachability;


@interface DICHOAskedViewController : UITableViewController
{
    NSMutableArray *dichoIDsArray;
    NSMutableArray *fullDichoStringsArray;
    NSMutableArray *dichosArray;
    NSMutableArray *datesArray;
    NSMutableArray *timesArray;
    NSMutableArray *firstAnswersArray;
    NSMutableArray *secondAnswersArray;
    NSMutableArray *firstResultsArray;
    NSMutableArray *secondResultsArray;
    NSMutableArray *votesArray;
    NSMutableArray *picturesArray;
    NSMutableArray *anonymousArray;
    NSMutableArray *starsArray;
    Reachability* internetReachable;
    Reachability* hostReachable;
    NSUserDefaults *prefs;
}

-(IBAction)checkInternetMyWay:(id)sender;
-(IBAction)starADicho:(id)sender;
-(IBAction)showThePicture:(id)sender;
-(IBAction)refresh:(id)sender;
-(IBAction)results:(id)sender;
@property (nonatomic) IBOutlet UIAlertView *notLoggedInAlert;
@property (nonatomic) IBOutlet UIAlertView *pictureAlert;

-(void) checkNetworkStatus:(NSNotification *)notice;
@property BOOL internetActive;
@property BOOL hostActive;
@property BOOL myInternetActive;


@end
