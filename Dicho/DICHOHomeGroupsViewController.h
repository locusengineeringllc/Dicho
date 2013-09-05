//
//  DICHOHomeGroupsViewController.h
//  Dicho
//
//  Created by Tyler Droll on 8/1/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOHomeGroupsViewController : UITableViewController
{
    NSMutableArray *groupsIDsArray;
    NSMutableArray *groupsNamesArray;
    NSMutableArray *groupsUsernamesArray;
    NSUserDefaults *prefs;
    
    NSURLConnection *groupInfosConnection;
    NSMutableData *groupInfosData;
    
    NSMutableArray *groupImagesArray;
    NSOperationQueue *imageQueue;
    
}
- (IBAction)createGroup:(id)sender;

-(void)parseGroupInfosData;
-(void)handleGroupInfosFail;

@end
