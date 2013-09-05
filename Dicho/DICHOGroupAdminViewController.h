//
//  DICHOGroupAdminViewController.h
//  Dicho
//
//  Created by Tyler Droll on 8/4/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOGroupAdminViewController : UITableViewController <UITextFieldDelegate>
{
    NSUserDefaults *prefs;

    NSString *groupID;
    NSString *originalAdmin;
    
    NSURLConnection *adminConnection;
    NSMutableData *adminData;
}

-(id)initWithGroupID:(NSString*)givenGroupID admin:(NSString*)givenAdmin;

@property (strong, nonatomic) IBOutlet UITextField *adminTextField;

@property (nonatomic) IBOutlet UIAlertView *progressAlert;

-(void)parseAdminData;
-(void)handleAdminFail;

@end
