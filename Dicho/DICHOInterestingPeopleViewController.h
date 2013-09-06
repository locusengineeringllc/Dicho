//
//  DICHOInterestingPeopleViewController.h
//  Dicho
//
//  Created by Tyler Droll on 9/5/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOInterestingPeopleViewController : UITableViewController
{
    NSString *userID;
    NSMutableArray *userIDsInt;
    NSMutableArray *usernamesInt;
    NSMutableArray *namesInt;
    NSMutableArray *answeringStatuses;
    NSUserDefaults *prefs;
    
    NSURLConnection *intPeopleInfosConnection;
    NSURLConnection *answeringConnection;
    NSURLConnection *unansweringConnection;
    
    NSMutableData *intPeopleInfosData;
    NSMutableData *answeringData;
    NSMutableData *unansweringData;
    
    
    NSMutableArray *userImagesArray;
    NSOperationQueue *imageQueue;
    
}

- (IBAction)answer:(id)sender;
@property (nonatomic) IBOutlet UIAlertView *progressAlert;

-(void)parseIntPeopleInfosData;
-(void)handleIntPeopleInfosFail;


-(void)parseAnsweringData;
-(void)parseUnansweringData;
-(void)handleAnsweringFail;
@property int answeringRow;

-(IBAction)goToUser:(id)sender;

@end
