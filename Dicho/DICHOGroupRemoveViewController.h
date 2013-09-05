//
//  DICHOGroupRemoveViewController.h
//  Dicho
//
//  Created by Tyler Droll on 8/6/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOGroupRemoveViewController : UITableViewController
{
    NSUserDefaults *prefs;

    NSString *groupID;
    
    NSMutableArray *memberIDs;
    NSMutableArray *usernames;
    NSMutableArray *names;

    NSURLConnection *memberInfosConnection;
    NSURLConnection *removeMemberConnection;

    NSMutableData *memberInfosData;
    
    NSMutableArray *userImagesArray;
    NSOperationQueue *imageQueue;

}
-(id)initWithGroupID:(NSString*)givenGroupID;
- (IBAction)removeMember:(id)sender;

-(void)parseMemberInfosData;
-(void)handleMemberInfosFail;


-(void)parseRemoveData;
-(void)handleRemoveFail;
@property int removingRow;

@property (nonatomic) IBOutlet UIAlertView *progressAlert;
-(IBAction)goToUser:(id)sender;

@end
