//
//  DICHOSearchFullNameViewController.h
//  Dicho
//
//  Created by Tyler Droll on 12/20/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOSearchFullNameViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *resultsIDsArray;
    NSMutableArray *resultsNamesArray;
    NSMutableArray *resultsUsernamesArray;
    NSUserDefaults *prefs;
    
    NSURLConnection *searchConnection;    
    NSMutableData *searchData;
    
    NSMutableArray *userImagesArray;
    NSOperationQueue *imageQueue;
}

@property (weak, nonatomic) IBOutlet UISearchBar *fullNameSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *searchResultsTable;
@property (nonatomic) IBOutlet UIAlertView *searchAlert;

-(void)parseSearchData;
-(void)handleSearchFail;

@end
