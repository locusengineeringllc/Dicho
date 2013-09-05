//
//  DICHOEmailAddressViewController.h
//  Dicho
//
//  Created by Tyler Droll on 12/29/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOEmailAddressViewController : UITableViewController{
    NSUserDefaults *prefs;
    NSURLConnection *emailConnection;
    NSMutableData *emailData;
}
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (nonatomic) IBOutlet UIAlertView *emailAlert;

-(void)parseEmailData;
-(void)handleEmailFail;

@end
