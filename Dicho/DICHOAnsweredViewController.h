//
//  DICHOAnsweredViewController.h
//  Dicho
//
//  Created by Tyler Droll on 5/24/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOAnsweredViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

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
    NSMutableArray *picturesArray;
    NSMutableArray *commentsArray;
    NSUserDefaults *prefs;
    
    NSURLConnection *getDichosConnection;
    NSURLConnection *starConnection;
    
    NSMutableData *getDichosData;
    NSMutableArray *userImagesArray;
    NSOperationQueue *imageQueue;
    
}
@property (weak, nonatomic) IBOutlet UITableView *answeredTable;
-(IBAction)share:(id)sender;
@property int shareSection;
-(IBAction)starADicho:(id)sender;
-(IBAction)showThePicture:(id)sender;
@property (nonatomic) IBOutlet UIAlertView *pictureAlert;


-(IBAction)results:(id)sender;
-(IBAction)loadMore:(id)sender;

-(void)parseGetDichosData;
-(void)handleGetDichosFail;

@property BOOL loadingMore;
@property BOOL loadedAll;


-(void)handleGoodStar;
-(void)handleStarringFail;
@property int starringSection;

@property (nonatomic) IBOutlet UIAlertView *progressAlert;

-(IBAction)goToUser:(id)sender;
-(IBAction)goToComments:(id)sender;

@end
