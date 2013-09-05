//
//  DICHOGroupRequestsViewController.h
//  Dicho
//
//  Created by Tyler Droll on 8/5/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOGroupRequestsViewController : UITableViewController
{
    NSUserDefaults *prefs;

    NSString *groupID;

    NSMutableArray *userIDsRequesting;
    NSMutableArray *usernames;
    NSMutableArray *names;
    
    NSURLConnection *requesterInfosConnection;
    NSURLConnection *denyConnection;
    NSURLConnection *acceptConnection;
    NSURLConnection *acceptAllConnection;
    
    NSMutableData *requesterInfosData;
    NSMutableData *acceptData;
    NSMutableData *acceptAllData;
    NSMutableData *denyData;
    
    NSMutableArray *userImagesArray;
    NSOperationQueue *imageQueue;    
    
}
-(id)initWithGroupID:(NSString*)givenGroupID;


- (IBAction)acceptAll:(id)sender;
- (IBAction)accept:(id)sender;
- (IBAction)deny:(id)sender;

-(void)parseRequesterInfosData;
-(void)handleRequesterInfosFail;

-(void)parseAcceptAllData;
-(void)handleAcceptAllFail;

-(void)parseAcceptData;
-(void)handleAcceptFail;

-(void)parseDenyData;
-(void)handleDenyFail;

@property int actingRow;


@property (nonatomic) IBOutlet UIAlertView *progressAlert;
-(IBAction)goToUser:(id)sender;


@end
