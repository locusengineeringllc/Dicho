//
//  DICHOLogInViewController.h
//  Dicho
//
//  Created by Tyler Droll on 10/31/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOLogInViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    NSUserDefaults *prefs;
    NSURLConnection *loginConnection;
    NSURLConnection *userInfoConnection;
    
    NSMutableData *loginData;
    NSMutableData *userInfoData;
    
    NSString *userID;
    NSString *name;
    NSString *username;
    NSString *password;
    NSString *email;

}

@property (weak, nonatomic) IBOutlet UITableView *logInTable;
@property (nonatomic) IBOutlet UIAlertView *loginAlert;

-(void)handleGoodLogin;
-(void)handleLoginFail;

-(void)handleGoodUserInfo;
-(void)handleUserInfoFail;

@end
