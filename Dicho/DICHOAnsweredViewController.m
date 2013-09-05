//
//  DICHOAnsweredViewController.m
//  Dicho
//
//  Created by Tyler Droll on 5/24/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOAnsweredViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DICHOAsyncImageViewRound.h"
#import "DICHOSingleUserViewController.h"
#import "DICHOSingleUserResultsViewController.h"
#import "DICHOSingleGroupViewController.h"
#import "DICHOCommentsViewController.h"
#import "DICHOPictureViewController.h"

@interface DICHOAnsweredViewController ()

@end

@implementation DICHOAnsweredViewController
@synthesize answeredTable;
@synthesize pictureAlert;
@synthesize loadingMore;
@synthesize loadedAll;
@synthesize progressAlert;
@synthesize starringSection;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewDidAppear:(BOOL)animated{
    NSString *loginStatus = [prefs objectForKey:@"loggedIn"];
    NSString *firstTimeStatus = [prefs objectForKey:@"firstTimeToHome"];
    
    if([loginStatus isEqualToString:@"no"]){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else if([firstTimeStatus isEqualToString:@"yes"]){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [imageQueue setSuspended:NO];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    prefs= [NSUserDefaults standardUserDefaults];

	// Do any additional setup after loading the view.
    answeredTable.backgroundView = nil;
    answeredTable.backgroundColor = [UIColor colorWithRed:0.94 green:0.98 blue:1.0 alpha:1.0];
    answeredTable.sectionFooterHeight= 3.0;
    answeredTable.sectionHeaderHeight = 3.0;
    
    //init all arrays
    dichoIDsArray = [[NSMutableArray alloc] init];
    dichosArray = [[NSMutableArray alloc] init];
    isGroupArray = [[NSMutableArray alloc] init];
    askerIDsArray = [[NSMutableArray alloc] init];
    usernamesArray = [[NSMutableArray alloc] init];
    namesArray = [[NSMutableArray alloc] init];
    datesArray = [[NSMutableArray alloc] init];
    timesSinceArray = [[NSMutableArray alloc] init];
    firstAnswersArray = [[NSMutableArray alloc] init];
    firstVotesArray = [[NSMutableArray alloc] init];
    secondAnswersArray = [[NSMutableArray alloc] init];
    secondVotesArray = [[NSMutableArray alloc] init];
    starredsArray = [[NSMutableArray alloc] init];
    answeredsArray = [[NSMutableArray alloc] init];
    picturesArray = [[NSMutableArray alloc] init];
    commentsArray = [[NSMutableArray alloc] init];
    userImagesArray = [[NSMutableArray alloc] init];
    imageQueue = [[NSOperationQueue alloc] init];
    imageQueue.maxConcurrentOperationCount = 4;
    
    loadingMore = YES;
    self.view.userInteractionEnabled = NO;
    ///call for first dichos here
    NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/getAnsweredDichos3.php?displayedNumber=0&userID=%@", [prefs objectForKey:@"userID"]];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 10.0];
    getDichosConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == self) {
        // View is disappearing because a new view controller was pushed onto the stack
        [imageQueue setSuspended:YES];
    } else if ([viewControllers indexOfObject:self] == NSNotFound) {
        // View is disappearing because it was popped from the stack
        [imageQueue cancelAllOperations];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if([dichosArray count] == 0){
        return 0;
    }else{
        if(loadedAll == YES){
            return [dichosArray count];
        }else{
            return [dichosArray count] + 1;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section < [dichoIDsArray count]){
        return 2;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section<[dichoIDsArray count] && indexPath.row==0){
        NSString *text = [dichosArray objectAtIndex:indexPath.section];
        CGSize constraint = CGSizeMake(280, 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont fontWithName:@"ArialMT" size:16.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat height = MAX(size.height, 13.0f);
        return height + 150;
    }else return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section<[dichosArray count] && indexPath.row==0){
        static NSString *CellIdentifier = @"dichoCell";
        
        UIImageView *userImageView;
        UIButton *userImageButton;
        UILabel *usernameLabel;
        UILabel *nameLabel;
        UILabel *timeLabel;
        UILabel *questionLabel;
        UIButton *pictureButton;
        UIButton *firstAnswerButton;
        UILabel *firstVotesLabel;
        UIButton *secondAnswerButton;
        UILabel *secondVotesLabel;
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            
            userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 46, 46)];
            userImageView.tag = 5;
            userImageView.backgroundColor = [UIColor lightGrayColor];
            userImageView.contentMode = UIViewContentModeScaleAspectFill;
            userImageView.clipsToBounds = YES;
            userImageView.layer.cornerRadius = 5.0;
            [cell.contentView addSubview:userImageView];
            
            //create, format, and add userimagebutton
            UIButton *userImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
            userImageButton.tag = 11;
            [userImageButton setFrame:CGRectMake(6, 6, 46, 46)];
            userImageButton.showsTouchWhenHighlighted = YES;
            [userImageButton setTitle:nil forState:UIControlStateNormal];
            [userImageButton addTarget:self action:@selector(goToUser:) forControlEvents:UIControlEventTouchUpInside];
            if([[isGroupArray objectAtIndex:indexPath.section] isEqualToString:@"1"]){
                [userImageButton setEnabled:YES];
            }else{
                if([[usernamesArray objectAtIndex:indexPath.section] isEqualToString:@"Anonymous"]){
                    [userImageButton setEnabled:NO];
                }else{
                    userImageButton.enabled=YES;
                }
            }
            [cell.contentView addSubview:userImageButton];
            
            //create, format, and add username label
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(58, 10, 242, 21)];
            nameLabel.tag = 1;
            nameLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:13.0f];
            nameLabel.textAlignment = NSTextAlignmentLeft;
            nameLabel.textColor = [UIColor blackColor];
            nameLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:nameLabel];
            
            //create, format, and add name label
            usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(58, 26, 239, 21)];
            usernameLabel.tag = 2;
            usernameLabel.font = [UIFont fontWithName:@"ArialMT" size:13.0f];
            usernameLabel.textAlignment = NSTextAlignmentLeft;
            usernameLabel.textColor = [UIColor darkGrayColor];
            usernameLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:usernameLabel];
            
            //create, format, and add time label
            timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(227, 3, 70, 15)];
            timeLabel.tag = 3;
            timeLabel.font = [UIFont fontWithName:@"ArialMT" size:11.0f];
            timeLabel.textAlignment = NSTextAlignmentRight;
            timeLabel.textColor = [UIColor darkGrayColor];
            timeLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:timeLabel];
            
            //create, format, and add question label
            questionLabel = [[UILabel alloc] init];
            questionLabel.tag =6;
            questionLabel.numberOfLines = 0;
            [questionLabel sizeToFit];
            questionLabel.font = [UIFont fontWithName:@"ArialMT" size:16.0f];
            questionLabel.textAlignment = NSTextAlignmentLeft;
            questionLabel.textColor = [UIColor blackColor];
            questionLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:questionLabel];
            
            NSString *text = [dichosArray objectAtIndex:indexPath.section];
            CGSize constraint = CGSizeMake(280, 20000.0f);
            CGSize size = [text sizeWithFont:[UIFont fontWithName:@"ArialMT" size:16.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
            
            //create, format, and add firstVotes label
            firstVotesLabel = [[UILabel alloc] initWithFrame:CGRectMake(258, 75+MAX(size.height, 13.0f), 42, 25)];
            firstVotesLabel.tag = 12;
            firstVotesLabel.font = [UIFont fontWithName:@"ArialMT" size:14.0f];
            firstVotesLabel.adjustsFontSizeToFitWidth = YES;
            firstVotesLabel.textAlignment = NSTextAlignmentCenter;
            firstVotesLabel.textColor = [UIColor colorWithWhite:0.55 alpha:1.0];
            firstVotesLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:firstVotesLabel];
            
            UIButton *firstAnswerButton = [UIButton buttonWithType:UIButtonTypeCustom];
            firstAnswerButton.tag = 7;
            [firstAnswerButton setFrame:CGRectMake(6, 75+MAX(size.height, 13.0f), 250, 25)];
            [firstAnswerButton setTitle:[firstAnswersArray objectAtIndex:indexPath.section] forState:UIControlStateNormal];
            firstAnswerButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:16.0f];
            firstAnswerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            firstAnswerButton.layer.masksToBounds = NO;
            firstAnswerButton.layer.cornerRadius = 5.0f;
            CAGradientLayer *btnGradient = [CAGradientLayer layer];
            btnGradient.frame = firstAnswerButton.bounds;
            btnGradient.colors = [NSArray arrayWithObjects:
                                  (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                                  (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                                  nil];
            [firstAnswerButton.layer insertSublayer:btnGradient atIndex:0];
            firstAnswerButton.layer. borderWidth = 1.0;
            
            //create, format, and add secondVotes label
            secondVotesLabel = [[UILabel alloc] initWithFrame:CGRectMake(258, 110+MAX(size.height, 13.0f), 42, 25)];
            secondVotesLabel.tag = 13;
            secondVotesLabel.font = [UIFont fontWithName:@"ArialMT" size:14.0f];
            secondVotesLabel.adjustsFontSizeToFitWidth = YES;
            secondVotesLabel.textAlignment = NSTextAlignmentCenter;
            secondVotesLabel.textColor = [UIColor colorWithWhite:0.55 alpha:1.0];
            secondVotesLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:secondVotesLabel];

            
            UIButton *secondAnswerButton = [UIButton buttonWithType:UIButtonTypeCustom];
            secondAnswerButton.tag = 8;
            [secondAnswerButton setFrame:CGRectMake(6, 110+MAX(size.height, 13.0f), 250, 25)];
            [secondAnswerButton setTitle:[secondAnswersArray objectAtIndex:indexPath.section] forState:UIControlStateNormal];
            secondAnswerButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:16.0f];
            secondAnswerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            secondAnswerButton.layer.masksToBounds = NO;
            secondAnswerButton.layer.cornerRadius = 5.0f;
            CAGradientLayer *btn2Gradient = [CAGradientLayer layer];
            btn2Gradient.frame = secondAnswerButton.bounds;
            btn2Gradient.colors = [NSArray arrayWithObjects:
                                   (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                                   (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                                   nil];
            [secondAnswerButton.layer insertSublayer:btn2Gradient atIndex:0];
            secondAnswerButton.layer.borderWidth = 1.0;
            
                firstAnswerButton.enabled = NO;
                secondAnswerButton.enabled = NO;
                if([[answeredsArray objectAtIndex:indexPath.section] isEqualToString:@"1"]){
                    //do work like they voted for first
                    [firstAnswerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    firstAnswerButton.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
                    [firstAnswerButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
                    firstAnswerButton.titleLabel.shadowOffset = CGSizeMake(0.0, 1.5);
                    firstAnswerButton.layer.borderColor = [UIColor colorWithWhite:0.1 alpha:1.0].CGColor;
                    
                    [secondAnswerButton setTitleColor:[UIColor colorWithWhite:0.2 alpha:1.0] forState:UIControlStateNormal];
                    secondAnswerButton.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
                    [secondAnswerButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    secondAnswerButton.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
                    secondAnswerButton.layer.borderColor = [UIColor clearColor].CGColor;

                    
                }else{
                    //do work like they voted for second
                    [firstAnswerButton setTitleColor:[UIColor colorWithWhite:0.2 alpha:1.0] forState:UIControlStateNormal];
                    firstAnswerButton.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
                    [firstAnswerButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    firstAnswerButton.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
                    firstAnswerButton.layer.borderColor = [UIColor clearColor].CGColor;
                    
                    [secondAnswerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    secondAnswerButton.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
                    [secondAnswerButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
                    secondAnswerButton.titleLabel.shadowOffset = CGSizeMake(0.0, 1.5);
                    secondAnswerButton.layer.borderColor = [UIColor colorWithWhite:0.1 alpha:1.0].CGColor;
                    
                }
        
            [cell.contentView addSubview:firstAnswerButton];
            [cell.contentView addSubview:secondAnswerButton];
            
            //create and add picture button
            UIButton *pictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
            pictureButton.tag = 10;
            [pictureButton addTarget:self action:@selector(showThePicture:) forControlEvents:UIControlEventTouchUpInside];
            [pictureButton setFrame:CGRectMake(266, 26, 35, 28)];
            if([[picturesArray objectAtIndex:indexPath.section] isEqualToString:@"1"]){
                [pictureButton setBackgroundImage:[UIImage imageNamed:@"dicho_camera_blue.png"] forState:UIControlStateNormal];
                [pictureButton setEnabled:YES];
            }else{
                pictureButton.enabled=NO;
                [pictureButton setBackgroundImage:nil forState:UIControlStateNormal];
            }
            [cell.contentView addSubview:pictureButton];
            
        }else{
            nameLabel = (UILabel *)[cell.contentView viewWithTag:1];
            usernameLabel = (UILabel *)[cell.contentView viewWithTag:2];
            timeLabel = (UILabel *)[cell.contentView viewWithTag:3];
            userImageView = (UIImageView *)[cell.contentView viewWithTag:5];
            questionLabel = (UILabel *)[cell.contentView viewWithTag:6];
            firstAnswerButton = (UIButton *)[cell.contentView viewWithTag:7];
            secondAnswerButton = (UIButton *)[cell.contentView viewWithTag:8];
            pictureButton = (UIButton *)[cell.contentView viewWithTag:10];
            userImageButton = (UIButton *)[cell.contentView viewWithTag:11];
            firstVotesLabel = (UILabel *)[cell.contentView viewWithTag:12];
            secondVotesLabel = (UILabel *)[cell.contentView viewWithTag:13];
            
            firstAnswerButton.enabled = NO;
            secondAnswerButton.enabled = NO;
            if([[answeredsArray objectAtIndex:indexPath.section] isEqualToString:@"1"]){
                //do work like they voted for first
                [firstAnswerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                firstAnswerButton.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
                [firstAnswerButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
                firstAnswerButton.titleLabel.shadowOffset = CGSizeMake(0.0, 1.5);
                firstAnswerButton.layer.borderColor = [UIColor colorWithWhite:0.1 alpha:1.0].CGColor;
                
                [secondAnswerButton setTitleColor:[UIColor colorWithWhite:0.2 alpha:1.0] forState:UIControlStateNormal];
                secondAnswerButton.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
                [secondAnswerButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
                secondAnswerButton.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
                secondAnswerButton.layer.borderColor = [UIColor clearColor].CGColor;

                
            }else{
                //do work like they voted for second
                [firstAnswerButton setTitleColor:[UIColor colorWithWhite:0.2 alpha:1.0] forState:UIControlStateNormal];
                firstAnswerButton.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
                [firstAnswerButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
                firstAnswerButton.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
                firstAnswerButton.layer.borderColor = [UIColor clearColor].CGColor;
                
                [secondAnswerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                secondAnswerButton.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
                [secondAnswerButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
                secondAnswerButton.titleLabel.shadowOffset = CGSizeMake(0.0, 1.5);
                secondAnswerButton.layer.borderColor = [UIColor colorWithWhite:0.1 alpha:1.0].CGColor;
                
            }
            
            if([[picturesArray objectAtIndex:indexPath.section] isEqualToString:@"1"]){
                [pictureButton setEnabled:YES];
                [pictureButton setBackgroundImage:[UIImage imageNamed:@"dicho_camera_blue.png"] forState:UIControlStateNormal];
            }else{
                pictureButton.enabled=NO;
                [pictureButton setBackgroundImage:nil forState:UIControlStateNormal];
            }
            
            if([[isGroupArray objectAtIndex:indexPath.section] isEqualToString:@"1"]){
                [userImageButton setEnabled:YES];
            }else{
                if([[usernamesArray objectAtIndex:indexPath.section] isEqualToString:@"Anonymous"]){
                    [userImageButton setEnabled:NO];
                }else{
                    userImageButton.enabled=YES;
                }
            }

        }
        
        
        userImageView.image = [userImagesArray objectAtIndex:indexPath.section];
        nameLabel.text = [namesArray objectAtIndex:indexPath.section];
        usernameLabel.text = [NSString stringWithFormat:@"@%@", [usernamesArray objectAtIndex:indexPath.section]];
        timeLabel.text = [timesSinceArray objectAtIndex:indexPath.section];
        
        questionLabel.text =[dichosArray objectAtIndex:indexPath.section];
        NSString *text = [dichosArray objectAtIndex:indexPath.section];
        CGSize constraint = CGSizeMake(280, 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont fontWithName:@"ArialMT" size:16.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        [questionLabel setFrame:CGRectMake(6, 65, 288, MAX(size.height, 13.0f))];
        
        [firstVotesLabel setFrame:CGRectMake(258, 75+MAX(size.height, 13.0f), 42, 25)];
        [secondVotesLabel setFrame:CGRectMake(258, 110+MAX(size.height, 13.0f), 42, 25)];
        firstVotesLabel.text = [firstVotesArray objectAtIndex:indexPath.section];
        secondVotesLabel.text = [secondVotesArray objectAtIndex:indexPath.section];
        
        [firstAnswerButton setTitle:[firstAnswersArray objectAtIndex:indexPath.section] forState:UIControlStateNormal];
        [firstAnswerButton setFrame:CGRectMake(6, 75+MAX(size.height, 13.0f), 250, 25)];
        
        
        [secondAnswerButton setTitle:[secondAnswersArray objectAtIndex:indexPath.section] forState:UIControlStateNormal];
        [secondAnswerButton setFrame:CGRectMake(6, 110+MAX(size.height, 13.0f), 250, 25)];
        
        [pictureButton setFrame:CGRectMake(266, 26, 35, 28)];
        [userImageButton setFrame:CGRectMake(6, 6, 46, 46)];
        
        return cell;
        
        
    }else if(indexPath.section<[dichosArray count] && indexPath.row==1){
        static NSString *CellIdentifier = @"questionInfoCell";
        
        UILabel *dateLabel;
        UIButton *starButton;
        UIButton *resultsButton;
        UIButton *commentsButton;
        UILabel *commentsLabel;
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 10, 80, 21)];
            dateLabel.tag = 1;
            dateLabel.font = [UIFont fontWithName:@"ArialMT" size:14.0f];
            dateLabel.textAlignment = NSTextAlignmentLeft;
            dateLabel.textColor = [UIColor darkGrayColor];
            [cell.contentView addSubview:dateLabel];
            
            //create, position, and add reask button
            commentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
            commentsButton.tag = 2;
            [commentsButton addTarget:self action:@selector(goToComments:) forControlEvents:UIControlEventTouchUpInside];
            [commentsButton setFrame:CGRectMake(94, 0, 44, 44)];
            [commentsButton setImage:[UIImage imageNamed:@"comment_filled.png"] forState:UIControlStateNormal];
            [cell.contentView addSubview:commentsButton];
            
            commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(94, 2, 44, 37)];
            commentsLabel.tag = 3;
            commentsLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:14.0f];
            commentsLabel.textAlignment = NSTextAlignmentCenter;
            commentsLabel.textColor = [UIColor whiteColor];
            commentsLabel.shadowColor = [UIColor blackColor];
            commentsLabel.shadowOffset = CGSizeMake(0.0, 1.0);
            commentsLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:commentsLabel];
            int commentsCount = [[commentsArray objectAtIndex:indexPath.section] intValue];
            if(commentsCount>999)
                commentsLabel.text = @"999+";
            else
                commentsLabel.text = [NSString stringWithFormat:@"%@", [commentsArray objectAtIndex:indexPath.section]];
            
            
            resultsButton = [UIButton buttonWithType:UIButtonTypeCustom];
            resultsButton.tag = 4;
            [resultsButton setFrame:CGRectMake(166, 7, 70, 30)];
            [resultsButton addTarget:self action:@selector(results:) forControlEvents:UIControlEventTouchUpInside];
            [resultsButton setImage:[UIImage imageNamed:@"results_filled.png"] forState:UIControlStateNormal];
            [cell.contentView addSubview:resultsButton];
            
            
            //create, position, and add star button
            starButton = [UIButton buttonWithType:UIButtonTypeCustom];
            starButton.tag = 5;
            [starButton addTarget:self action:@selector(starADicho:) forControlEvents:UIControlEventTouchUpInside];
            [starButton setFrame:CGRectMake(256, 6, 32, 32)];
            [starButton setUserInteractionEnabled:NO];
            if([[starredsArray objectAtIndex:indexPath.section] isEqualToString:@"1"]){
                [starButton setImage:[UIImage imageNamed:@"favorite_filled.png"] forState:UIControlStateNormal];
                [starButton setUserInteractionEnabled:NO];
             }else{
                 [starButton setImage:[UIImage imageNamed:@"favorite_empty.png"] forState:UIControlStateNormal];
                 starButton.userInteractionEnabled = YES;
             }
            [cell.contentView addSubview:starButton];
            
        }else{
            dateLabel = (UILabel *)[cell.contentView viewWithTag:1];
            commentsButton = (UIButton *)[cell.contentView viewWithTag:2];
            commentsLabel = (UILabel *)[cell.contentView viewWithTag:3];
            resultsButton = (UIButton *)[cell.contentView viewWithTag:4];
            starButton = (UIButton *)[cell.contentView viewWithTag:5];

            
            //working version
             if([[starredsArray objectAtIndex:indexPath.section] isEqualToString:@"1"]){
                 [starButton setImage:[UIImage imageNamed:@"favorite_filled.png"] forState:UIControlStateNormal];
                 starButton.userInteractionEnabled=NO;
             }else{
                [starButton setImage:[UIImage imageNamed:@"favorite_empty.png"] forState:UIControlStateNormal];
                 starButton.userInteractionEnabled = YES;
             }
        }
        
        dateLabel.text = [NSString stringWithFormat:@"%@", [datesArray objectAtIndex:indexPath.section]];
        
        int commentsCount = [[commentsArray objectAtIndex:indexPath.section] intValue];
        if(commentsCount>999)
            commentsLabel.text = @"999+";
        else
            commentsLabel.text = [NSString stringWithFormat:@"%@", [commentsArray objectAtIndex:indexPath.section]];
        
        return cell;
    }else{
        static NSString *CellIdentifier = @"bottomCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];            
        }
        
        return cell;
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    float reload_distance = 30;
    if(y > h - reload_distance) {
        [self loadMore:self];
    }
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if(connection==getDichosConnection){
        getDichosData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(connection==getDichosConnection){
        [getDichosData appendData:data];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(connection==starConnection){
        [self handleGoodStar];
    }else if(connection==getDichosConnection){
        [self parseGetDichosData];
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if(connection==starConnection){
        [self handleStarringFail];
    }else if(connection==getDichosConnection){
        [self handleGetDichosFail];
    }
}

-(void)parseGetDichosData{
    NSString *returnedString = [[NSString alloc] initWithData:getDichosData encoding: NSUTF8StringEncoding];
    returnedString = [returnedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([returnedString isEqualToString:@""]){
        loadedAll=YES;
        loadingMore = NO;
        [answeredTable reloadData];
        self.view.userInteractionEnabled = YES;
    }else{
        int existingSections = [dichoIDsArray count];

        //////break down dichos data!!!
        NSArray *infoArray = [returnedString componentsSeparatedByString:@"|"];
        for(int i=0; i<infoArray.count-1; i=i+15){
            [dichoIDsArray addObject:[infoArray objectAtIndex:i]];
            [dichosArray addObject:[infoArray objectAtIndex:i+1]];
            [firstAnswersArray addObject:[infoArray objectAtIndex:i+2]];
            [secondAnswersArray addObject:[infoArray objectAtIndex:i+3]];
            [isGroupArray addObject:[infoArray objectAtIndex:i+5]];
            [askerIDsArray addObject:[infoArray objectAtIndex:i+6]];
            [namesArray addObject:[infoArray objectAtIndex:i+7]];
            [usernamesArray addObject:[infoArray objectAtIndex:i+8]];
            [starredsArray addObject:[infoArray objectAtIndex:i+9]];
            [answeredsArray addObject:[infoArray objectAtIndex:i+10]];
            [picturesArray addObject:[infoArray objectAtIndex:i+11]];
            [firstVotesArray addObject:[infoArray objectAtIndex:i+12]];
            [secondVotesArray addObject:[infoArray objectAtIndex:i+13]];
            [commentsArray addObject:[infoArray objectAtIndex:i+14]];
            [userImagesArray addObject:[UIImage imageNamed:@"dichoTabBarIcon.png"]];

            //do date stuff
            NSArray *dateAndTimeParts = [[infoArray objectAtIndex:i+4] componentsSeparatedByString:@" "];
            NSString *date = [dateAndTimeParts objectAtIndex:0];
            NSArray *dateParts = [date componentsSeparatedByString:@"-"];
            
            //format and add date like 12/17/12
            NSString *fullYear = [dateParts objectAtIndex:0];
            NSString *endOfYear = [fullYear substringWithRange:NSMakeRange(2, 2)];
            NSString *formattedDate = [NSString stringWithFormat:@"%@/%@/%@", [dateParts objectAtIndex:1], [dateParts objectAtIndex:2], endOfYear];
            [datesArray addObject:formattedDate];
            
            
            NSString *dichoDateString = [infoArray objectAtIndex:i+4];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:-14400]];
            NSDate *dichoDate = [formatter dateFromString:dichoDateString];
            NSDate *nowDate = [NSDate date];
            double secondsBetween = [nowDate timeIntervalSinceDate:dichoDate];
            //less than a minute
            if (secondsBetween < 60)
            {
                int seconds = round(secondsBetween / 1);
                [timesSinceArray addObject: [NSString stringWithFormat:@"%ds", seconds]];
            }
            //entered minutes range
            else if (secondsBetween < 3600)
            {
                int diff = round(secondsBetween / 60);
                [timesSinceArray addObject:[NSString stringWithFormat:@"%dm", diff]];
            }
            //entering hours range
            else if (secondsBetween < 86400)
            {
                int diff = round(secondsBetween / 60 / 60);
                [timesSinceArray addObject:[NSString stringWithFormat:@"%dh", diff]];
            }
            //otherwise we have entered days
            else if (secondsBetween < 604800)
            {
                int diff = round(secondsBetween / 60 / 60 / 24);
                [timesSinceArray addObject:[NSString stringWithFormat:@"%dd", diff]];
            }
            else //if(ti<31556916)
            {
                int diff = round(secondsBetween / 60 / 60 / 24 / 7);
                [timesSinceArray addObject:[NSString stringWithFormat:@"%dw", diff]];
            }
        }
        
        //cycled through all returned data, now what...
        [answeredTable reloadData];
        loadingMore = NO;
        self.view.userInteractionEnabled = YES;
        for(int i=existingSections; i<[dichoIDsArray count]; i++){
            
            NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                    selector:@selector(loadUserImage:)
                                                                                      object:[NSNumber numberWithInt:i]];
            [imageQueue addOperation:operation];
            
        }
    }
}

-(void)loadUserImage:(NSNumber*)aSectionNumber{
    int sectionNumber = [aSectionNumber intValue];
    NSURL *imageURL;
    if([[isGroupArray objectAtIndex:sectionNumber] isEqualToString:@"1"]){
        imageURL= [NSURL URLWithString:[NSString stringWithFormat:@"http://dichoapp.com/groupImages/%@.jpeg", [askerIDsArray objectAtIndex:sectionNumber]]];
    }else{
        if([[usernamesArray objectAtIndex:sectionNumber] isEqualToString:@"Anonymous"]){
            imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://dichoapp.com/userImages/0.jpeg"]];
        }else{
            imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://dichoapp.com/userImages/%@.jpeg", [askerIDsArray objectAtIndex:sectionNumber]]];
        }
    }
    
    NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
    
    if(imageData != nil){
        UIImage * image = [UIImage imageWithData:imageData];
        
        //resize image to let tableview scroll more smoothly
        CGFloat widthFactor = image.size.width/47;
        CGFloat heightFactor = image.size.height/47;
        CGFloat scaleFactor;
        
        if(widthFactor<heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        CGSize desiredSize = CGSizeMake(image.size.width/scaleFactor, image.size.height/scaleFactor);
        UIGraphicsBeginImageContextWithOptions(desiredSize, NO, 0.0);
        [image drawInRect:CGRectMake(0,0,desiredSize.width,desiredSize.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [userImagesArray replaceObjectAtIndex:sectionNumber withObject:newImage];
        
        NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:sectionNumber];
        NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
        
        [self.answeredTable performSelectorOnMainThread:@selector(reloadRowsAtIndexPaths:withRowAnimation:) withObject:rowsToReload waitUntilDone:NO];
    }
}


-(void)handleGetDichosFail{
    self.view.userInteractionEnabled = YES;
    loadingMore = NO;
    UIAlertView *refreshFail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [refreshFail show];
    
}

-(IBAction)loadMore:(id)sender{
    if(loadedAll==NO){
        if(loadingMore == NO){
            loadingMore = YES;
            self.view.userInteractionEnabled = NO;

            //call php with most recent to get back list of new dichos
            NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/getAnsweredDichos3.php?displayedNumber=%d&userID=%@",[dichoIDsArray count], [prefs objectForKey:@"userID"]];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
            getDichosConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        }
    }
}


- (IBAction)starADicho:(id)sender {
    //get indexpath
    progressAlert= [[UIAlertView alloc] initWithTitle:nil message:@"Favoriting..." delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [progressAlert show];
    NSIndexPath *indexPath = [answeredTable indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    starringSection = indexPath.section;
    
    //add star in database
    NSString *strURL = [NSString stringWithFormat: @"http://dichoapp.com/files/addStar.php?dichoID=%@&userID=%@", [dichoIDsArray objectAtIndex:indexPath.section], [prefs objectForKey:@"userID"]];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    starConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

-(void)handleGoodStar{
    [starredsArray replaceObjectAtIndex:starringSection withObject:@"1"];
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:1 inSection:starringSection];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [answeredTable reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)handleStarringFail{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *starringFail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection and try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [starringFail show];
}

- (IBAction)showThePicture:(id)sender {
   /* pictureAlert= [[UIAlertView alloc] initWithTitle:nil message:@"\n\n\n\n\n\n\n\n\n\n\n\n\n" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [pictureAlert show]; */
    NSIndexPath *indexPath = [self.answeredTable indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];

    
    DICHOPictureViewController *pictureView = [[DICHOPictureViewController alloc] initWithDichoID:[dichoIDsArray objectAtIndex:indexPath.section]];
    [pictureView setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:pictureView animated:YES completion:NULL];
   /* UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 265, 285)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    NSString *imageUrl= [NSString stringWithFormat:@"http://dichoapp.com/dichoImages/%@.jpeg", [dichoIDsArray objectAtIndex:indexPath.section]];
    UIImage *dichoImage = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString:imageUrl]]];
    imageView.image = dichoImage;
    imageView.backgroundColor=[UIColor clearColor];
    [pictureAlert addSubview:imageView];*/
}


-(IBAction)results:(id)sender{
    NSIndexPath *indexPath = [self.answeredTable indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    
    
    DICHOSingleUserResultsViewController *nextVC = [[DICHOSingleUserResultsViewController alloc] initWithDichoID:[dichoIDsArray objectAtIndex:indexPath.section] Dicho:[dichosArray objectAtIndex:indexPath.section] FirstAnswer:[firstAnswersArray objectAtIndex:indexPath.section] SecondAnswer:[secondAnswersArray objectAtIndex:indexPath.section]];
    [self.navigationController pushViewController:nextVC animated:YES];
}

-(IBAction)goToUser:(id)sender{
    NSIndexPath *indexPath = [self.answeredTable indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    
    if([[isGroupArray objectAtIndex:indexPath.section] isEqualToString:@"1"]){
        ////go to group
        DICHOSingleGroupViewController *nextVC = [[DICHOSingleGroupViewController alloc] initWithGroupName:[namesArray objectAtIndex:indexPath.section] groupID:[askerIDsArray objectAtIndex:indexPath.section]];
        [self.navigationController pushViewController:nextVC animated:YES];
    }else{
        ////go to single user
        DICHOSingleUserViewController *nextVC = [[DICHOSingleUserViewController alloc] initWithUsername: [usernamesArray objectAtIndex:indexPath.section] askerID:[askerIDsArray objectAtIndex:indexPath.section]];
        [self.navigationController pushViewController:nextVC animated:YES];
    }
    
}

-(IBAction)goToComments:(id)sender{
    NSIndexPath *indexPath = [answeredTable indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    DICHOCommentsViewController *nextVC = [[DICHOCommentsViewController alloc] initWithDichoID:[dichoIDsArray objectAtIndex:indexPath.section]];
    [self.navigationController pushViewController:nextVC animated:YES];
}

@end

