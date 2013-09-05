//
//  DICHOPopularDichosViewController.m
//  Dicho
//
//  Created by Tyler Droll on 9/5/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOPopularDichosViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DICHOSingleUserViewController.h"
#import "DICHOSingleUserResultsViewController.h"
#import "DICHOSingleGroupViewController.h"
#import "DICHOCommentsViewController.h"
#import "DICHOPictureViewController.h"

@interface DICHOPopularDichosViewController ()

@end

@implementation DICHOPopularDichosViewController
@synthesize firstVoteAlert;
@synthesize secondVoteAlert;
@synthesize votingSection;
@synthesize votingForFirst;
@synthesize starringSection;
@synthesize progressAlert;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewDidAppear:(BOOL)animated{
    NSString *loginStatus = [prefs objectForKey:@"loggedIn"];
    NSString *firstTimeStatus = [prefs objectForKey:@"firstTimeToSearch"];
    
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
    self.tableView.sectionFooterHeight= 3.0;
    self.tableView.sectionHeaderHeight = 3.0;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.94 green:0.98 blue:1.0 alpha:1.0];
    
    //init all arrays
    dichoIDsArray = [[NSMutableArray alloc] init];
    dichosArray = [[NSMutableArray alloc] init];
    askerIDsArray = [[NSMutableArray alloc] init];
    usernamesArray = [[NSMutableArray alloc] init];
    namesArray = [[NSMutableArray alloc] init];
    datesArray = [[NSMutableArray alloc] init];
    timesSinceArray = [[NSMutableArray alloc] init];
    firstAnswersArray = [[NSMutableArray alloc] init];
    firstVotesArray = [[NSMutableArray alloc] init];
    secondAnswersArray = [[NSMutableArray alloc] init];
    secondVotesArray = [[NSMutableArray alloc] init];
    answeredsArray = [[NSMutableArray alloc] init];
    starredsArray = [[NSMutableArray alloc] init];
    picturesArray = [[NSMutableArray alloc] init];
    commentsArray = [[NSMutableArray alloc] init];
    userImagesArray = [[NSMutableArray alloc] init];
    imageQueue = [[NSOperationQueue alloc] init];
    imageQueue.maxConcurrentOperationCount = 5;
    
    self.view.userInteractionEnabled = NO;
    ///call for first dichos here
    NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/getPopularDichos.php?userID=%@", [prefs objectForKey:@"userID"]];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([dichosArray count] == 0){
        return 0;
    }else{
        return [dichosArray count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0){
        NSString *text = [dichosArray objectAtIndex:indexPath.section];
        CGSize constraint = CGSizeMake(280, 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont fontWithName:@"ArialMT" size:16.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat height = MAX(size.height, 13.0f);
        return height + 150;
    }else return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row==0){
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
            
            userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 6, 46, 46)];
            userImageView.tag = 5;
            userImageView.backgroundColor = [UIColor lightGrayColor];
            userImageView.contentMode = UIViewContentModeScaleAspectFill;
            userImageView.clipsToBounds = YES;
            userImageView.layer.cornerRadius = 5.0;
            [cell.contentView addSubview:userImageView];
            
            //create, format, and add userimagebutton
            UIButton *userImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
            userImageButton.tag = 11;
            [userImageButton setFrame:CGRectMake(10, 6, 46, 46)];
            userImageButton.showsTouchWhenHighlighted = YES;
            [userImageButton setTitle:nil forState:UIControlStateNormal];
            [userImageButton addTarget:self action:@selector(goToUser:) forControlEvents:UIControlEventTouchUpInside];
            
            if([[usernamesArray objectAtIndex:indexPath.section] isEqualToString:@"Anonymous"]){
                [userImageButton setEnabled:NO];
            }else{
                userImageButton.enabled=YES;
            }
            [cell.contentView addSubview:userImageButton];
            
            //create, format, and add username label
            //nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 10, 242, 21)];//////original
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 10, 219, 21)];
            nameLabel.tag = 1;
            nameLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:13.0f];
            nameLabel.textAlignment = NSTextAlignmentLeft;
            nameLabel.textColor = [UIColor blackColor];
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.adjustsFontSizeToFitWidth = YES;
            [cell.contentView addSubview:nameLabel];
            
            //create, format, and add name label
            //usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 26, 239, 21)]; ////original
            usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 26, 219, 21)];
            
            usernameLabel.tag = 2;
            usernameLabel.font = [UIFont fontWithName:@"ArialMT" size:13.0f];
            usernameLabel.textAlignment = NSTextAlignmentLeft;
            usernameLabel.textColor = [UIColor colorWithWhite:0.55 alpha:1.0];
            usernameLabel.backgroundColor = [UIColor clearColor];
            usernameLabel.adjustsFontSizeToFitWidth = YES;
            [cell.contentView addSubview:usernameLabel];
            
            //create, format, and add time label
            timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(247, 3, 70, 15)];
            timeLabel.tag = 3;
            timeLabel.font = [UIFont fontWithName:@"ArialMT" size:11.0f];
            timeLabel.textAlignment = NSTextAlignmentRight;
            timeLabel.textColor = [UIColor colorWithWhite:0.55 alpha:1.0];
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
            CGSize constraint = CGSizeMake(292, 20000.0f);
            CGSize size = [text sizeWithFont:[UIFont fontWithName:@"ArialMT" size:16.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
            
            //create, format, and add firstVotes label
            firstVotesLabel = [[UILabel alloc] initWithFrame:CGRectMake(277, 75+MAX(size.height, 13.0f), 41, 25)]; //262x and center
            firstVotesLabel.tag = 12;
            firstVotesLabel.font = [UIFont fontWithName:@"ArialMT" size:16.0f];
            firstVotesLabel.adjustsFontSizeToFitWidth = YES;
            firstVotesLabel.textAlignment = NSTextAlignmentCenter;
            firstVotesLabel.textColor = [UIColor colorWithWhite:0.55 alpha:1.0];
            firstVotesLabel.backgroundColor = [UIColor whiteColor];
            //firstVotesLabel.text = @"42";
            [cell.contentView addSubview:firstVotesLabel];
            
            UIButton *firstAnswerButton = [UIButton buttonWithType:UIButtonTypeCustom];
            firstAnswerButton.tag = 7;
            [firstAnswerButton setFrame:CGRectMake(25, 75+MAX(size.height, 13.0f), 250, 25)]; ////10x, 250w
            [firstAnswerButton setTitle:[firstAnswersArray objectAtIndex:indexPath.section] forState:UIControlStateNormal];
            firstAnswerButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:16.0f];
            firstAnswerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            [firstAnswerButton addTarget:self action:@selector(voteForFirst:) forControlEvents:UIControlEventTouchUpInside];
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
            firstAnswerButton.showsTouchWhenHighlighted = YES;
            
            //create, format, and add secondVotes label
            secondVotesLabel = [[UILabel alloc] initWithFrame:CGRectMake(277, 110+MAX(size.height, 13.0f), 41, 25)];
            secondVotesLabel.tag = 13;
            secondVotesLabel.font = [UIFont fontWithName:@"ArialMT" size:16.0f];
            secondVotesLabel.adjustsFontSizeToFitWidth = YES;
            secondVotesLabel.textAlignment = NSTextAlignmentCenter;
            secondVotesLabel.textColor = [UIColor colorWithWhite:0.55 alpha:1.0];
            secondVotesLabel.backgroundColor = [UIColor whiteColor];
            [cell.contentView addSubview:secondVotesLabel];
            
            UIButton *secondAnswerButton = [UIButton buttonWithType:UIButtonTypeCustom];
            secondAnswerButton.tag = 8;
            [secondAnswerButton setFrame:CGRectMake(25, 110+MAX(size.height, 13.0f), 250, 25)]; ////10x, 250w
            [secondAnswerButton setTitle:[secondAnswersArray objectAtIndex:indexPath.section] forState:UIControlStateNormal];
            secondAnswerButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:16.0f];
            secondAnswerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            [secondAnswerButton addTarget:self action:@selector(voteForSecond:) forControlEvents:UIControlEventTouchUpInside];
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
            secondAnswerButton.showsTouchWhenHighlighted = YES;
            
            //set enabled and colors
            if([[answeredsArray objectAtIndex:indexPath.section] isEqualToString:@"0"]){
                firstAnswerButton.enabled = YES;
                secondAnswerButton.enabled = YES;
                [firstAnswerButton setTitleColor:[UIColor colorWithWhite:0.2 alpha:1.0] forState:UIControlStateNormal];
                firstAnswerButton.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
                [firstAnswerButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
                firstAnswerButton.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
                firstAnswerButton.layer.borderColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0].CGColor;
                
                [secondAnswerButton setTitleColor:[UIColor colorWithWhite:0.2 alpha:1.0] forState:UIControlStateNormal];
                secondAnswerButton.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
                [secondAnswerButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
                secondAnswerButton.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
                secondAnswerButton.layer.borderColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0].CGColor;
                
                firstVotesLabel.text = @"";
                secondVotesLabel.text = @"";
                
                
            }else{
                firstAnswerButton.enabled = NO;
                secondAnswerButton.enabled = NO;
                firstVotesLabel.text = [firstVotesArray objectAtIndex:indexPath.section];
                secondVotesLabel.text = [secondVotesArray objectAtIndex:indexPath.section];
                
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
            }
            [cell.contentView addSubview:firstAnswerButton];
            [cell.contentView addSubview:secondAnswerButton];
            
            //create and add picture button
            UIButton *pictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
            pictureButton.tag = 10;
            [pictureButton addTarget:self action:@selector(showThePicture:) forControlEvents:UIControlEventTouchUpInside];
            [pictureButton setFrame:CGRectMake(286, 26, 35, 28)]; ////original
            [pictureButton setFrame:CGRectMake(281, 24, 40, 32)];
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
            
            //set enabled and colors
            if([[answeredsArray objectAtIndex:indexPath.section] isEqualToString:@"0"]){
                firstAnswerButton.enabled = YES;
                secondAnswerButton.enabled = YES;
                [firstAnswerButton setTitleColor:[UIColor colorWithWhite:0.2 alpha:1.0] forState:UIControlStateNormal];
                firstAnswerButton.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
                [firstAnswerButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
                firstAnswerButton.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
                firstAnswerButton.layer.borderColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0].CGColor;
                
                [secondAnswerButton setTitleColor:[UIColor colorWithWhite:0.2 alpha:1.0] forState:UIControlStateNormal];
                secondAnswerButton.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
                [secondAnswerButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
                secondAnswerButton.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
                secondAnswerButton.layer.borderColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0].CGColor;
                
                firstVotesLabel.text = @"";
                secondVotesLabel.text = @"";
                
            }else{
                firstAnswerButton.enabled = NO;
                secondAnswerButton.enabled = NO;
                firstVotesLabel.text = [firstVotesArray objectAtIndex:indexPath.section];
                secondVotesLabel.text = [secondVotesArray objectAtIndex:indexPath.section];
                
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
            }
            
            
            
            if([[picturesArray objectAtIndex:indexPath.section] isEqualToString:@"1"]){
                [pictureButton setEnabled:YES];
                [pictureButton setBackgroundImage:[UIImage imageNamed:@"dicho_camera_blue.png"] forState:UIControlStateNormal];
                
            }else{
                pictureButton.enabled=NO;
                [pictureButton setBackgroundImage:nil forState:UIControlStateNormal];
            }
            
            
            if([[usernamesArray objectAtIndex:indexPath.section] isEqualToString:@"Anonymous"]){
                [userImageButton setEnabled:NO];
            }else{
                userImageButton.enabled=YES;
            }
            
        }
        
        
        userImageView.image = [userImagesArray objectAtIndex:indexPath.section];
        nameLabel.text = [namesArray objectAtIndex:indexPath.section];
        usernameLabel.text = [NSString stringWithFormat:@"@%@", [usernamesArray objectAtIndex:indexPath.section]];
        timeLabel.text = [timesSinceArray objectAtIndex:indexPath.section];
        
        questionLabel.text =[dichosArray objectAtIndex:indexPath.section];
        NSString *text = [dichosArray objectAtIndex:indexPath.section];
        CGSize constraint = CGSizeMake(292, 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont fontWithName:@"ArialMT" size:16.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        [questionLabel setFrame:CGRectMake(10, 65, 300, MAX(size.height, 13.0f))];
        
        [firstVotesLabel setFrame:CGRectMake(277, 75+MAX(size.height, 13.0f), 41, 25)];
        [secondVotesLabel setFrame:CGRectMake(277, 110+MAX(size.height, 13.0f), 41, 25)];
        
        [firstAnswerButton setTitle:[firstAnswersArray objectAtIndex:indexPath.section] forState:UIControlStateNormal];
        [firstAnswerButton setFrame:CGRectMake(25, 75+MAX(size.height, 13.0f), 250, 25)]; /////10x, 250w
        
        [secondAnswerButton setTitle:[secondAnswersArray objectAtIndex:indexPath.section] forState:UIControlStateNormal];
        [secondAnswerButton setFrame:CGRectMake(25, 110+MAX(size.height, 13.0f), 250, 25)]; /////10x, 250w
        
        [pictureButton setFrame:CGRectMake(286, 26, 35, 28)]; ////original
        [pictureButton setFrame:CGRectMake(281, 24, 40, 32)];
        
        [userImageButton setFrame:CGRectMake(10, 6, 46, 46)];
        
        return cell;
        
    }else{
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
            
            //create, position, and add date label
            dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 10, 80, 21)];
            dateLabel.tag = 1;
            dateLabel.font = [UIFont fontWithName:@"ArialMT" size:14.0f];
            dateLabel.textAlignment = NSTextAlignmentLeft;
            dateLabel.textColor = [UIColor darkGrayColor];
            [cell.contentView addSubview:dateLabel];
            
            //create, position, and add comments button and then label
            commentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
            commentsButton.tag = 2;
            [commentsButton addTarget:self action:@selector(goToComments:) forControlEvents:UIControlEventTouchUpInside];
            [commentsButton setFrame:CGRectMake(94, 0, 44, 44)];
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
            
            //create, position, and add results button
            resultsButton = [UIButton buttonWithType:UIButtonTypeCustom];
            resultsButton.tag = 4;
            [resultsButton setFrame:CGRectMake(166, 7, 70, 30)];
            
            [resultsButton addTarget:self action:@selector(results:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:resultsButton];
            
            
            
            if([[answeredsArray objectAtIndex:indexPath.section] isEqualToString:@"0"]){
                resultsButton.userInteractionEnabled = NO;
                [resultsButton setImage:[UIImage imageNamed:@"results_empty.png"] forState:UIControlStateNormal];
                
                commentsButton.userInteractionEnabled = NO;
                [commentsButton setImage:[UIImage imageNamed:@"comment_empty.png"] forState:UIControlStateNormal];
                
                commentsLabel.text = @"";
            }else{
                resultsButton.userInteractionEnabled = YES;
                [resultsButton setImage:[UIImage imageNamed:@"results_filled.png"] forState:UIControlStateNormal];
                
                commentsButton.userInteractionEnabled = YES;
                [commentsButton setImage:[UIImage imageNamed:@"comment_filled.png"] forState:UIControlStateNormal];
                int commentsCount = [[commentsArray objectAtIndex:indexPath.section] intValue];
                if(commentsCount>999)
                    commentsLabel.text = @"999+";
                else
                    commentsLabel.text = [NSString stringWithFormat:@"%@", [commentsArray objectAtIndex:indexPath.section]];
            }
            
            //create, position, and add star button
            starButton = [UIButton buttonWithType:UIButtonTypeCustom];
            starButton.tag = 5;
            [starButton addTarget:self action:@selector(starADicho:) forControlEvents:UIControlEventTouchUpInside];
            [starButton setFrame:CGRectMake(256, 6, 32, 32)];
            
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
            
            if([[answeredsArray objectAtIndex:indexPath.section] isEqualToString:@"0"]){
                resultsButton.userInteractionEnabled = NO;
                [resultsButton setImage:[UIImage imageNamed:@"results_empty.png"] forState:UIControlStateNormal];
                
                commentsButton.userInteractionEnabled = NO;
                [commentsButton setImage:[UIImage imageNamed:@"comment_empty.png"] forState:UIControlStateNormal];
                commentsLabel.text = @"";
            }else{
                resultsButton.userInteractionEnabled = YES;
                [resultsButton setImage:[UIImage imageNamed:@"results_filled.png"] forState:UIControlStateNormal];
                
                commentsButton.userInteractionEnabled = YES;
                [commentsButton setImage:[UIImage imageNamed:@"comment_filled.png"] forState:UIControlStateNormal];
                int commentsCount = [[commentsArray objectAtIndex:indexPath.section] intValue];
                if(commentsCount>999)
                    commentsLabel.text = @"999+";
                else
                    commentsLabel.text = [NSString stringWithFormat:@"%@", [commentsArray objectAtIndex:indexPath.section]];
            }
            
            if([[starredsArray objectAtIndex:indexPath.section] isEqualToString:@"1"]){
                [starButton setImage:[UIImage imageNamed:@"favorite_filled.png"] forState:UIControlStateNormal];
                starButton.userInteractionEnabled=NO;
            }else{
                [starButton setImage:[UIImage imageNamed:@"favorite_empty.png"] forState:UIControlStateNormal];
                starButton.userInteractionEnabled = YES;
            }
        }
        
        dateLabel.text = [NSString stringWithFormat:@"%@", [datesArray objectAtIndex:indexPath.section]];
        return cell;
        
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
    }else if(connection==votingConnection){
        [self handleGoodVote];
    }else if(connection==getDichosConnection){
        [self parseGetDichosData];
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if(connection==starConnection){
        [self handleStarringFail];
    }else if(connection==votingConnection){
        [self handleVotingFail];
    }else if(connection==getDichosConnection){
        [self handleGetDichosFail];
    }
}

-(void)parseGetDichosData{
    NSString *returnedString = [[NSString alloc] initWithData:getDichosData encoding: NSUTF8StringEncoding];
    returnedString = [returnedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([returnedString isEqualToString:@""]){
        [self.tableView reloadData];
        self.view.userInteractionEnabled = YES;
    }else{
        int existingSections = [dichoIDsArray count];
        
        //////break down dichos data!!!
        NSArray *infoArray = [returnedString componentsSeparatedByString:@"|"];
        for(int i=0; i<infoArray.count-1; i=i+14){
            [dichoIDsArray addObject:[infoArray objectAtIndex:i]];
            [dichosArray addObject:[infoArray objectAtIndex:i+1]];
            [firstAnswersArray addObject:[infoArray objectAtIndex:i+2]];
            [secondAnswersArray addObject:[infoArray objectAtIndex:i+3]];
            [askerIDsArray addObject:[infoArray objectAtIndex:i+5]];
            [namesArray addObject:[infoArray objectAtIndex:i+6]];
            [usernamesArray addObject:[infoArray objectAtIndex:i+7]];
            [starredsArray addObject:[infoArray objectAtIndex:i+8]];
            [answeredsArray addObject:[infoArray objectAtIndex:i+9]];
            [picturesArray addObject:[infoArray objectAtIndex:i+10]];
            [firstVotesArray addObject:[infoArray objectAtIndex:i+11]];
            [secondVotesArray addObject:[infoArray objectAtIndex:i+12]];
            [commentsArray addObject:[infoArray objectAtIndex:i+13]];
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
            
            //get time since
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
        [self.tableView reloadData];
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
    
    if([[usernamesArray objectAtIndex:sectionNumber] isEqualToString:@"Anonymous"]){
        imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://dichoapp.com/userImages/0.jpeg"]];
    }else{
        imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://dichoapp.com/userImages/%@.jpeg", [askerIDsArray objectAtIndex:sectionNumber]]];
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
        
        [self.tableView performSelectorOnMainThread:@selector(reloadRowsAtIndexPaths:withRowAnimation:) withObject:rowsToReload waitUntilDone:NO];
    }
}


-(void)handleGetDichosFail{
    self.view.userInteractionEnabled = YES;
    UIAlertView *refreshFail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [refreshFail show];
    
}

- (IBAction)starADicho:(id)sender {
    //get indexpath
    progressAlert= [[UIAlertView alloc] initWithTitle:nil message:@"Favoriting..." delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [progressAlert show];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
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
    [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)handleStarringFail{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *starringFail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection and try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [starringFail show];
}

- (IBAction)showThePicture:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    
    DICHOPictureViewController *pictureView = [[DICHOPictureViewController alloc] initWithDichoID:[dichoIDsArray objectAtIndex:indexPath.section]];
    [pictureView setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:pictureView animated:YES completion:NULL];
}

-(IBAction)voteForFirst:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    votingSection = indexPath.section;
    firstVoteAlert= [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: [NSString stringWithFormat: @"Submit \"%@\"", [firstAnswersArray objectAtIndex:indexPath.section]], @"Submit Anonymously",nil];
    [firstVoteAlert show];
}

-(IBAction)voteForSecond:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    votingSection = indexPath.section;
    secondVoteAlert= [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: [NSString stringWithFormat: @"Submit \"%@\"", [secondAnswersArray objectAtIndex:indexPath.section]], @"Submit Anonymously",nil];
    [secondVoteAlert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView==firstVoteAlert)
    {
        if(buttonIndex==1){ //regular first vote
            progressAlert= [[UIAlertView alloc] initWithTitle:nil message:@"Submitting..." delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [progressAlert show];
            
            votingForFirst = YES;
            NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/FirstVote.php?dichoID=%@&userID=%@&anon=0", [dichoIDsArray objectAtIndex:votingSection], [prefs objectForKey:@"userID"]];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
            votingConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
        }else if(buttonIndex==2){ //anonymous first vote
            progressAlert= [[UIAlertView alloc] initWithTitle:nil message:@"Submitting..." delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [progressAlert show];
            
            votingForFirst = YES;
            NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/FirstVote.php?dichoID=%@&userID=%@&anon=1", [dichoIDsArray objectAtIndex:votingSection], [prefs objectForKey:@"userID"]];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
            votingConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
        }
    }else if(alertView==secondVoteAlert){
        if(buttonIndex==1){ //regular second vote
            progressAlert= [[UIAlertView alloc] initWithTitle:nil message:@"Submitting..." delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [progressAlert show];
            
            votingForFirst = NO;
            NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/SecondVote.php?dichoID=%@&userID=%@&anon=0", [dichoIDsArray objectAtIndex:votingSection], [prefs objectForKey:@"userID"]];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
            votingConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
        }else if(buttonIndex==2){ //anonymous second vote
            progressAlert= [[UIAlertView alloc] initWithTitle:nil message:@"Submitting..." delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [progressAlert show];
            
            votingForFirst = NO;
            NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/SecondVote.php?dichoID=%@&userID=%@&anon=1", [dichoIDsArray objectAtIndex:votingSection], [prefs objectForKey:@"userID"]];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
            votingConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        }
        
        
    }
}

-(void)handleGoodVote{
    if(votingForFirst==YES){
        [answeredsArray replaceObjectAtIndex: votingSection withObject:@"1"];
        int voteCount = [[firstVotesArray objectAtIndex:votingSection] intValue];
        voteCount = voteCount + 1;
        [firstVotesArray replaceObjectAtIndex:votingSection withObject:[NSString stringWithFormat:@"%d", voteCount]];
    }else{
        [answeredsArray replaceObjectAtIndex: votingSection withObject:@"2"];
        int voteCount = [[secondVotesArray objectAtIndex:votingSection] intValue];
        voteCount = voteCount + 1;
        [secondVotesArray replaceObjectAtIndex:votingSection withObject:[NSString stringWithFormat:@"%d", voteCount]];
    }
    NSIndexPath* rowToReload0 = [NSIndexPath indexPathForRow:0 inSection:votingSection];
    NSIndexPath* rowToReload1 = [NSIndexPath indexPathForRow:1 inSection:votingSection];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload0, rowToReload1, nil];
    [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)handleVotingFail{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *votingFail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection and vote again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [votingFail show];
}

-(IBAction)results:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    
    DICHOSingleUserResultsViewController *nextVC = [[DICHOSingleUserResultsViewController alloc] initWithDichoID:[dichoIDsArray objectAtIndex:indexPath.section] Dicho:[dichosArray objectAtIndex:indexPath.section] FirstAnswer:[firstAnswersArray objectAtIndex:indexPath.section] SecondAnswer:[secondAnswersArray objectAtIndex:indexPath.section]];
    [self.navigationController pushViewController:nextVC animated:YES];
}

-(IBAction)goToUser:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    
    ////go to single user
    DICHOSingleUserViewController *nextVC = [[DICHOSingleUserViewController alloc] initWithUsername: [usernamesArray objectAtIndex:indexPath.section] askerID:[askerIDsArray objectAtIndex:indexPath.section]];
    [self.navigationController pushViewController:nextVC animated:YES];
    
}

-(IBAction)goToComments:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    DICHOCommentsViewController *nextVC = [[DICHOCommentsViewController alloc] initWithDichoID:[dichoIDsArray objectAtIndex:indexPath.section]];
    [self.navigationController pushViewController:nextVC animated:YES];
}

@end
