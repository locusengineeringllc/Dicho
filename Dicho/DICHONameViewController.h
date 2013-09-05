//
//  DICHONameViewController.h
//  Dicho
//
//  Created by Tyler Droll on 12/29/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHONameViewController : UITableViewController
{
    NSUserDefaults *prefs;
    NSURLConnection *nameConnection;
    NSMutableData *nameData;
}

@property (nonatomic) IBOutlet UIAlertView *namesAlert;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

-(void)parseNameData;
-(void)handleNameFail;

@end
