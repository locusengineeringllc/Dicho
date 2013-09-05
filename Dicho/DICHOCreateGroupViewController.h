//
//  DICHOCreateGroupViewController.h
//  Dicho
//
//  Created by Tyler Droll on 8/1/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOCreateGroupViewController : UITableViewController
{
    NSUserDefaults *prefs;
    
    NSURLConnection *uniqueConnection;
    NSMutableData *uniqueData;
    
    NSURLConnection *createConnection;
    NSMutableData *createData;
}

- (IBAction)createGroup:(id)sender;
- (IBAction)checkUsernameUniqueness:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (nonatomic) IBOutlet UIAlertView *createAlert;


-(void)parseUniqueData;
-(void)handleUniqueFail;

-(void)parseCreateData;
-(void)handleCreateFail;

@end
