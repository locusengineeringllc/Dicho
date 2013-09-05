//
//  DICHOSingleGroupViewController.h
//  Dicho
//
//  Created by Tyler Droll on 8/1/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOSingleGroupViewController : UITableViewController
{
    NSUserDefaults *prefs;
    NSString *userID;

    NSString *groupID;
    NSString *username;
    NSString *name;
    UIImage *loadedGroupImage;
    
    NSString *dichosNumber;
    NSString *membersNumber;
    NSString *adminName;
    NSString *adminID;
    NSString *memberStatus;
    BOOL isAdmin;
    BOOL loadedInfo;
    
    NSMutableArray *dichoIDsArray;
    NSMutableArray *dichosArray;
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

    NSURLConnection *infoConnection;
    NSURLConnection *getDichosConnection;
    NSURLConnection *votingConnection;
    NSURLConnection *starConnection;
    NSURLConnection *leaveGroupConnection;
    
    NSMutableData *infoData;
    NSMutableData *getDichosData;
    NSMutableArray *userImagesArray;
    NSOperationQueue *imageQueue;

}
-(id)initWithGroupName: (NSString *)givenGroupName groupID: (NSString*)givenGroupID;

- (IBAction)refresh:(id)sender;
@property (nonatomic, strong) IBOutlet UIRefreshControl *refreshControl;
-(void)parseInfoData;
-(void)handleInfoFail;

-(void)parseGetDichosData;
-(void)handleGetDichosFail;

-(IBAction)starADicho:(id)sender;
-(IBAction)showThePicture:(id)sender;
@property (nonatomic) IBOutlet UIAlertView *pictureAlert;

-(IBAction)voteForFirst:(id)sender;
@property (nonatomic) IBOutlet UIAlertView *firstVoteAlert;
-(IBAction)voteForSecond:(id)sender;
@property (nonatomic) IBOutlet UIAlertView *secondVoteAlert;
@property int votingSection;

-(IBAction)loadMore:(id)sender;


@property BOOL loadingMore;
@property BOOL loadedAll;

-(void)handleGoodVote;
-(void)handleVotingFail;
@property BOOL votingForFirst;

-(void)handleGoodStar;
-(void)handleStarringFail;
@property int starringSection;

-(void)handleGoodLeave;
-(void)handleLeaveFail;

@property (nonatomic) IBOutlet UIAlertView *progressAlert;

-(IBAction)results:(id)sender;
- (IBAction)goToMembers:(id)sender;
-(IBAction)goToSettings:(id)sender;
-(IBAction)goToAsk:(id)sender;
-(IBAction)goToUser:(id)sender;
-(IBAction)goToComments:(id)sender;

-(IBAction)leaveGroup:(id)sender;
@property (nonatomic) IBOutlet UIAlertView *leaveGroupAlert;
@property (nonatomic) IBOutlet UIAlertView *notMemberAlert;




@end
