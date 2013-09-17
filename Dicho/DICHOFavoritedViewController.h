//
//  DICHOFavoritedViewController.h
//  Dicho
//
//  Created by Tyler Droll on 5/15/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOFavoritedViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

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
    NSMutableArray *answeredsArray;
    NSMutableArray *picturesArray;
    NSMutableArray *commentsArray;

    NSURLConnection *getDichosConnection;
    NSURLConnection *votingConnection;
    
    NSMutableData *getDichosData;
    NSMutableArray *userImagesArray;
    NSOperationQueue *imageQueue;

    NSUserDefaults *prefs;
}
@property (weak, nonatomic) IBOutlet UITableView *favoritesTable;
-(IBAction)showThePicture:(id)sender;
@property (nonatomic) IBOutlet UIAlertView *pictureAlert;

-(IBAction)share:(id)sender;
@property int shareSection;

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


@property (nonatomic) IBOutlet UIAlertView *progressAlert;

-(IBAction)goToUser:(id)sender;
-(IBAction)goToComments:(id)sender;

@end
