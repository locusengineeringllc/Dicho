//
//  DICHOAskingViewController.h
//  Dicho
//
//  Created by Tyler Droll on 11/28/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOAskingViewController : UITableViewController
{
    NSString *userID;
    NSMutableArray *userIDsAskingToBeAddedArray;
    NSMutableArray *userIDsAsking;
    NSMutableArray *usernamesAsking;
    NSMutableArray *namesAsking;
    NSMutableArray *answeringStatuses;
    NSUserDefaults *prefs;
    
    NSURLConnection *askingIDsConnection;
    NSURLConnection *infoConnection;
    NSURLConnection *answeringConnection;
    NSURLConnection *unansweringConnection;
    
    NSMutableData *askingIDsData;
    NSMutableData *infoData;
    NSMutableData *answeringData;
    NSMutableData *unansweringData;

}

- (IBAction)answer:(id)sender;
@property (nonatomic) IBOutlet UIAlertView *progressAlert;

-(void)parseAskingIDsData;
-(void)handleAskingIDsFail;

-(void)parseInfoData;
-(void)handleInfoFail;

-(void)parseAnsweringData;
-(void)parseUnansweringData;
-(void)handleAnsweringFail;
@property int answeringRow;

@end
