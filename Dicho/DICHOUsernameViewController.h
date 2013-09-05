//
//  DICHOUsernameViewController.h
//  Dicho
//
//  Created by Tyler Droll on 6/3/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOUsernameViewController : UITableViewController{
    NSUserDefaults *prefs;
    
    NSURLConnection *firstUniqueConnection;
    NSMutableData *firstUniqueData;
        
    NSURLConnection *usernameConnection;
    NSMutableData *usernameData;
}

@property (nonatomic) IBOutlet UIAlertView *usernameAlert;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;

-(void)parseFirstUniqueData;
-(void)handleFirstUniqueFail;

-(void)parseUsernameData;
-(void)handleUsernameFail;


@end
