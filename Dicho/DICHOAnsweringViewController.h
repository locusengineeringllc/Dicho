//
//  DICHOAnsweringViewController.h
//  Dicho
//
//  Created by Tyler Droll on 11/17/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOAnsweringViewController : UITableViewController
{
    NSString *userID;
    NSMutableArray *userIDsAnsweringToBeAddedArray;
    NSMutableArray *userIDsAnswering;
    NSMutableArray *usernamesAnswering;
    NSMutableArray *namesAnswering;
    NSMutableArray *answeringStatuses;
    NSMutableArray *userImagesArray;
    NSUserDefaults *prefs;
    
    NSURLConnection *answeringIDsConnection;
    NSURLConnection *infoConnection;
    NSURLConnection *answeringConnection;
    NSURLConnection *unansweringConnection;
    
    NSMutableData *answeringIDsData;
    NSMutableData *infoData;
    NSMutableData *answeringData;
    NSMutableData *unansweringData;
}

- (IBAction)answer:(id)sender;
@property (nonatomic) IBOutlet UIAlertView *progressAlert;

-(void)parseAnsweringIDsData;
-(void)handleAnsweringIDsFail;

-(void)parseInfoData;
-(void)handleInfoFail;

-(void)parseAnsweringData;
-(void)parseUnansweringData;
-(void)handleAnsweringFail;
@property int answeringRow;

@end
