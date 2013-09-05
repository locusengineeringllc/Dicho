//
//  DICHOContactUsViewController.h
//  Dicho
//
//  Created by Tyler Droll on 9/3/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOContactUsViewController : UITableViewController{
    NSURLConnection *contactConnection;
    NSMutableData *contactData;

}
@property (weak, nonatomic) IBOutlet UITextView *contactTextView;

@property (nonatomic) IBOutlet UIAlertView *contactAlert;

-(void)parseContactData;
-(void)handleContactFail;

@end
