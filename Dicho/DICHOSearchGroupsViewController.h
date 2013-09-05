//
//  DICHOSearchGroupsViewController.h
//  Dicho
//
//  Created by Tyler Droll on 8/7/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOSearchGroupsViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *groupsIDsArray;
    NSMutableArray *namesArray;
    NSMutableArray *usernamesArray;
    NSUserDefaults *prefs;
    NSString *userID;
    
    NSURLConnection *searchConnection;
    NSURLConnection *joinConnection;
    
    NSMutableData *searchData;
    NSMutableData *joinData;
    
    NSMutableArray *groupImagesArray;
    NSOperationQueue *imageQueue;
    
}

@property (weak, nonatomic) IBOutlet UISearchBar *groupSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *searchResultsTable;
@property (nonatomic) IBOutlet UIAlertView *searchAlert;

-(void)parseSearchData;
-(void)handleSearchFail;

-(void)parseJoinData;
-(void)handleJoinFail;
-(IBAction)join:(id)sender;
@property int joiningRow;



@end
