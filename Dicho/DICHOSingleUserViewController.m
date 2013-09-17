//
//  DICHOSearchUsernameSelectViewController.m
//  Dicho
//
//  Created by Tyler Droll on 12/18/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import "DICHOSingleUserViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DICHOSingleUserResultsViewController.h"
#import "DICHOSUAskingViewController.h"
#import "DICHOSUAnsweringViewController.h"
#import "DICHOCommentsViewController.h"
#import "DICHOPictureViewController.h"
#import <Social/Social.h>

@interface DICHOSingleUserViewController ()

@end

@implementation DICHOSingleUserViewController
@synthesize pictureAlert;
@synthesize firstVoteAlert;
@synthesize secondVoteAlert;
@synthesize votingSection;
@synthesize votingForFirst;
@synthesize starringSection;
@synthesize shareSection;
@synthesize progressAlert;
@synthesize loadedAll;
@synthesize loadingMore;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithUsername: (NSString *)givenUsername askerID: (NSString*)askerID{
    self = [super init];
    if( !self) return nil;
    self.title = givenUsername;
    username = givenUsername;
    selectedUserID = askerID;
    loadedInfo = NO;
    userImage = [UIImage imageNamed:@"dichoTabBarIcon.png"];

    imageQueue = [[NSOperationQueue alloc] init];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(loadUserImage) object:nil];

    [imageQueue addOperation:operation];

    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    prefs= [NSUserDefaults standardUserDefaults];    
    userID = [prefs objectForKey:@"userID"];
    loadedInfo = NO;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.94 green:0.98 blue:1.0 alpha:1.0];
    self.tableView.sectionFooterHeight = 0.0;
    self.tableView.sectionHeaderHeight = 8.0;
    
    //original info connection connection
    NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/getInfoFromUserID.php?askerID=%@&answererID=%@", selectedUserID, userID];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 15.0];
    infoConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

}

-(void) viewDidAppear:(BOOL)animated{
    NSString *loginStatus = [prefs objectForKey:@"loggedIn"];
    
    if([loginStatus isEqualToString:@"no"]){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        if(self.tabBarController.selectedIndex == 0){
            if([[prefs objectForKey:@"firstTimeToDicho"] isEqualToString:@"yes"]){
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }else if(self.tabBarController.selectedIndex == 2){
            if([[prefs objectForKey:@"firstTimeToSearch"] isEqualToString:@"yes"]){
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }else if(self.tabBarController.selectedIndex == 3){
            if([[prefs objectForKey:@"firstTimeToHome"] isEqualToString:@"yes"]){
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
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
    // Return the number of sections.
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
    // Return the number of rows in the section.
    if(section==0)
        return 1;
    if([dichoIDsArray count] != 0){
        if(section == [dichoIDsArray count]+1)
            return 1;
        else return 2;
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
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
        static NSString *topCellIdentifier = @"userCell";
        UITableViewCell *topCell = [tableView dequeueReusableCellWithIdentifier:topCellIdentifier];
        

        UIImageView *userPicture;
        UILabel *fullnameLabel;
        UILabel *usernameLabel;
        
        UILabel *dichosNumberLabel;
        UILabel *dichosLabel;
        UIButton *dichosButton;
        
        UILabel *answerersNumberLabel;
        UILabel *answerersLabel;
        UIButton *answerersButton;
        
        UILabel *answeringNumberLabel;
        UILabel *answeringLabel;
        UIButton *answereringButton;
        
        UILabel *answerButtonLabel;
        UIButton *customAnswerButton;
       
        if (topCell == nil) {
            topCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:topCellIdentifier];
            topCell.backgroundColor = [UIColor whiteColor];
            topCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            //create and add userpicture, name, username
            userPicture = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 120, 120)];
            userPicture.tag = 1;
            userPicture.backgroundColor = [UIColor lightGrayColor];
            userPicture.contentMode = UIViewContentModeScaleAspectFill;
            userPicture.clipsToBounds = YES;
            [topCell.contentView addSubview:userPicture];
            
            fullnameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 132, 300, 21)];
            fullnameLabel.text = name;
            fullnameLabel.textColor = [UIColor blackColor];
            fullnameLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0f];
            fullnameLabel.textAlignment = NSTextAlignmentLeft;
            fullnameLabel.adjustsFontSizeToFitWidth = YES;
            fullnameLabel.backgroundColor = [UIColor whiteColor];
            [topCell.contentView addSubview:fullnameLabel];
            
            usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 151, 300, 21)];
            usernameLabel.text = [NSString stringWithFormat:@"@%@", username];
            usernameLabel.textColor = [UIColor darkGrayColor];
            usernameLabel.font = [UIFont fontWithName:@"ArialMT" size:15.0f];
            usernameLabel.textAlignment = NSTextAlignmentLeft;
            usernameLabel.adjustsFontSizeToFitWidth = YES;
            usernameLabel.backgroundColor = [UIColor clearColor];
            [topCell.contentView addSubview:usernameLabel];
            
            //create and add dichos number label, label, and button
            dichosNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 12, 120, 20)];
            dichosNumberLabel.text = dichosNumber;
            dichosNumberLabel.textColor = [UIColor blackColor];
            dichosNumberLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0f];
            dichosNumberLabel.textAlignment = NSTextAlignmentCenter;
            dichosNumberLabel.adjustsFontSizeToFitWidth = YES;
            dichosNumberLabel.backgroundColor = [UIColor clearColor];
            [topCell.contentView addSubview:dichosNumberLabel];
            
            dichosLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 25, 120, 20)];
            dichosLabel.text = @"Dichos";
            dichosLabel.textColor = [UIColor darkGrayColor];
            dichosLabel.font = [UIFont fontWithName:@"ArialMT" size:14.0f];
            dichosLabel.textAlignment = NSTextAlignmentCenter;
            dichosLabel.backgroundColor = [UIColor clearColor];
            [topCell.contentView addSubview:dichosLabel];
            
            dichosButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [dichosButton setFrame:CGRectMake(130, 10, 120, 41)];
            [dichosButton setUserInteractionEnabled:NO];
            dichosButton.layer.borderColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0].CGColor;
            dichosButton.layer.borderWidth = 1.0;
            CAGradientLayer *btnGradient2 = [CAGradientLayer layer];
            btnGradient2.frame = dichosButton.bounds;
            btnGradient2.colors = [NSArray arrayWithObjects:
                                  (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                                  (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
                                  (id)[UIColor colorWithWhite:0.75f alpha:0.2f].CGColor,
                                  (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                                  (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                                  nil];
            [dichosButton.layer insertSublayer:btnGradient2 atIndex:0];
            [topCell.contentView addSubview:dichosButton];
            
            //create and add answerers number label, label, and button
            answerersNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 52, 120, 20)];
            answerersNumberLabel.text = answerersNumber;
            answerersNumberLabel.textColor = [UIColor blackColor];
            answerersNumberLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0f];
            answerersNumberLabel.textAlignment = NSTextAlignmentCenter;
            answerersNumberLabel.adjustsFontSizeToFitWidth = YES;
            answerersNumberLabel.backgroundColor = [UIColor clearColor];
            [topCell.contentView addSubview:answerersNumberLabel];
            
            answerersLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 65, 120, 20)];
            answerersLabel.text = @"Answerers";
            answerersLabel.textColor = [UIColor darkGrayColor];
            answerersLabel.font = [UIFont fontWithName:@"ArialMT" size:14.0f];
            answerersLabel.textAlignment = NSTextAlignmentCenter;
            answerersLabel.backgroundColor = [UIColor clearColor];
            [topCell.contentView addSubview:answerersLabel];
            
            answerersButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [answerersButton setFrame:CGRectMake(130, 49, 120, 42)];
            [answerersButton setUserInteractionEnabled:YES];
            answerersButton.showsTouchWhenHighlighted = YES;
            answerersButton.layer.borderColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0].CGColor;
            answerersButton.layer.borderWidth = 1.0;
            [answerersButton addTarget:self action:@selector(goToAsking:) forControlEvents:UIControlEventTouchUpInside];
            CAGradientLayer *btnGradient3 = [CAGradientLayer layer];
            btnGradient3.frame = answerersButton.bounds;
            btnGradient3.colors = [NSArray arrayWithObjects:
                                   (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                                   (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
                                   (id)[UIColor colorWithWhite:0.75f alpha:0.2f].CGColor,
                                   (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                                   (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                                   nil];
            [answerersButton.layer insertSublayer:btnGradient3 atIndex:0];
            [topCell.contentView addSubview:answerersButton];
            
            //create and add answering number label, label, and button
            answeringNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 92, 120, 20)];
            answeringNumberLabel.text = answeringNumber;
            answeringNumberLabel.textColor = [UIColor blackColor];
            answeringNumberLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0f];
            answeringNumberLabel.textAlignment = NSTextAlignmentCenter;
            answeringNumberLabel.adjustsFontSizeToFitWidth = YES;
            answeringNumberLabel.backgroundColor = [UIColor clearColor];
            [topCell.contentView addSubview:answeringNumberLabel];
            
            answeringLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 105, 120, 20)];
            answeringLabel.text = @"Answering";
            answeringLabel.textColor = [UIColor darkGrayColor];
            answeringLabel.font = [UIFont fontWithName:@"ArialMT" size:14.0f];
            answeringLabel.textAlignment = NSTextAlignmentCenter;
            answeringLabel.backgroundColor = [UIColor clearColor];
            [topCell.contentView addSubview:answeringLabel];
            
            answereringButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [answereringButton setFrame:CGRectMake(130, 89, 120, 41)];
            [answereringButton setUserInteractionEnabled:YES];
            answereringButton.showsTouchWhenHighlighted = YES;
            answereringButton.layer.borderColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0].CGColor;
            answereringButton.layer.borderWidth = 1.0;
            [answereringButton addTarget:self action:@selector(goToAnswering:) forControlEvents:UIControlEventTouchUpInside];
            CAGradientLayer *btnGradient4 = [CAGradientLayer layer];
            btnGradient4.frame = answereringButton.bounds;
            btnGradient4.colors = [NSArray arrayWithObjects:
                                   (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                                   (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
                                   (id)[UIColor colorWithWhite:0.75f alpha:0.2f].CGColor,
                                   (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                                   (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                                   nil];
            [answereringButton.layer insertSublayer:btnGradient4 atIndex:0];
            [topCell.contentView addSubview:answereringButton];
            
            //create and add custom answer button and its label
            answerButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(280, 9, 10, 120)];
            answerButtonLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:10.0f];
            answerButtonLabel.numberOfLines = 9;
            answerButtonLabel.backgroundColor = [UIColor clearColor];
            answerButtonLabel.textAlignment = NSTextAlignmentCenter;
            answerButtonLabel.lineBreakMode = NSLineBreakByCharWrapping;
            
            customAnswerButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [customAnswerButton addTarget:self action:@selector(answer:) forControlEvents:UIControlEventTouchUpInside];
            [customAnswerButton setFrame:CGRectMake(269, 10, 32, 120)];
            [customAnswerButton setUserInteractionEnabled:YES];
            customAnswerButton.layer.masksToBounds = NO;
            customAnswerButton.layer.cornerRadius = 5.0f;
            customAnswerButton.layer.shadowColor = [UIColor blackColor].CGColor;
            customAnswerButton.layer.shadowOpacity = 1;
            customAnswerButton.layer.shadowRadius = 1;
            customAnswerButton.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
            CAGradientLayer *btnGradient = [CAGradientLayer layer];
            btnGradient.frame = customAnswerButton.bounds;
            btnGradient.colors = [NSArray arrayWithObjects:
                                  (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                                  (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
                                  (id)[UIColor colorWithWhite:0.75f alpha:0.2f].CGColor,
                                  (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                                  (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                                  nil];
            [customAnswerButton.layer insertSublayer:btnGradient atIndex:0];
            customAnswerButton.showsTouchWhenHighlighted = YES;
            
            if(answering==YES){
                answerButtonLabel.text = @"ANSWERING";
                answerButtonLabel.textColor = [UIColor whiteColor];
                customAnswerButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0];
            }else{
                answerButtonLabel.text = @"ANSWER";
                answerButtonLabel.textColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0];
                customAnswerButton.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
                customAnswerButton.layer.borderColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0].CGColor;
                customAnswerButton.layer.borderWidth = 2.0;
            }
            [topCell.contentView addSubview:customAnswerButton];
            [topCell.contentView addSubview:answerButtonLabel];
            
        }else{
            userPicture = (UIImageView *)[topCell.contentView viewWithTag:1];

        }
        userPicture.image = userImage;
        
        return topCell;
        
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
            
            UILabel *usernameLabel;
            UILabel *nameLabel;
            UILabel *timeLabel;
            UIImageView *askerPicture;
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
                
                //create, format, and add username label
                nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 10, 219, 21)];
                nameLabel.tag = 1;
                nameLabel.text = name;
                nameLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:13.0f];
                nameLabel.textAlignment = NSTextAlignmentLeft;
                nameLabel.textColor = [UIColor blackColor];
                nameLabel.backgroundColor = [UIColor clearColor];
                nameLabel.adjustsFontSizeToFitWidth = YES;
                [cell.contentView addSubview:nameLabel];
                
                //create, format, and add name label
                usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 26, 206, 21)];
                usernameLabel.tag = 2;
                usernameLabel.text = [NSString stringWithFormat:@"@%@", username];
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
                
                
                //create, get image, and add imageView
                askerPicture = [[UIImageView alloc] initWithFrame:CGRectMake(10, 6, 46, 46)];
                askerPicture.tag = 5;
                askerPicture.backgroundColor = [UIColor lightGrayColor];
                askerPicture.layer.cornerRadius = 5.0;
                askerPicture.contentMode = UIViewContentModeScaleAspectFill;
                askerPicture.clipsToBounds = YES;
                askerPicture.image = userImage;
                [cell.contentView addSubview:askerPicture];
                
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
                
                //set buttons enabled and colors
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
                questionLabel = (UILabel *)[cell.contentView viewWithTag:6];
                firstAnswerButton = (UIButton *)[cell.contentView viewWithTag:7];
                secondAnswerButton = (UIButton *)[cell.contentView viewWithTag:8];
                askerPicture = (UIImageView *)[cell.contentView viewWithTag:5];
                pictureButton = (UIButton *)[cell.contentView viewWithTag:10];
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
            }
            
            askerPicture.image = userImage;
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
                shareButton.showsTouchWhenHighlighted = YES;
                [shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
                [shareButton setFrame:CGRectMake(15, 4, 36, 36)];
                [shareButton setImage:[UIImage imageNamed:@"shareButton.png"] forState:UIControlStateNormal];
                [cell.contentView addSubview:shareButton];
                
                //create, position, and add comments button and label
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

#pragma mark - Table view delegate
    
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

- (IBAction)goToAnswering:(id)sender {    
    DICHOSUAnsweringViewController *nextVC = [[DICHOSUAnsweringViewController alloc] initWithAnswererID:selectedUserID];
    [self.navigationController pushViewController:nextVC animated:YES];
}

- (IBAction)goToAsking:(id)sender {    
    DICHOSUAskingViewController *nextVC = [[DICHOSUAskingViewController alloc] initWithAskerID:selectedUserID];
    [self.navigationController pushViewController:nextVC animated:YES];
}

-(IBAction)loadMore:(id)sender{
    if(loadedAll==NO){
        if(loadingMore == NO){
            loadingMore = YES;
            self.view.userInteractionEnabled = NO;
            
            //call php with most recent to get back list of new dichos
            NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/getOneUserDichos3.php?displayedNumber=%d&askerID=%@&userID=%@",[dichoIDsArray count], selectedUserID, userID];
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
    }else if(connection==answeringConnection){
        [self parseAnsweringData];
    }else if(connection==unansweringConnection){
        [self parseUnansweringData];
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
    }else if(connection==answeringConnection){
        [self handleAnsweringFail];
    }else if(connection==unansweringConnection){
        [self handleAnsweringFail];
    }else if(connection==getDichosConnection){
        [self handleGetDichosFail];
    }
}

-(IBAction)answer:(id)sender{
    if(answering==YES){
        if([selectedUserID isEqualToString:@"1"]){
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"You can't unanswer Dicho!" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }else if([selectedUserID isEqualToString:userID]){
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"You can't unanswer yourself!" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }else{
            progressAlert= [[UIAlertView alloc] initWithTitle:nil message:@"Unanswering..." delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [progressAlert show];
            
            NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/unanswer.php?askerID=%@&answererID=%@", selectedUserID, userID];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 10.0];
            unansweringConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        }
        
    }else if(answering==NO){
        progressAlert= [[UIAlertView alloc] initWithTitle:nil message:@"Answering..." delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [progressAlert show];
        
        NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/addAnswerer.php?askerID=%@&answererID=%@", selectedUserID, userID];
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 10.0];
        answeringConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

-(void)parseAnsweringData{
    answering=YES;
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:0];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)parseUnansweringData{
    answering=NO;
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:0];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
}


-(void)handleAnsweringFail{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [fail show];
}

-(void)parseInfoData{
    NSString *returnedInfoString = [[NSString alloc] initWithData:infoData encoding: NSUTF8StringEncoding];
    returnedInfoString = [returnedInfoString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *infoArray= [returnedInfoString componentsSeparatedByString:@","];
    dichosNumber = [infoArray objectAtIndex:0];
    answerersNumber = [infoArray objectAtIndex:1];
    answeringNumber = [infoArray objectAtIndex:2];
    if([[infoArray objectAtIndex:3] isEqualToString:@"yes"]){
        answering = YES;
    }else{
        answering = NO;
    }
    name = [infoArray objectAtIndex:4];
    
    
    loadedInfo = YES;
    
    self.view.userInteractionEnabled = NO;
    [self.tableView reloadData];
    
    loadingMore = YES;
    loadedAll = NO;
    
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
    
    //call to get all the dichos
    NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/getOneUserDichos3.php?displayedNumber=0&askerID=%@&userID=%@", selectedUserID, userID];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 10.0];
    getDichosConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(void)handleInfoFail{
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
        [self.tableView reloadData];
        self.view.userInteractionEnabled = YES;
    }else{
        NSArray *infoArray = [returnedString componentsSeparatedByString:@"|"];
        for(int i=0; i<infoArray.count-1; i=i+11){
            //store dicho, first answer, second answer, etc
            [dichoIDsArray addObject:[infoArray objectAtIndex:i]];
            [dichosArray addObject:[infoArray objectAtIndex:i+1]];
            [firstAnswersArray addObject:[infoArray objectAtIndex:i+2]];
            [secondAnswersArray addObject:[infoArray objectAtIndex:i+3]];
            [starredsArray addObject:[infoArray objectAtIndex:i+5]];
            [answeredsArray addObject:[infoArray objectAtIndex:i+6]];
            [picturesArray addObject:[infoArray objectAtIndex:i+7]];
            [firstVotesArray addObject:[infoArray objectAtIndex:i+8]];
            [secondVotesArray addObject:[infoArray objectAtIndex:i+9]];
            [commentsArray addObject:[infoArray objectAtIndex:i+10]];
        
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
        [self.tableView reloadData];
        loadingMore = NO;
        self.view.userInteractionEnabled = YES;
        
    }
    
}

-(void)handleGetDichosFail{
    loadingMore = NO;
    UIAlertView *getDichosFail = [[UIAlertView alloc] initWithTitle:@"Connection interrupted." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [getDichosFail show];
    [self.tableView reloadData];
    self.view.userInteractionEnabled = YES;
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

-(IBAction)share:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    shareSection = indexPath.section;
    
    UIActionSheet *shareSheet = [[UIActionSheet alloc] initWithTitle:@"Share this Dicho" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Twitter", @"Facebook", @"Copy Link", nil];
    [shareSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *dichoID = [dichoIDsArray objectAtIndex:shareSection-1];
    NSString *dichoURL = [NSString stringWithFormat:@"http://dichoapp.com/files/webDicho.php?dhcd=%@", dichoID];
    
    if (buttonIndex == 0) {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        {
            SLComposeViewController *tweetSheet = [SLComposeViewController
                                                   composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetSheet setInitialText:@"Check out this Dicho!"];
            [tweetSheet addURL:[NSURL URLWithString:dichoURL]];
            
            [self presentViewController:tweetSheet animated:YES completion:nil];
        }
    } else if (buttonIndex == 1) {
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            [controller setInitialText:@"Check out this Dicho!"];
            [controller addURL:[NSURL URLWithString:dichoURL]]; //format with dichoID
            
            [self presentViewController:controller animated:YES completion:Nil];
        }
    } else if (buttonIndex == 2) {
        [UIPasteboard generalPasteboard].string = dichoURL;
    }
}


-(IBAction)goToComments:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    DICHOCommentsViewController *nextVC = [[DICHOCommentsViewController alloc] initWithDichoID:[dichoIDsArray objectAtIndex:indexPath.section-1]];
    [self.navigationController pushViewController:nextVC animated:YES];
    
}


-(void)loadUserImage{
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://dichoapp.com/userImages/%@.jpeg", selectedUserID]];
    NSData * userImageData = [NSData dataWithContentsOfURL:imageURL];
    
    if(userImageData != nil){
        UIImage * image = [UIImage imageWithData:userImageData];
        
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
        userImage = newImage;
        
        [self.tableView reloadData];

    }
}

@end
