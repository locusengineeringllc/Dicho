//
//  DICHOCommentsViewController.h
//  Dicho
//
//  Created by Tyler Droll on 8/17/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOCommentsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

{
    NSString *userID;
    NSString *selectedDichoID;
    NSMutableArray *commentsIDsArray;
    NSMutableArray *userIDsArray;
    NSMutableArray *usernamesArray;
    NSMutableArray *timesSinceArray;
    NSMutableArray *commentsArray;
    NSMutableArray *likedArray;
    NSMutableArray *numberOfLikesArray;
    
    NSUserDefaults *prefs;
    
    NSURLConnection *commentsInfosConnection;
    NSURLConnection *likingConnection;
    NSURLConnection *unlikingConnection;
    NSURLConnection *deleteConnection;
    NSURLConnection *postCommentConnection;
    
    NSMutableData *commentsInfosData;
    NSMutableData *likingData;
    NSMutableData *unlikingData;
    NSMutableData *postCommentData;
    
    
    NSMutableArray *userImagesArray;
    NSOperationQueue *imageQueue;
    
    NSString *postedComment;
    
}

-(id)initWithDichoID:(NSString*)aDichoID;
@property (strong, nonatomic) IBOutlet UITextView *commentTextView;
@property (strong, nonatomic) IBOutlet UIButton *postButton;
-(IBAction)postComment:(id)sender;
-(void)parsePostCommentData;
-(void)handlePostCommentFail;

@property (nonatomic, strong) UITableView *commentsTable;
@property BOOL loadedAll;



- (IBAction)like:(id)sender;
-(IBAction)goToLikes:(id)sender;

-(void)parseCommentsInfosData;
-(void)handleCommentsInfosFail;

-(void)parseLikingData;
-(void)parseUnlikingData;
-(void)handleLikingFail;
@property int likingRow;

-(void)handleGoodDelete;
-(void)handleDeleteFail;
@property int deletingRow;

-(IBAction)goToUser:(id)sender;

@property (nonatomic) IBOutlet UIAlertView *progressAlert;

@end
