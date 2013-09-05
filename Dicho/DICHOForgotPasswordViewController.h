//
//  DICHOForgotPasswordViewController.h
//  Dicho
//
//  Created by Tyler Droll on 12/31/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOForgotPasswordViewController : UITableViewController{
    NSUserDefaults *prefs;
    NSURLConnection *fpConnection;
    NSMutableData *fpData;
}
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (nonatomic) IBOutlet UIAlertView *forgotPasswordAlert;

-(void)parseFPData;
-(void)handleFPFail;

@end
