//
//  DICHOSUAskingViewController.h
//  Dicho
//
//  Created by Tyler Droll on 5/23/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOSUAskingViewController : UITableViewController
{
    NSString *userID;
    NSString *selectedUserID;
    NSMutableArray *userIDsAsking;
    NSMutableArray *usernamesAsking;
    NSMutableArray *namesAsking;
    NSMutableArray *answeringStatuses;
    NSUserDefaults *prefs;
    
    NSURLConnection *askingInfosConnection;
    NSURLConnection *answeringConnection;
    NSURLConnection *unansweringConnection;
    
    NSMutableData *askingInfosData;
    NSMutableData *answeringData;
    NSMutableData *unansweringData;
    
    
    NSMutableArray *userImagesArray;

    NSOperationQueue *imageQueue;

}
-(id)initWithAskerID:(NSString*)aAskerID;

- (IBAction)answer:(id)sender;
@property (nonatomic) IBOutlet UIAlertView *progressAlert;

-(void)parseAskingInfosData;
-(void)handleAskingInfosFail;


-(void)parseAnsweringData;
-(void)parseUnansweringData;
-(void)handleAnsweringFail;
@property int answeringRow;

-(IBAction)goToUser:(id)sender;


@end
