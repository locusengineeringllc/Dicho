//
//  DICHOCreateAccountViewController.h
//  Dicho
//
//  Created by Tyler Droll on 12/20/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOCreateAccountViewController : UITableViewController <UITextFieldDelegate>{
    NSUserDefaults *prefs;
    
    NSURLConnection *uniqueConnection;
    NSMutableData *uniqueData;

    NSURLConnection *createConnection;
    NSMutableData *createData;
    
}
- (IBAction)checkUniqueUsername:(id)sender;
- (IBAction)createButton:(id)sender;
- (IBAction)password1Changed:(id)sender;
- (IBAction)password2Changed:(id)sender;

-(void)parseUniqueData;
-(void)handleUniqueFail;

-(void)parseCreateData;
-(void)handleCreateFail;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *password1TextField;
@property (weak, nonatomic) IBOutlet UITextField *password2TextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UILabel *passwordMatchLabel;

@property (nonatomic) IBOutlet UIAlertView *createAlert;



@end
