//
//  DICHOGroupNameViewController.h
//  Dicho
//
//  Created by Tyler Droll on 8/3/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOGroupNameViewController : UITableViewController <UITextFieldDelegate>
{
    NSUserDefaults *prefs;

    NSString *groupID;
    NSString *originalName;
    
    NSURLConnection *nameConnection;
    NSMutableData *nameData;

}

-(id)initWithGroupID:(NSString*)givenGroupID name:(NSString*)givenName;

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;

@property (nonatomic) IBOutlet UIAlertView *progressAlert;

-(void)parseNameData;
-(void)handleNameFail;

@end
