//
//  DICHOShowLikesViewController.h
//  Dicho
//
//  Created by Tyler Droll on 8/20/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOShowLikesViewController : UITableViewController
{
    NSUserDefaults *prefs;

    NSMutableArray *userIDsArray;
    NSMutableArray *usernamesArray;
    
    NSString *selectedCommentID;
    
    NSURLConnection *likersConnection;
    NSMutableData *likersData;

}

-(id)initWithCommentID:(NSString*)aCommentID;

@property BOOL loadedAll;


-(void)parseLikersData;
-(void)handleConnectionFail;

@end
