//
//  DICHOSUShowAnswerersViewController.h
//  Dicho
//
//  Created by Tyler Droll on 5/13/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuartzCore/QuartzCore.h"

@interface DICHOSUShowAnswerersViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *firstNamesArray;
    NSMutableArray *firstUserIDsArray;
    NSMutableArray *secondNamesArray;
    NSMutableArray *secondUserIDsArray;
    NSUserDefaults *prefs;
    NSString *selectedDichoID;
    
    NSURLConnection *firstNamesConnection;
    NSURLConnection *firstLoadMoreConnection;
    NSURLConnection *secondNamesConnection;
    NSURLConnection *secondLoadMoreConnection;
    
    NSMutableData *firstNamesData;
    NSMutableData *firstLoadMoreData;
    NSMutableData *secondNamesData;
    NSMutableData *secondLoadMoreData;
}

-(id)initWithDichoID:(NSString*)aDichoID;

@property (nonatomic, strong) UITableView *firstAnswerersTable;
@property (nonatomic, strong) UITableView *secondAnswerersTable;

@property (nonatomic) IBOutlet UIAlertView *showAnswerersAlert;

-(void)parseFirstNamesData;
-(void)parseFirstLoadMoreData;

-(void)parseSecondNamesData;
-(void)parseSecondLoadMoreData;

-(void)handleConnectionFail;

@end
