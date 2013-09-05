//
//  DICHOSearchUsernameSelectViewController.h
//  Dicho
//
//  Created by Tyler Droll on 12/18/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOSingleUserViewController : UITableViewController
{
    BOOL answering;
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
    UIImage *userImage;
    NSString *name;
    NSString *username;
    NSString *selectedUserID;
    NSString *userID;
    NSString *dichosNumber;
    NSString *answerersNumber;
    NSString *answeringNumber;
    BOOL loadedInfo;
    NSUserDefaults *prefs;
    NSOperationQueue *imageQueue;

    
    NSURLConnection *getDichosConnection;
    NSURLConnection *answeringConnection;
    NSURLConnection *unansweringConnection;
    NSURLConnection *infoConnection;
    NSURLConnection *votingConnection;
    NSURLConnection *starConnection;
    
    NSMutableData *getDichosData;
    NSMutableData *infoData;
}
-(id)initWithUsername: (NSString *)givenUsername askerID: (NSString*)askerID;


-(IBAction)starADicho:(id)sender;
-(IBAction)showThePicture:(id)sender;
-(IBAction)answer:(id)sender;
@property (nonatomic) IBOutlet UIAlertView *pictureAlert;


-(IBAction)voteForFirst:(id)sender;
@property (nonatomic) IBOutlet UIAlertView *firstVoteAlert;
-(IBAction)voteForSecond:(id)sender;
@property (nonatomic) IBOutlet UIAlertView *secondVoteAlert;
@property int votingSection;

-(IBAction)results:(id)sender;
- (IBAction)goToAnswering:(id)sender;
- (IBAction)goToAsking:(id)sender;
-(IBAction)goToComments:(id)sender;

-(void)parseGetDichosData;
-(void)handleGetDichosFail;
-(IBAction)loadMore:(id)sender;

-(void)parseAnsweringData;
-(void)parseUnansweringData;
-(void)handleAnsweringFail;

-(void)parseInfoData;
-(void)handleInfoFail;



@property BOOL loadingMore;
@property BOOL loadedAll;

-(void)handleGoodVote;
-(void)handleVotingFail;
@property BOOL votingForFirst;

-(void)handleGoodStar;
-(void)handleStarringFail;
@property int starringSection;

@property (nonatomic) IBOutlet UIAlertView *progressAlert;


@end
