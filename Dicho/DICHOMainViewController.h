//
//  DICHOMainViewController.h
//  Dicho
//
//  Created by Tyler Droll on 9/22/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <SystemConfiguration/SystemConfiguration.h>

@interface DICHOMainViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
    NSMutableArray *dichoIDsArray;
    NSMutableArray *dichosArray;
    NSMutableArray *isGroupArray;
    NSMutableArray *askerIDsArray;
    NSMutableArray *usernamesArray;
    NSMutableArray *namesArray;
    NSMutableArray *datesArray;
    NSMutableArray *timesSinceArray;
    NSMutableArray *firstAnswersArray;
    NSMutableArray *firstVotesArray;
    NSMutableArray *secondAnswersArray;
    NSMutableArray *secondVotesArray;
    NSMutableArray *starredsArray;
    NSMutableArray *answeredsArray;
    NSMutableArray *picturesArray; //stores whether or not dicho has picture attached
    NSMutableArray *commentsArray;
    NSURLConnection *getDichosConnection;
    NSURLConnection *votingConnection;
    NSURLConnection *starConnection;
    
    NSMutableData *getDichosData;
    NSMutableArray *askerImagesArray;
    NSOperationQueue *imageQueue;
    NSUserDefaults *prefs;
}

@property (weak, nonatomic) IBOutlet UITableView *dichoTable;
- (IBAction)refresh:(id)sender;
@property (nonatomic, strong) IBOutlet UIRefreshControl *refreshControl;
-(IBAction)starADicho:(id)sender;
-(IBAction)share:(id)sender;
@property int shareSection;
-(IBAction)showThePicture:(id)sender;
@property (nonatomic) IBOutlet UIAlertView *pictureAlert;

-(IBAction)voteForFirst:(id)sender;
@property (nonatomic) IBOutlet UIAlertView *firstVoteAlert;
-(IBAction)voteForSecond:(id)sender;
@property (nonatomic) IBOutlet UIAlertView *secondVoteAlert;
@property int votingSection;

-(IBAction)results:(id)sender;
-(IBAction)loadMore:(id)sender;

-(void)parseGetDichosData;
-(void)handleGetDichosFail;


@property BOOL loadingMore;
@property BOOL loadedAll;

-(void)handleGoodVote;
-(void)handleVotingFail;
@property BOOL votingForFirst;

-(void)handleGoodStar;
-(void)handleStarringFail;
@property int starringSection;

@property (nonatomic) IBOutlet UIAlertView *progressAlert;

-(IBAction)goToUser:(id)sender;
-(IBAction)goToComments:(id)sender;

@end