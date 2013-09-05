//
//  DICHOGroupSettingsViewController.h
//  Dicho
//
//  Created by Tyler Droll on 8/3/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOGroupSettingsViewController : UITableViewController
{
    NSUserDefaults *prefs;
    NSString *groupID;
    NSString *name;
    NSString *username;
    NSString *adminUsername;
    NSString *adminID;
    UIImage *groupImage;
    NSString *memberRequestsNumber;
    NSString *userID;
    NSString *ownUsername;
    
    NSURLConnection *settingsInfoConnection;
    NSMutableData *settingsInfoData;
    
    NSURLConnection *deleteGroupConnection;
    
}
-(id)initWithGroupID:(NSString*)aGroupID name:(NSString*)aName username:(NSString*)aUsername image:(UIImage*)aImage;

-(void)parseSettingsInfoData;
-(void)handleSettingsInfoFail;

-(void)parseDeleteData;
-(void)handleDeleteFail;

@property (nonatomic) IBOutlet UIAlertView *notAdminAlert;
@property (nonatomic) IBOutlet UIAlertView *deleteAlert;
@property (nonatomic) IBOutlet UIAlertView *progressAlert;


@end
