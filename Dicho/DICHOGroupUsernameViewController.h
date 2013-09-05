//
//  DICHOGroupUsernameViewController.h
//  Dicho
//
//  Created by Tyler Droll on 8/3/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOGroupUsernameViewController : UITableViewController <UITextFieldDelegate>
{
    NSUserDefaults *prefs;

    NSString *groupID;
    NSString *originalUsername;
    
    NSURLConnection *usernameConnection;
    NSMutableData *usernameData;
    
}

-(id)initWithGroupID:(NSString*)givenGroupID username:(NSString*)givenUsername;

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;

@property (nonatomic) IBOutlet UIAlertView *progressAlert;

-(void)parseUsernameData;
-(void)handleUsernameFail;


@end
