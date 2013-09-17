//
//  DICHOSingleGroupViewController.m
//  Dicho
//
//  Created by Tyler Droll on 8/1/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOSingleGroupViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DICHOSingleUserResultsViewController.h"
#import "DICHOAsyncImageViewRound.h"
#import "DICHOSingleUserViewController.h"
#import "DICHOGroupMembersViewController.h"
#import "DICHOGroupAskViewController.h"
#import "DICHOGroupSettingsViewController.h"
#import "DICHOCommentsViewController.h"
#import "DICHOPictureViewController.h"

@interface DICHOSingleGroupViewController ()

@end

@implementation DICHOSingleGroupViewController
@synthesize pictureAlert;
@synthesize firstVoteAlert;
@synthesize secondVoteAlert;
@synthesize votingSection;
@synthesize votingForFirst;
@synthesize starringSection;
@synthesize progressAlert;
@synthesize loadedAll;
@synthesize loadingMore;
@synthesize leaveGroupAlert;
@synthesize notMemberAlert;
@synthesize refreshControl;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)initWithGroupName: (NSString *)givenGroupName groupID: (NSString*)givenGroupID{
    self = [super init];
    if( !self) return nil;
    self.title = givenGroupName;
    name = givenGroupName;
    groupID = givenGroupID;
    loadedInfo = NO;
    isAdmin = NO;
    return self;
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    prefs= [NSUserDefaults standardUserDefaults];
    userID = [prefs objectForKey:@"userID"];
    loadedInfo = NO;
    
    //init all arrays
    dichoIDsArray = [[NSMutableArray alloc] init];
    dichosArray = [[NSMutableArray alloc] init];
    askerIDsArray = [[NSMutableArray alloc] init];
    usernamesArray = [[NSMutableArray alloc] init];
    namesArray = [[NSMutableArray alloc] init];
    datesArray = [[NSMutableArray alloc] init];
    timesSinceArray = [[NSMutableArray alloc] init];
    firstAnswersArray = [[NSMutableArray alloc] init];
    secondAnswersArray = [[NSMutableArray alloc] init];
    firstVotesArray = [[NSMutableArray alloc] init];
    secondVotesArray = [[NSMutableArray alloc] init];
    starredsArray = [[NSMutableArray alloc] init];
    answeredsArray = [[NSMutableArray alloc] init];
    picturesArray = [[NSMutableArray alloc] init];
    commentsArray = [[NSMutableArray alloc] init];
    userImagesArray = [[NSMutableArray alloc] init];
    imageQueue = [[NSOperationQueue alloc] init];
    imageQueue.maxConcurrentOperationCount = 4;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.94 green:0.98 blue:1.0 alpha:1.0];
    self.tableView.sectionFooterHeight= 0.0;
    self.tableView.sectionHeaderHeight = 8.0;
    
    UIBarButtonItem *askButton = [[UIBarButtonItem alloc] initWithTitle:@"Ask"
                                                                    style:UIBarButtonItemStyleBordered target:self action:@selector(goToAsk:)];
    
    self.navigationItem.rightBarButtonItem = askButton;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0];
    
    dichosNumber=@"0";
    membersNumber=@"0";
    adminName=@"0";
    adminID=@"0";
    memberStatus=@"2";
    loadedGroupImage = [UIImage imageNamed:@"dichoTabBarIcon.png"];
   
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:0.5];
    [self.tableView addSubview:refreshControl];
    
    [self refresh:self];
    
}

-(void) viewDidAppear:(BOOL)animated{
    NSString *loginStatus = [prefs objectForKey:@"loggedIn"];
    
    if([loginStatus isEqualToString:@"no"]){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        if(self.tabBarController.selectedIndex == 0){
            if([[prefs objectForKey:@"firstTimeToDicho"] isEqualToString:@"yes"]){
                [self.navigationController popToRootViewControllerAnimated:YES];
            }else{
                [imageQueue setSuspended:NO];
            }
        }else if(self.tabBarController.selectedIndex == 3){
            if([[prefs objectForKey:@"firstTimeToHome"] isEqualToString:@"yes"]){
                [self.navigationController popToRootViewControllerAnimated:YES];
            }else{
                [imageQueue setSuspended:NO];
            }
        }
    }
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
    if([dichoIDsArray count] == 0){
        if(loadedInfo == YES)
            return 1;
        else return 0;
    }else{
        if(loadedAll == YES){
            return [dichosArray count]+1;
        }else{
            return [dichosArray count] + 2;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
        return 1;
    if([dichoIDsArray count] != 0){
        if(section == [dichoIDsArray count]+1)
            return 1;
        else return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
        return 178;
    if([dichoIDsArray count] != 0){
        if(indexPath.section == [dichoIDsArray count]+1)
            return 44;
        else{
            if(indexPath.row==0){
                NSString *text = [dichosArray objectAtIndex:(indexPath.section-1)];
                CGSize constraint = CGSizeMake(292, 20000.0f);
                CGSize size = [text sizeWithFont:[UIFont fontWithName:@"ArialMT" size:16.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
                CGFloat height = MAX(size.height, 13.0f);
                return height + 150;
            }else return 44;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0){
        static NSString *CellIdentifier = @"groupInfoCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UIImageView *groupPicture;
        UILabel *nameLabel;
        UILabel *usernameLabel;
        
        UILabel *dichosNumberLabel;
        UILabel *dichosLabel;
        UIButton *dichosButton;
        
        UILabel *membersNumberLabel;
        UILabel *membersLabel;
        UIButton *membersButton;
        
        UILabel *adminNameLabel;
        UILabel *adminLabel;
        UIButton *adminButton;
        
        UILabel *joinButtonLabel;
        UIButton *joinButton;
        UIButton *settingsButton;
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            //create and add userpicture, name, username
            groupPicture = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 120, 120)];
            groupPicture.tag = 1;
            groupPicture.contentMode = UIViewContentModeScaleAspectFill;
            groupPicture.clipsToBounds = YES;
            groupPicture.backgroundColor = [UIColor lightGrayColor];
            [cell.contentView addSubview:groupPicture];
            
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 132, 262, 21)];
            nameLabel.tag = 2;
            nameLabel.textColor = [UIColor blackColor];
            nameLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0f];
            nameLabel.adjustsFontSizeToFitWidth = YES;
            nameLabel.textAlignment = NSTextAlignmentLeft;
            nameLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:nameLabel];
            
            usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 151, 240, 21)];
            usernameLabel.tag = 3;
            usernameLabel.textColor = [UIColor darkGrayColor];
            usernameLabel.font = [UIFont fontWithName:@"ArialMT" size:15.0f];
            usernameLabel.textAlignment = NSTextAlignmentLeft;
            usernameLabel.adjustsFontSizeToFitWidth = YES;
            usernameLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:usernameLabel];
            
            //create and add dichos number label, label, and button
            dichosNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 12, 120, 20)];
            dichosNumberLabel.tag = 4;
            dichosNumberLabel.textColor = [UIColor blackColor];
            dichosNumberLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0f];
            dichosNumberLabel.textAlignment = NSTextAlignmentCenter;
            dichosNumberLabel.adjustsFontSizeToFitWidth = YES;
            dichosNumberLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:dichosNumberLabel];
            
            dichosLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 25, 120, 20)];
            dichosLabel.text = @"Dichos";
            dichosLabel.textColor = [UIColor darkGrayColor];
            dichosLabel.font = [UIFont fontWithName:@"ArialMT" size:14.0f];
            dichosLabel.textAlignment = NSTextAlignmentCenter;
            dichosLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:dichosLabel];
            
            dichosButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [dichosButton setFrame:CGRectMake(130, 10, 120, 41)];
            [dichosButton setUserInteractionEnabled:NO];
            dichosButton.layer.borderColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0].CGColor;
            dichosButton.layer.borderWidth = 1.0;
            CAGradientLayer *btnGradientDichos = [CAGradientLayer layer];
            btnGradientDichos.frame = dichosButton.bounds;
            btnGradientDichos.colors = [NSArray arrayWithObjects:
                                   (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                                   (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
                                   (id)[UIColor colorWithWhite:0.75f alpha:0.2f].CGColor,
                                   (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                                   (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                                   nil];
            [dichosButton.layer insertSublayer:btnGradientDichos atIndex:0];
            [cell.contentView addSubview:dichosButton];
            
            //create and add members number label, label, and button
            membersNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 52, 120, 20)];
            membersNumberLabel.tag = 5;
            membersNumberLabel.textColor = [UIColor blackColor];
            membersNumberLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0f];
            membersNumberLabel.textAlignment = NSTextAlignmentCenter;
            membersNumberLabel.adjustsFontSizeToFitWidth = YES;
            membersNumberLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:membersNumberLabel];
            
            membersLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 65, 120, 20)];
            membersLabel.text = @"Members";
            membersLabel.textColor = [UIColor darkGrayColor];
            membersLabel.font = [UIFont fontWithName:@"ArialMT" size:14.0f];
            membersLabel.textAlignment = NSTextAlignmentCenter;
            membersLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:membersLabel];
            
            membersButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [membersButton setFrame:CGRectMake(130, 49, 120, 42)];
            [membersButton setUserInteractionEnabled:YES];
            membersButton.showsTouchWhenHighlighted = YES;
            membersButton.layer.borderColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0].CGColor;
            membersButton.layer.borderWidth = 1.0;
            [membersButton addTarget:self action:@selector(goToMembers:) forControlEvents:UIControlEventTouchUpInside];
            CAGradientLayer *btnGradientMembers = [CAGradientLayer layer];
            btnGradientMembers.frame = membersButton.bounds;
            btnGradientMembers.colors = [NSArray arrayWithObjects:
                                   (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                                   (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
                                   (id)[UIColor colorWithWhite:0.75f alpha:0.2f].CGColor,
                                   (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                                   (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                                   nil];
            [membersButton.layer insertSublayer:btnGradientMembers atIndex:0];
            [cell.contentView addSubview:membersButton];
            
            //create and add admin namelabel, label, and button
            adminNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 92, 120, 19)];
            adminNameLabel.tag =6;
            adminNameLabel.textColor = [UIColor blackColor];
            adminNameLabel.font = [UIFont fontWithName:@"ArialMT" size:15.0f];
            adminNameLabel.adjustsFontSizeToFitWidth = YES;
            adminNameLabel.textAlignment = NSTextAlignmentCenter;
            adminNameLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:adminNameLabel];
            
            adminLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 107, 120, 19)];
            adminLabel.text = @"Admin";
            adminLabel.textColor = [UIColor darkGrayColor];
            adminLabel.font = [UIFont fontWithName:@"ArialMT" size:14.0f];
            adminLabel.textAlignment = NSTextAlignmentCenter;
            adminLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:adminLabel];
            
            adminButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [adminButton setFrame:CGRectMake(130, 89, 120, 41)];
            [adminButton setUserInteractionEnabled:NO];
            adminButton.layer.borderColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0].CGColor;
            adminButton.layer.borderWidth = 1.0;
            CAGradientLayer *btnGradientAdmin = [CAGradientLayer layer];
            btnGradientAdmin.frame = adminButton.bounds;
            btnGradientAdmin.colors = [NSArray arrayWithObjects:
                                   (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                                   (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
                                   (id)[UIColor colorWithWhite:0.75f alpha:0.2f].CGColor,
                                   (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                                   (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                                   nil];
            [adminButton.layer insertSublayer:btnGradientAdmin atIndex:0];
            [cell.contentView addSubview:adminButton];
            
            //create and add custom join button and its label
            joinButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(280, 9, 10, 120)];
            joinButtonLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:10.0f];
            joinButtonLabel.numberOfLines = 9;
            joinButtonLabel.backgroundColor = [UIColor clearColor];
            joinButtonLabel.textAlignment = NSTextAlignmentCenter;
            joinButtonLabel.lineBreakMode = NSLineBreakByCharWrapping;
            
            joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [joinButton addTarget:self action:@selector(leaveGroup:) forControlEvents:UIControlEventTouchUpInside];
            [joinButton setFrame:CGRectMake(269, 10, 32, 120)];
            [joinButton setUserInteractionEnabled:YES];
            joinButton.layer.masksToBounds = NO;
            joinButton.layer.cornerRadius = 5.0f;
            joinButton.layer.shadowColor = [UIColor blackColor].CGColor;
            joinButton.layer.shadowOpacity = 1;
            joinButton.layer.shadowRadius = 1;
            joinButton.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
            CAGradientLayer *btnGradient = [CAGradientLayer layer];
            btnGradient.frame = joinButton.bounds;
            btnGradient.colors = [NSArray arrayWithObjects:
                                  (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                                  (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
                                  (id)[UIColor colorWithWhite:0.75f alpha:0.2f].CGColor,
                                  (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                                  (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                                  nil];
            [joinButton.layer insertSublayer:btnGradient atIndex:0];
            joinButton.showsTouchWhenHighlighted = YES;

            joinButtonLabel.text = @"MEMBER";
            joinButtonLabel.textColor = [UIColor whiteColor];
            joinButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0];
            
            [cell.contentView addSubview:joinButton];
            [cell.contentView addSubview:joinButtonLabel];
            
            settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [settingsButton addTarget:self action:@selector(goToSettings:) forControlEvents:UIControlEventTouchUpInside];
            [settingsButton setFrame:CGRectMake(288, 146, 30, 30)];

            [settingsButton setUserInteractionEnabled:YES];
            settingsButton.layer.masksToBounds = NO;
            settingsButton.showsTouchWhenHighlighted = YES;
            [settingsButton setBackgroundImage:[UIImage imageNamed:@"settingsIcon.png"] forState:UIControlStateNormal];
            [cell.contentView addSubview:settingsButton];

        }else{
            groupPicture = (UIImageView *)[cell.contentView viewWithTag:1];
            nameLabel = (UILabel *)[cell.contentView viewWithTag:2];
            usernameLabel = (UILabel *)[cell.contentView viewWithTag:3];
            dichosNumberLabel = (UILabel *)[cell.contentView viewWithTag:4];
            membersNumberLabel = (UILabel *)[cell.contentView viewWithTag:5];
            adminNameLabel = (UILabel *)[cell.contentView viewWithTag:6];
        }
        
        groupPicture.image = loadedGroupImage;
        nameLabel.text = name;
        usernameLabel.text = [NSString stringWithFormat:@"@%@", username];
        dichosNumberLabel.text = dichosNumber;
        membersNumberLabel.text = membersNumber;
        adminNameLabel.text = adminName;
        
        return cell;
    }else if(indexPath.section == [dichoIDsArray count]+1){
        static NSString *CellIdentifier = @"loadingMoreCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UILabel *loadingMoreLabel;
        UIActivityIndicatorView *activityIndicator;
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            loadingMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 11, 135, 20)];
            loadingMoreLabel.font = [UIFont fontWithName:@"ArialMT" size:15.0f];
            loadingMoreLabel.text = @"Loading more...";
            loadingMoreLabel.textAlignment = NSTextAlignmentCenter;
            loadingMoreLabel.textColor = [UIColor darkGrayColor];
            loadingMoreLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:loadingMoreLabel];
            
            activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(200, 11, 20, 20)];
            activityIndicator.activityIndicatorViewStyle= UIActivityIndicatorViewStyleGray;
            [activityIndicator startAnimating];
            [cell.contentView addSubview:activityIndicator];
        }
        
        return cell;
        
    }else{
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
                if([[usernamesArray objectAtIndex:indexPath.section-1] isEqualToString:@"Anonymous"]){
                    [userImageButton setEnabled:NO];
                }else{
                    userImageButton.enabled=YES;
                }
                [cell.contentView addSubview:userImageButton];
                
                //create, format, and add username label
                nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 10, 219, 21)];
                nameLabel.tag = 1;
                nameLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:13.0f];
                nameLabel.textAlignment = NSTextAlignmentLeft;
                nameLabel.textColor = [UIColor blackColor];
                nameLabel.backgroundColor = [UIColor clearColor];
                nameLabel.adjustsFontSizeToFitWidth = YES;
                [cell.contentView addSubview:nameLabel];
                
                //create, format, and add name label
                usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 26, 206, 21)];
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
                
                NSString *text = [dichosArray objectAtIndex:indexPath.section-1];
                CGSize constraint = CGSizeMake(292, 20000.0f);
                CGSize size = [text sizeWithFont:[UIFont fontWithName:@"ArialMT" size:16.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
                
                //create, format, and add firstVotes label
                firstVotesLabel = [[UILabel alloc] initWithFrame:CGRectMake(272, 75+MAX(size.height, 13.0f), 38, 25)];
                firstVotesLabel.tag = 12;
                firstVotesLabel.font = [UIFont fontWithName:@"ArialMT" size:16.0f];
                firstVotesLabel.adjustsFontSizeToFitWidth = YES;
                firstVotesLabel.textAlignment = NSTextAlignmentCenter;
                firstVotesLabel.textColor = [UIColor colorWithWhite:0.55 alpha:1.0];
                firstVotesLabel.backgroundColor = [UIColor whiteColor];
                [cell.contentView addSubview:firstVotesLabel];
                
                UIButton *firstAnswerButton = [UIButton buttonWithType:UIButtonTypeCustom];
                firstAnswerButton.tag = 7;
                [firstAnswerButton setFrame:CGRectMake(10, 75+MAX(size.height, 13.0f), 260, 25)];
                [firstAnswerButton setTitle:[firstAnswersArray objectAtIndex:indexPath.section-1] forState:UIControlStateNormal];
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
                secondVotesLabel = [[UILabel alloc] initWithFrame:CGRectMake(272, 110+MAX(size.height, 13.0f), 38, 25)];
                secondVotesLabel.tag = 13;
                secondVotesLabel.font = [UIFont fontWithName:@"ArialMT" size:16.0f];
                secondVotesLabel.adjustsFontSizeToFitWidth = YES;
                secondVotesLabel.textAlignment = NSTextAlignmentCenter;
                secondVotesLabel.textColor = [UIColor colorWithWhite:0.55 alpha:1.0];
                secondVotesLabel.backgroundColor = [UIColor whiteColor];
                [cell.contentView addSubview:secondVotesLabel];
                
                UIButton *secondAnswerButton = [UIButton buttonWithType:UIButtonTypeCustom];
                secondAnswerButton.tag = 8;
                [secondAnswerButton setFrame:CGRectMake(10, 110+MAX(size.height, 13.0f), 260, 25)];
                [secondAnswerButton setTitle:[secondAnswersArray objectAtIndex:indexPath.section-1] forState:UIControlStateNormal];
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
                if([[answeredsArray objectAtIndex:indexPath.section-1] isEqualToString:@"0"]){
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
                    firstVotesLabel.text = [firstVotesArray objectAtIndex:indexPath.section-1];
                    secondVotesLabel.text = [secondVotesArray objectAtIndex:indexPath.section-1];
                    
                    if([[answeredsArray objectAtIndex:indexPath.section-1] isEqualToString:@"1"]){
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
                [pictureButton setFrame:CGRectMake(268, 24, 45, 36)];
                if([[picturesArray objectAtIndex:indexPath.section-1] isEqualToString:@"1"]){
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
                if([[answeredsArray objectAtIndex:indexPath.section-1] isEqualToString:@"0"]){
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
                    firstVotesLabel.text = [firstVotesArray objectAtIndex:indexPath.section-1];
                    secondVotesLabel.text = [secondVotesArray objectAtIndex:indexPath.section-1];
                    
                    if([[answeredsArray objectAtIndex:indexPath.section-1] isEqualToString:@"1"]){
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
                
                
                
                if([[picturesArray objectAtIndex:indexPath.section-1] isEqualToString:@"1"]){
                    [pictureButton setEnabled:YES];
                    [pictureButton setBackgroundImage:[UIImage imageNamed:@"dicho_camera_blue.png"] forState:UIControlStateNormal];
                    
                }else{
                    pictureButton.enabled=NO;
                    [pictureButton setBackgroundImage:nil forState:UIControlStateNormal];
                }
                
                if([[usernamesArray objectAtIndex:indexPath.section-1] isEqualToString:@"Anonymous"]){
                    [userImageButton setEnabled:NO];
                }else{
                    userImageButton.enabled=YES;
                }
                
            }
            
            userImageView.image = [userImagesArray objectAtIndex:indexPath.section-1];
            nameLabel.text = [namesArray objectAtIndex:indexPath.section-1];
            usernameLabel.text = [NSString stringWithFormat:@"@%@", [usernamesArray objectAtIndex:indexPath.section-1]];
            timeLabel.text = [timesSinceArray objectAtIndex:indexPath.section-1];
            
            questionLabel.text =[dichosArray objectAtIndex:indexPath.section-1];
            NSString *text = [dichosArray objectAtIndex:indexPath.section-1];
            CGSize constraint = CGSizeMake(292, 20000.0f);
            CGSize size = [text sizeWithFont:[UIFont fontWithName:@"ArialMT" size:16.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
            [questionLabel setFrame:CGRectMake(10, 65, 300, MAX(size.height, 13.0f))];
            
            [firstVotesLabel setFrame:CGRectMake(272, 75+MAX(size.height, 13.0f), 38, 25)];
            [secondVotesLabel setFrame:CGRectMake(272, 110+MAX(size.height, 13.0f), 38, 25)];
            
            [firstAnswerButton setTitle:[firstAnswersArray objectAtIndex:indexPath.section-1] forState:UIControlStateNormal];
            [firstAnswerButton setFrame:CGRectMake(10, 75+MAX(size.height, 13.0f), 260, 25)];
            
            [secondAnswerButton setTitle:[secondAnswersArray objectAtIndex:indexPath.section-1] forState:UIControlStateNormal];
            [secondAnswerButton setFrame:CGRectMake(10, 110+MAX(size.height, 13.0f), 260, 25)];
            
            [pictureButton setFrame:CGRectMake(268, 24, 45, 36)];
            [userImageButton setFrame:CGRectMake(10, 6, 46, 46)];
            
            return cell;
        }else if(indexPath.row==1) {
            static NSString *CellIdentifier = @"questionInfoCell";
            
            UIButton *shareButton;
            UIButton *starButton;
            UIButton *resultsButton;
            UIButton *commentsButton;
            UILabel *commentsLabel;
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                
                cell.backgroundColor = [UIColor whiteColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                
                //create, position, and add share button
                shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
                shareButton.tag = 1;
                [shareButton setFrame:CGRectMake(15, 4, 36, 36)];
                [shareButton setImage:[UIImage imageNamed:@"shareButton.png"] forState:UIControlStateNormal];
                shareButton.enabled = NO;
                [cell.contentView addSubview:shareButton];
                
                //create, position, and add reask button
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
                
                resultsButton = [UIButton buttonWithType:UIButtonTypeCustom];
                resultsButton.tag = 4;
                [resultsButton setFrame:CGRectMake(166, 7, 70, 30)];
                [resultsButton addTarget:self action:@selector(results:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:resultsButton];
                
                if([[answeredsArray objectAtIndex:indexPath.section-1] isEqualToString:@"0"]){
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

                    int commentsCount = [[commentsArray objectAtIndex:indexPath.section-1] intValue];
                    if(commentsCount>999)
                        commentsLabel.text = @"999+";
                    else
                        commentsLabel.text = [NSString stringWithFormat:@"%@", [commentsArray objectAtIndex:indexPath.section-1]];
                }
                
                //create, position, and add star button
                starButton = [UIButton buttonWithType:UIButtonTypeCustom];
                starButton.tag = 5;
                [starButton addTarget:self action:@selector(starADicho:) forControlEvents:UIControlEventTouchUpInside];
                [starButton setFrame:CGRectMake(256, 6, 32, 32)];
                if([[starredsArray objectAtIndex:indexPath.section-1] isEqualToString:@"1"]){
                    [starButton setImage:[UIImage imageNamed:@"favorite_filled.png"] forState:UIControlStateNormal];
                    [starButton setUserInteractionEnabled:NO];
                }else{
                    [starButton setImage:[UIImage imageNamed:@"favorite_empty.png"] forState:UIControlStateNormal];
                    starButton.userInteractionEnabled = YES;
                }
                [cell.contentView addSubview:starButton];
                
            }else{
                shareButton = (UIButton *)[cell.contentView viewWithTag:1];
                commentsButton = (UIButton *)[cell.contentView viewWithTag:2];
                commentsLabel = (UILabel *)[cell.contentView viewWithTag:3];
                resultsButton = (UIButton *)[cell.contentView viewWithTag:4];
                starButton = (UIButton *)[cell.contentView viewWithTag:5];
                
                if([[answeredsArray objectAtIndex:indexPath.section-1] isEqualToString:@"0"]){
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
                    int commentsCount = [[commentsArray objectAtIndex:indexPath.section-1] intValue];
                    if(commentsCount>999)
                        commentsLabel.text = @"999+";
                    else
                        commentsLabel.text = [NSString stringWithFormat:@"%@", [commentsArray objectAtIndex:indexPath.section-1]];
                }
                
                
                //working version
                if([[starredsArray objectAtIndex:indexPath.section-1] isEqualToString:@"1"]){
                    [starButton setImage:[UIImage imageNamed:@"favorite_filled.png"] forState:UIControlStateNormal];
                    starButton.userInteractionEnabled=NO;
                }else{
                    [starButton setImage:[UIImage imageNamed:@"favorite_empty.png"] forState:UIControlStateNormal];
                    starButton.userInteractionEnabled = YES;
                }
                
            }
            
            return cell;
            
        }
        
    }
    
}


- (IBAction)showThePicture:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    
    DICHOPictureViewController *pictureView = [[DICHOPictureViewController alloc] initWithDichoID:[dichoIDsArray objectAtIndex:indexPath.section-1]];
    [pictureView setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:pictureView animated:YES completion:NULL];
    
}

-(IBAction)results:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
        
    DICHOSingleUserResultsViewController *nextVC = [[DICHOSingleUserResultsViewController alloc] initWithDichoID:[dichoIDsArray objectAtIndex:indexPath.section-1] Dicho:[dichosArray objectAtIndex:indexPath.section-1] FirstAnswer:[firstAnswersArray objectAtIndex:indexPath.section-1] SecondAnswer:[secondAnswersArray objectAtIndex:indexPath.section-1]];
    [self.navigationController pushViewController:nextVC animated:YES];
}

-(IBAction)loadMore:(id)sender{
    if(loadedAll==NO){
        if(loadingMore == NO){
            loadingMore = YES;
            self.view.userInteractionEnabled = NO;
            
            //call php with most recent to get back list of new dichos
            NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/getOneGroupDichos2.php?displayedNumber=%d&groupID=%@&userID=%@",[dichoIDsArray count], groupID, userID];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
            getDichosConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        }
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
    if(connection==infoConnection){
        infoData = [[NSMutableData alloc] init];
    }else if(connection==getDichosConnection){
        getDichosData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(connection==infoConnection){
        [infoData appendData:data];
    }else if(connection==getDichosConnection){
        [getDichosData appendData:data];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(connection==infoConnection){
        [self parseInfoData];
    }else if(connection==starConnection){
        [self handleGoodStar];
    }else if(connection==votingConnection){
        [self handleGoodVote];
    }else if(connection==leaveGroupConnection){
        [self handleGoodLeave];
    }else if(connection==getDichosConnection){
        [self parseGetDichosData];
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if(connection==infoConnection){
        [self handleInfoFail];
    }else if(connection==starConnection){
        [self handleStarringFail];
    }else if(connection==votingConnection){
        [self handleVotingFail];
    }else if(connection==leaveGroupConnection){
        [self handleLeaveFail];
    }else if(connection==getDichosConnection){
        [self handleGetDichosFail];
    }
}

- (IBAction)refresh:(id)sender{
    self.view.userInteractionEnabled = NO;
    [imageQueue cancelAllOperations];
    
    
    [dichoIDsArray removeAllObjects];
    [dichosArray removeAllObjects];
    [askerIDsArray removeAllObjects];
    [usernamesArray removeAllObjects];
    [namesArray removeAllObjects];
    [datesArray removeAllObjects];
    [timesSinceArray removeAllObjects];
    [firstAnswersArray removeAllObjects];
    [firstVotesArray removeAllObjects];
    [secondAnswersArray removeAllObjects];
    [secondVotesArray removeAllObjects];
    [starredsArray removeAllObjects];
    [answeredsArray removeAllObjects];
    [picturesArray removeAllObjects];
    [commentsArray removeAllObjects];
    [userImagesArray removeAllObjects];

    [self.tableView reloadData];
    
    ////call for group info
    ////need to get dichos, members, admin name and userID, (following will be set to Member
    NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/getGroupInfo.php?groupID=%@&userID=%@", groupID, userID];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 15.0];
    infoConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}


-(void)parseInfoData{
    NSString *returnedInfoString = [[NSString alloc] initWithData:infoData encoding: NSUTF8StringEncoding];
    returnedInfoString = [returnedInfoString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *infoArray= [returnedInfoString componentsSeparatedByString:@"|"];
    name = [infoArray objectAtIndex:0];
    username = [infoArray objectAtIndex:1];
    dichosNumber = [infoArray objectAtIndex:2];
    membersNumber = [infoArray objectAtIndex:3];
    adminID = [infoArray objectAtIndex:4];
    adminName = [infoArray objectAtIndex:5];
    memberStatus = [infoArray objectAtIndex:6];
    
    
    if(![memberStatus isEqualToString:@"2"]){
        [refreshControl endRefreshing];
        self.view.userInteractionEnabled = YES;
        notMemberAlert = [[UIAlertView alloc] initWithTitle:@"You are not a member of this group." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: @"Ok", nil];
        [notMemberAlert show];
    }else{
        if([adminID isEqualToString:userID]){
            isAdmin = YES;
        }
        loadedInfo = YES;
        self.title = name;
        [self.tableView reloadData];
        self.view.userInteractionEnabled = YES;
        
        loadingMore = YES;
        loadedAll = NO;
        
        //add get group image operation to queue
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                selector:@selector(loadGroupImage)
                                                                                  object:nil];
        [imageQueue addOperation:operation];
        
        
        //call to get all the dichos
        NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/getOneGroupDichos2.php?displayedNumber=0&groupID=%@&userID=%@", groupID, userID];
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 10.0];
        getDichosConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

-(void)loadGroupImage{
    NSURL * imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://dichoapp.com/groupImages/%@.jpeg", groupID]];
    NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
    
    if(imageData != nil){
        UIImage * image = [UIImage imageWithData:imageData];
        
        //resize image to let tableview scroll more smoothly
        CGFloat widthFactor = image.size.width/120;
        CGFloat heightFactor = image.size.height/120;
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
        loadedGroupImage = newImage;
        
        NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:0];
        NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
        
        [self.tableView performSelectorOnMainThread:@selector(reloadRowsAtIndexPaths:withRowAnimation:) withObject:rowsToReload waitUntilDone:NO];
        
    }
}

-(void)handleInfoFail{
    [refreshControl endRefreshing];
    self.view.userInteractionEnabled = YES;
    UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [fail show];
}

-(void)parseGetDichosData{
    NSString *returnedString = [[NSString alloc] initWithData:getDichosData encoding: NSUTF8StringEncoding];
    returnedString = [returnedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([returnedString isEqualToString:@""]){
        loadedAll=YES;
        loadingMore = NO;
        [refreshControl endRefreshing];
        [self.tableView reloadData];
        self.view.userInteractionEnabled = YES;
    }else{
        int existingSections = [dichoIDsArray count];

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
            
            //find time since
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
        [self.tableView reloadData];
        [refreshControl endRefreshing];
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
        
        NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:sectionNumber+1];
        NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
        
        [self.tableView performSelectorOnMainThread:@selector(reloadRowsAtIndexPaths:withRowAnimation:) withObject:rowsToReload waitUntilDone:NO];
        
    }
}

-(void)handleGetDichosFail{
    [refreshControl endRefreshing];
    self.view.userInteractionEnabled = YES;
    loadingMore = NO;
    
    UIAlertView *refreshFail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [refreshFail show];
}

-(IBAction)voteForFirst:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    votingSection = indexPath.section-1;
    firstVoteAlert= [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: [NSString stringWithFormat: @"Submit \"%@\"", [firstAnswersArray objectAtIndex:indexPath.section-1]], @"Submit Anonymously",nil];
    [firstVoteAlert show];
}

-(IBAction)voteForSecond:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    votingSection = indexPath.section-1;
    secondVoteAlert= [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: [NSString stringWithFormat: @"Submit \"%@\"", [secondAnswersArray objectAtIndex:indexPath.section-1]], @"Submit Anonymously",nil];
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
            NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/FirstVote.php?dichoID=%@&userID=%@&anon=0", [dichoIDsArray objectAtIndex:votingSection], userID];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
            votingConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
        }else if(buttonIndex==2){ //anonymous first vote
            progressAlert= [[UIAlertView alloc] initWithTitle:nil message:@"Submitting..." delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [progressAlert show];
            
            votingForFirst = YES;
            NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/FirstVote.php?dichoID=%@&userID=%@&anon=1", [dichoIDsArray objectAtIndex:votingSection], userID];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
            votingConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
        }
    }else if(alertView==secondVoteAlert){
        if(buttonIndex==1){ //regular second vote
            progressAlert= [[UIAlertView alloc] initWithTitle:nil message:@"Submitting..." delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [progressAlert show];
            
            votingForFirst = NO;
            NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/SecondVote.php?dichoID=%@&userID=%@&anon=0", [dichoIDsArray objectAtIndex:votingSection], userID];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
            votingConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
        }else if(buttonIndex==2){ //anonymous second vote
            progressAlert= [[UIAlertView alloc] initWithTitle:nil message:@"Submitting..." delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [progressAlert show];
            
            votingForFirst = NO;
            NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/SecondVote.php?dichoID=%@&userID=%@&anon=1", [dichoIDsArray objectAtIndex:votingSection], userID];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
            votingConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        }
    }else if(alertView == leaveGroupAlert){
        if(buttonIndex==1){
            progressAlert= [[UIAlertView alloc] initWithTitle:nil message:@"Leaving..." delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [progressAlert show];
            
            NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/leaveGroup.php?userID=%@&groupID=%@", userID, groupID];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
            leaveGroupConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

        }
    }else if(alertView == notMemberAlert){
        if(buttonIndex == 0){
            [self.navigationController popViewControllerAnimated:YES];
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
    NSIndexPath* rowToReload0 = [NSIndexPath indexPathForRow:0 inSection:votingSection+1];
    NSIndexPath* rowToReload1 = [NSIndexPath indexPathForRow:1 inSection:votingSection+1];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload0, rowToReload1, nil];
    [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
}
-(void)handleVotingFail{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *votingFail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection and vote again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [votingFail show];
}

- (IBAction)starADicho:(id)sender {
    progressAlert= [[UIAlertView alloc] initWithTitle:nil message:@"Favoriting..." delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [progressAlert show];
    //get indexpath
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    starringSection = indexPath.section;
    
    //add star in database
    NSString *strURL = [NSString stringWithFormat: @"http://dichoapp.com/files/addStar.php?dichoID=%@&userID=%@", [dichoIDsArray objectAtIndex:indexPath.section-1], userID];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    starConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(void)handleGoodStar{
    [starredsArray replaceObjectAtIndex:starringSection-1 withObject:@"1"];
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

-(IBAction)goToMembers:(id)sender{
    DICHOGroupMembersViewController *nextVC = [[DICHOGroupMembersViewController alloc] initWithGroupID:groupID];
    [self.navigationController pushViewController:nextVC animated:YES];
}

-(IBAction)goToSettings:(id)sender{
    if(isAdmin == YES){
        DICHOGroupSettingsViewController *nextVC = [[DICHOGroupSettingsViewController alloc] initWithGroupID:groupID name:name username:username image:loadedGroupImage];
        [self.navigationController pushViewController:nextVC animated:YES];
        
    }else{
        UIAlertView *notAdminAlert = [[UIAlertView alloc] initWithTitle:@"You are not the admin." message:@"Only the group's administrator can access the group's settings." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [notAdminAlert show];
    }
}
-(IBAction)goToAsk:(id)sender{
    DICHOGroupAskViewController *nextVC = [[DICHOGroupAskViewController alloc] initWithGroupID: groupID];
    [self.navigationController pushViewController:nextVC animated:YES];
    
}
-(IBAction)goToUser:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    
    DICHOSingleUserViewController *nextVC = [[DICHOSingleUserViewController alloc] initWithUsername: [usernamesArray objectAtIndex:indexPath.section-1] askerID:[askerIDsArray objectAtIndex:indexPath.section-1]];
    [self.navigationController pushViewController:nextVC animated:YES];
}

-(IBAction)goToComments:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    DICHOCommentsViewController *nextVC = [[DICHOCommentsViewController alloc] initWithDichoID:[dichoIDsArray objectAtIndex:indexPath.section-1]];
    [self.navigationController pushViewController:nextVC animated:YES];
}

-(IBAction)leaveGroup:(id)sender{
    if(isAdmin == YES){
        UIAlertView *adminAlert = [[UIAlertView alloc] initWithTitle:@"You are the admin." message:@"Select a new administrator before leaving the group." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [adminAlert show];
    }else{
        leaveGroupAlert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to leave this group?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Yes", nil];
        [leaveGroupAlert show];
    }
    
}
-(void)handleGoodLeave{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    [self.navigationController popViewControllerAnimated:YES];

}
-(void)handleLeaveFail{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *leavingFail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection and try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [leavingFail show];

}
@end
