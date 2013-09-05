//
//  DICHOPasswordViewController.h
//  Dicho
//
//  Created by Tyler Droll on 12/29/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOPasswordViewController : UITableViewController <UITextFieldDelegate>{
    NSUserDefaults *prefs;
    NSURLConnection *passwordConnection;
    NSMutableData *passwordData;

}
@property (weak, nonatomic) IBOutlet UITextField *currentPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *proposedPassword1TextField;
@property (weak, nonatomic) IBOutlet UITextField *proposedPassword2TextField;
- (IBAction)proposedPassword1Changed:(id)sender;
- (IBAction)proposedPassword2Changed:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *matchLabel;
@property (nonatomic) IBOutlet UIAlertView *passwordAlert;

-(void)parsePasswordData;
-(void)handlePasswordFail;

@end
