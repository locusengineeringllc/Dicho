//
//  DICHOPopularDichosViewController.h
//  Dicho
//
//  Created by Tyler Droll on 9/5/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOPopularDichosViewController : UITableViewController <UIActionSheetDelegate>
{
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
    
    NSURLConnection *getDichosConnection;
    NSURLConnection *votingConnection;
    NSURLConnection *starConnection;
    
    NSMutableData *getDichosData;
    NSMutableArray *userImagesArray;
    NSOperationQueue *imageQueue;
    
    NSUserDefaults *prefs;
}

-(IBAction)share:(id)sender;
@property int shareSection;
-(IBAction)starADicho:(id)sender;
-(IBAction)showThePicture:(id)sender;

-(IBAction)voteForFirst:(id)sender;
@property (nonatomic) IBOutlet UIAlertView *firstVoteAlert;
-(IBAction)voteForSecond:(id)sender;
@property (nonatomic) IBOutlet UIAlertView *secondVoteAlert;
@property int votingSection;

-(IBAction)results:(id)sender;

-(void)parseGetDichosData;
-(void)handleGetDichosFail;


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
