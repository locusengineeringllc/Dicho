//
//  DICHOHomeShowAnswerersViewController.h
//  Dicho
//
//  Created by Tyler Droll on 5/24/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuartzCore/QuartzCore.h"
@interface DICHOHomeShowAnswerersViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *firstNamesArray;
    NSMutableArray *secondNamesArray;
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
@property (weak, nonatomic) IBOutlet UITableView *firstAnswerersTable;
@property (weak, nonatomic) IBOutlet UITableView *secondAnswerersTable;
@property (nonatomic) IBOutlet UIAlertView *showAnswerersAlert;

-(void)parseFirstNamesData;
-(void)parseFirstLoadMoreData;

-(void)parseSecondNamesData;
-(void)parseSecondLoadMoreData;

-(void)handleConnectionFail;
@end
