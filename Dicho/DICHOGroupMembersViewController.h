//
//  DICHOGroupMembersViewController.h
//  Dicho
//
//  Created by Tyler Droll on 8/2/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOGroupMembersViewController : UITableViewController
{
    NSString *userID;
    NSString *groupID;
    NSMutableArray *memberIDs;
    NSMutableArray *memberUsernames;
    NSMutableArray *memberNames;
    NSMutableArray *answeringStatuses;
    NSUserDefaults *prefs;
    
    NSMutableArray *userImagesArray;
    NSOperationQueue *imageQueue;
    
    NSURLConnection *memberInfosConnection;
    NSURLConnection *answeringConnection;
    NSURLConnection *unansweringConnection;
    
    NSMutableData *memberInfosData;
    NSMutableData *answeringData;
    NSMutableData *unansweringData;
}
-(id)initWithGroupID:(NSString*)givenGroupID;

- (IBAction)answer:(id)sender;
@property (nonatomic) IBOutlet UIAlertView *progressAlert;

-(void)parseMemberInfosData;
-(void)handleMemberInfosFail;

-(void)parseAnsweringData;
-(void)parseUnansweringData;
-(void)handleAnsweringFail;
@property int answeringRow;

-(IBAction)goToUser:(id)sender;

@end
