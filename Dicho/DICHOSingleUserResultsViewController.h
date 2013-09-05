//
//  DICHOSingleUserResultsViewController.h
//  Dicho
//
//  Created by Tyler Droll on 5/13/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOSingleUserResultsViewController : UITableViewController
{
    NSUserDefaults *prefs;
    NSString *dichoID;
    NSString *dicho;
    NSString *firstAnswer;
    NSString *secondAnswer;
    NSString *firstPercent;
    NSString *secondPercent;
    NSString *firstVotes;
    NSString *secondVotes;
    NSString *totalVotes;
    NSURLConnection *resultsConnection;
    NSMutableData *resultsData;
    UIImage *screenshot;
}
-(id)initWithDichoID:(NSString*)aDichoID Dicho:(NSString*)aDicho FirstAnswer:(NSString*)aFirstAnswer SecondAnswer:(NSString*)aSecondAnswer;

@property (nonatomic) IBOutlet UIAlertView *resultsAlert;
@property (nonatomic) IBOutlet UIAlertView *shareAlert;



@property float firstWidth;
@property float secondWidth;

-(void)parseGoodResults;
-(void)handleResultsFail;

- (IBAction)share:(id)sender;

@end
