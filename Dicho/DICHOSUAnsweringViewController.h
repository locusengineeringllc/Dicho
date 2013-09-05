//
//  DICHOSUAnsweringViewController.h
//  Dicho
//
//  Created by Tyler Droll on 5/23/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOSUAnsweringViewController : UITableViewController
{
    NSString *userID;
    NSString *selectedUserID;
    NSMutableArray *userIDsAnswering;
    NSMutableArray *usernamesAnswering;
    NSMutableArray *namesAnswering;
    NSMutableArray *answeringStatuses;
    NSUserDefaults *prefs;
    
    NSURLConnection *answeringInfosConnection;
    NSURLConnection *answeringConnection;
    NSURLConnection *unansweringConnection;
    
    NSMutableData *answeringInfosData;
    NSMutableData *answeringData;
    NSMutableData *unansweringData;
    
    NSMutableArray *userImagesArray;

    NSOperationQueue *imageQueue;

}

-(id)initWithAnswererID:(NSString*)aAnswererID;

- (IBAction)answer:(id)sender;
@property (nonatomic) IBOutlet UIAlertView *progressAlert;

-(void)parseAnsweringInfosData;
-(void)handleAnsweringInfosFail;

-(void)parseAnsweringData;
-(void)parseUnansweringData;
-(void)handleAnsweringFail;
@property int answeringRow;

-(IBAction)goToUser:(id)sender;

@end
