//
//  DICHOHomeViewController.h
//  Dicho
//
//  Created by Tyler Droll on 11/28/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOHomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
    NSArray *homeNumbersStringComponents;
    
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
    NSMutableArray *picturesArray;
    NSMutableArray *commentsArray;
    NSMutableArray *anonymousArray;
    UIImage *userImage;
    NSString *username;
    NSString *name;
    NSString *dichosString;
    NSString *answerersString;
    NSString *answeringString;
    NSString *answeredString;
    NSString *favoritesString;
    NSString *groupsString;
    NSString *votingDichoID;
    NSUserDefaults *prefs;
    
    NSURLConnection *homeNumbersConnection;
    NSURLConnection *getDichosConnection;
    NSURLConnection *votingConnection;
    NSURLConnection *starConnection;
    NSURLConnection *deleteConnection;
    
    NSMutableData *homeNumbersData;
    NSMutableData *getDichosData;
    
    NSMutableArray *userImagesArray;
    NSOperationQueue *imageQueue;
    
}
@property (weak, nonatomic) IBOutlet UITableView *homeTable;

- (IBAction)goToAsking:(id)sender;
- (IBAction)goToDichos:(id)sender;
- (IBAction)goToAnswering:(id)sender;
- (IBAction)goToAnswered:(id)sender;
- (IBAction)goToFavorited:(id)sender;
- (IBAction)goToGroups:(id)sender;

-(IBAction)showThePicture:(id)sender;
@property (nonatomic) IBOutlet UIAlertView *pictureAlert;

- (IBAction)refresh:(id)sender;
@property (nonatomic, strong) IBOutlet UIRefreshControl *refreshControl;
-(void)parseHomeNumbersData;
-(void)handleHomeNumbersFail;

-(void)parseGetDichosData;
-(void)handleGetDichosFail;

-(IBAction)results:(id)sender;
-(IBAction)loadMore:(id)sender;

@property BOOL loadingMore;
@property BOOL loadedAll;

-(IBAction)voteForFirst:(id)sender;
@property (nonatomic) IBOutlet UIAlertView *firstVoteAlert;
-(IBAction)voteForSecond:(id)sender;
@property (nonatomic) IBOutlet UIAlertView *secondVoteAlert;
@property int votingSection;
-(void)handleGoodVote;
-(void)handleVotingFail;
@property BOOL votingForFirst;

-(IBAction)share:(id)sender;
@property int shareSection;
-(IBAction)starADicho:(id)sender;
-(void)handleGoodStar;
-(void)handleStarringFail;
@property int starringSection;

-(void)handleGoodDelete;
-(void)handleDeleteFail;
@property int deletingSection;

@property (nonatomic) IBOutlet UIAlertView *progressAlert;

-(IBAction)goToUser:(id)sender;
-(IBAction)goToComments:(id)sender;

@end
