//
//  DICHOAskedViewController.m
//  Dicho
//
//  Created by Tyler Droll on 11/28/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import "DICHOAskedViewController.h"
#import "Reachability.h"
#import <QuartzCore/QuartzCore.h>


@interface DICHOAskedViewController ()

@end

@implementation DICHOAskedViewController
@synthesize notLoggedInAlert;
@synthesize pictureAlert;
@synthesize internetActive;
@synthesize hostActive;
@synthesize myInternetActive;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) viewDidAppear:(BOOL)animated{
    NSLog(@"refreshhh");
        NSString *loginStatus = [prefs objectForKey:@"loggedIn"];
    NSString *firstTimeStatus = [prefs objectForKey:@"firstTimeToHome"];
    
    if([loginStatus isEqualToString:@"no"]){
        //[self.tabBarController setSelectedIndex:4];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else if([firstTimeStatus isEqualToString:@"yes"]){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self refresh:self];
    }
    
    /* [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
     
     internetReachable = [Reachability reachabilityForInternetConnection];
     [internetReachable startNotifier];
     
     // check if a pathway to a random host exists
     hostReachable = [Reachability reachabilityWithHostname: @"www.apple.com"];
     [hostReachable startNotifier];
     NSLog(@"post int");
     */
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    prefs= [NSUserDefaults standardUserDefaults];

    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background 2.png"]];
    [backgroundImageView setFrame:self.tableView.frame];
    self.tableView.backgroundView = backgroundImageView;
    //init all arrays
    dichoIDsArray = [[NSMutableArray alloc] init];
    fullDichoStringsArray = [[NSMutableArray alloc] init];
    dichosArray = [[NSMutableArray alloc] init];
    datesArray = [[NSMutableArray alloc] init];
    timesArray = [[NSMutableArray alloc] init];
    firstAnswersArray = [[NSMutableArray alloc] init];
    secondAnswersArray = [[NSMutableArray alloc] init];
    firstResultsArray = [[NSMutableArray alloc] init];
    secondResultsArray = [[NSMutableArray alloc] init];
    votesArray = [[NSMutableArray alloc] init];
    picturesArray = [[NSMutableArray alloc] init];
    anonymousArray = [[NSMutableArray alloc] init];
    starsArray = [[NSMutableArray alloc] init];
    
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    hostReachable = [Reachability reachabilityWithHostname: @"www.apple.com"];
    [hostReachable startNotifier];
    


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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(dichoIDsArray.count==0)
        return 0;
    else
        return [dichosArray count]+1;
}
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row<[dichoIDsArray count]){
            NSString *text = [dichosArray objectAtIndex:indexPath.row];
            CGSize constraint = CGSizeMake(190, 20000.0f);
            CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
            CGFloat height = MAX(size.height, 13.0f);
            return height + 65;
    }else return 50;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row<[dichoIDsArray count]){
        static NSString *CellIdentifier = @"dichoCell";
        
        UILabel *timeLabel;
        UILabel *dateLabel;
        UILabel *questionLabel;
        //UILabel *firstAnswerLabel;
        UIButton *firstAnswerButton;
       // UILabel *secondAnswerLabel;
        UIButton *secondAnswerButton;
        //UILabel *firstResultLabel;
       // UILabel *secondResultLabel;
      //  UILabel *votesLabel;
      //  UILabel *votesNumberLabel;
        UIButton *pictureButton;
        UIButton *starButton;
       // UIButton *showAnswerersButton;
        UIButton *votesButton;
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            //create, format, and add time label
            timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(231, 4, 64, 21)];
            timeLabel.tag = 3;
            timeLabel.font = [UIFont fontWithName:@"ArialMT" size:11.0f];
            timeLabel.textAlignment = NSTextAlignmentRight;
            timeLabel.textColor = [UIColor darkGrayColor];
            timeLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:timeLabel];
            
            //create, format, and add date label
            dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(239, 16, 56, 21)];
            dateLabel.tag = 4;
            dateLabel.font = [UIFont fontWithName:@"ArialMT" size:11.0f];
            dateLabel.textAlignment = NSTextAlignmentRight;
            dateLabel.textColor = [UIColor darkGrayColor];
            dateLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:dateLabel];
            
            
            
            //create, format, and add question label
            questionLabel = [[UILabel alloc] init];
            questionLabel.tag =6;
            questionLabel.numberOfLines = 0;
            [questionLabel sizeToFit];
            questionLabel.font = [UIFont fontWithName:@"ArialMT" size:13.0f];
            questionLabel.textAlignment = NSTextAlignmentLeft;
            questionLabel.textColor = [UIColor blackColor];
            questionLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:questionLabel];
            
            //create, position, and add first answer label
                     UIButton *firstAnswerButton = [UIButton buttonWithType:UIButtonTypeCustom];
            firstAnswerButton.tag = 7;
            NSString *text = [dichosArray objectAtIndex:indexPath.row];
            CGSize constraint = CGSizeMake(190, 20000.0f);
            CGSize size = [text sizeWithFont:[UIFont fontWithName:@"ArialMT" size:13.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
            firstAnswerButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:11.0f];
            [firstAnswerButton setTitle:[NSString stringWithFormat:@"%@: %@%%", [firstAnswersArray objectAtIndex:indexPath.row], [firstResultsArray objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
            firstAnswerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            firstAnswerButton. contentEdgeInsets = UIEdgeInsetsMake(2, 5, 0, 0);
            [firstAnswerButton sizeToFit];
            [firstAnswerButton setFrame:CGRectMake(50, 15+MAX(size.height, 13.0f), firstAnswerButton.frame.size.width+5, 14)];
            firstAnswerButton.enabled = NO;
            firstAnswerButton.layer.masksToBounds = NO;
            firstAnswerButton.layer.cornerRadius = 5.0f;
            firstAnswerButton.layer.shadowColor = [UIColor blackColor].CGColor;
            firstAnswerButton.layer.shadowOpacity = 1;
            firstAnswerButton.layer.shadowRadius = 1;
            firstAnswerButton.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
            CAGradientLayer *firstBtnGradient = [CAGradientLayer layer];
            firstBtnGradient.frame = firstAnswerButton.bounds;
            firstBtnGradient.colors = [NSArray arrayWithObjects:
                                  (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                                  (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
                                  (id)[UIColor colorWithWhite:0.75f alpha:0.2f].CGColor,
                                  (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                                  (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                                  nil];
            [firstAnswerButton.layer insertSublayer:firstBtnGradient atIndex:0];
            firstAnswerButton.titleLabel.textColor = [UIColor whiteColor];
            firstAnswerButton.backgroundColor= [UIColor colorWithRed:0.0 green:0.4 blue:0.5 alpha:1.0];
            [cell.contentView addSubview:firstAnswerButton];
            
            //create, position, and add second answer label
            UIButton *secondAnswerButton = [UIButton buttonWithType:UIButtonTypeCustom];
            secondAnswerButton.tag = 8;
            secondAnswerButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:11.0f];
            [secondAnswerButton setTitle:[NSString stringWithFormat:@"%@: %@%%", [secondAnswersArray objectAtIndex:indexPath.row], [secondResultsArray objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
            secondAnswerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            secondAnswerButton. contentEdgeInsets = UIEdgeInsetsMake(2, 5, 0, 0);
            [secondAnswerButton sizeToFit];
            [secondAnswerButton setFrame:CGRectMake(50, 15+MAX(size.height, 13.0f)+16, secondAnswerButton.frame.size.width+5, 14)];
            secondAnswerButton.enabled = NO;
            secondAnswerButton.layer.masksToBounds = NO;
            secondAnswerButton.layer.cornerRadius = 5.0f;
            secondAnswerButton.layer.shadowColor = [UIColor blackColor].CGColor;
            secondAnswerButton.layer.shadowOpacity = 1;
            secondAnswerButton.layer.shadowRadius = 1;
            secondAnswerButton.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
            CAGradientLayer *secondBtnGradient = [CAGradientLayer layer];
            secondBtnGradient.frame = secondAnswerButton.bounds;
            secondBtnGradient.colors = [NSArray arrayWithObjects:
                                       (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                                       (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
                                       (id)[UIColor colorWithWhite:0.75f alpha:0.2f].CGColor,
                                       (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                                       (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                                       nil];
            [secondAnswerButton.layer insertSublayer:secondBtnGradient atIndex:0];
            
            secondAnswerButton.titleLabel.textColor = [UIColor whiteColor];
            secondAnswerButton.backgroundColor= [UIColor colorWithRed:0.0 green:0.4 blue:0.5 alpha:1.0];
            [cell.contentView addSubview:secondAnswerButton];
            
            
            //create and add picture button
            UIButton *pictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
            pictureButton.tag = 12;
            [pictureButton addTarget:self action:@selector(showThePicture:) forControlEvents:UIControlEventTouchUpInside];
            [pictureButton setFrame:CGRectMake(7, 32, 40, 30)];
            [pictureButton setBackgroundImage:[UIImage imageNamed:@"dicho_camera.png"] forState:UIControlStateNormal];
            //[pictureButton setImage:[UIImage imageNamed:@"dicho_camera.png"] forState:UIControlStateNormal];
            if([[picturesArray objectAtIndex:indexPath.row] isEqualToString:@"1"]){
                [pictureButton setEnabled:YES];
            }else{
                pictureButton.enabled=NO;
            }
            [cell.contentView addSubview:pictureButton];
            
            //create, position, and add star button
            UIButton *starButton = [UIButton buttonWithType:UIButtonTypeCustom];
            starButton.tag = 13;
            [starButton addTarget:self action:@selector(starADicho:) forControlEvents:UIControlEventTouchUpInside];
            [starButton setFrame:CGRectMake(12, 3, 30, 30)];
            //[starButton setImage:[UIImage imageNamed:@"star%20empty.png"] forState:UIControlStateNormal];
            if([[starsArray objectAtIndex:indexPath.row] isEqualToString:@"1"]){
                [starButton setImage:[UIImage imageNamed:@"starFilled.png"] forState:UIControlStateNormal];
                [starButton setUserInteractionEnabled:NO];
            }else{
                [starButton setImage:[UIImage imageNamed:@"starHollow.png"] forState:UIControlStateNormal];
                starButton.userInteractionEnabled = YES;
            }
            [cell.contentView addSubview:starButton];

           
            
            UIButton *votesButton = [UIButton buttonWithType:UIButtonTypeCustom];
            votesButton.tag = 14;
            [votesButton addTarget:self action:@selector(results:) forControlEvents:UIControlEventTouchUpInside];

            //NSString *text = [dichosArray objectAtIndex:indexPath.row];
           // CGSize constraint = CGSizeMake(190, 20000.0f);
           // CGSize size = [text sizeWithFont:[UIFont fontWithName:@"ArialMT" size:13.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
            //[votesButton setFrame:CGRectMake(50, 15+MAX(size.height, 13.0f)+32, 245, 14)];
            votesButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:11.0f];
            [votesButton setTitle:[NSString stringWithFormat:@"Votes: %@", [votesArray objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
            votesButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            votesButton. contentEdgeInsets = UIEdgeInsetsMake(2, 5, 0, 0);
            [votesButton sizeToFit];
            [votesButton setFrame:CGRectMake(200, 15+MAX(size.height, 13.0f)+32, votesButton.frame.size.width+5, 14)];
            votesButton.enabled = YES;
            votesButton.layer.masksToBounds = NO;
            votesButton.layer.cornerRadius = 5.0f;
            votesButton.layer.shadowColor = [UIColor blackColor].CGColor;
            votesButton.layer.shadowOpacity = 1;
            votesButton.layer.shadowRadius = 1;
            votesButton.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
            CAGradientLayer *btnGradient = [CAGradientLayer layer];
            btnGradient.frame = votesButton.bounds;
            btnGradient.colors = [NSArray arrayWithObjects:
                                  (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                                  (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
                                  (id)[UIColor colorWithWhite:0.75f alpha:0.2f].CGColor,
                                  (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                                  (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                                  nil];
            [votesButton.layer insertSublayer:btnGradient atIndex:0];
            
            //[votesButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
           // [votesButton setTitle:@"WWWWWWWWWWWWWWWWWW: 100%" forState:UIControlStateNormal];
            
            //votesButton.backgroundColor = [UIColor blackColor];
            //votesButton.titleLabel.textColor = [UIColor whiteColor];
            votesButton.titleLabel.textColor = [UIColor whiteColor];
            votesButton.backgroundColor= [UIColor colorWithRed:0.0 green:0.4 blue:0.5 alpha:1.0];

            [cell.contentView addSubview:votesButton];
            //[answerButton addTarget:self action:@selector(answer:) forControlEvents:UIControlEventTouchUpInside];
           // [answerButton setFrame:CGRectMake(223, 5, 70, 20)];
            
            
        }else{
            timeLabel = (UILabel *)[cell.contentView viewWithTag:3];
            dateLabel = (UILabel *)[cell.contentView viewWithTag:4];
            questionLabel = (UILabel *)[cell.contentView viewWithTag:6];
            firstAnswerButton = (UILabel *)[cell.contentView viewWithTag:7];
            secondAnswerButton = (UILabel *)[cell.contentView viewWithTag:8];
           // votesLabel = (UILabel *)[cell.contentView viewWithTag:9];
            //firstResultLabel = (UILabel *)[cell.contentView viewWithTag:9];
           // secondResultLabel = (UILabel *)[cell.contentView viewWithTag:10];
            pictureButton = (UIButton *)[cell.contentView viewWithTag:12];
            starButton = (UIButton *)[cell.contentView viewWithTag:13];
            votesButton = (UIButton *)[cell.contentView viewWithTag:14];
            
            
            
            if([[picturesArray objectAtIndex:indexPath.row] isEqualToString:@"1"]){
                [pictureButton setEnabled:YES];
            }else{
                pictureButton.enabled=NO;
            }
            
            if([[starsArray objectAtIndex:indexPath.row] isEqualToString:@"1"]){
                [starButton setImage:[UIImage imageNamed:@"starFilled.png"] forState:UIControlStateNormal];
                starButton.userInteractionEnabled=NO;
            }else{
                [starButton setImage:[UIImage imageNamed:@"starHollow.png"] forState:UIControlStateNormal];
                starButton.userInteractionEnabled = YES;
            }
           
        }
        
        
        timeLabel.text = [timesArray objectAtIndex:indexPath.row];
        dateLabel.text = [datesArray objectAtIndex:indexPath.row];
        
        
        
        questionLabel.text =[dichosArray objectAtIndex:indexPath.row];
        NSString *text = [dichosArray objectAtIndex:indexPath.row];
        CGSize constraint = CGSizeMake(190, 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont fontWithName:@"ArialMT" size:13.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        [questionLabel setFrame:CGRectMake(55, 6, 190, MAX(size.height, 13.0f))];
        
       // firstAnswerLabel.text = [NSString stringWithFormat:@"%@: %@%%", [firstAnswersArray objectAtIndex:indexPath.row], [firstResultsArray objectAtIndex:indexPath.row]];
       // firstAnswerLabel.text = @"WWWWWWWWWWWWWWWWWW: 100%";
       // [firstAnswerLabel setFrame:CGRectMake(55, 15+MAX(size.height, 13.0f), 245, 21)];
        //secondAnswerLabel.text = [NSString stringWithFormat:@"%@: %@%%", [secondAnswersArray objectAtIndex:indexPath.row], [secondResultsArray objectAtIndex:indexPath.row]];
       // [secondAnswerLabel setFrame:CGRectMake(55, 15+MAX(size.height, 13.0f)+14, 245, 21)];
        //votesLabel.text = [NSString stringWithFormat:@"Votes: %@", [votesArray objectAtIndex:indexPath.row]];
       // [votesLabel setFrame:CGRectMake(55, 15+MAX(size.height, 13.0f)+28, 245, 21)];
        //[firstAnswerButton sizeToFit];
        [firstAnswerButton setTitle:[NSString stringWithFormat:@"%@: %@%%", [firstAnswersArray objectAtIndex:indexPath.row], [firstResultsArray objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
        [firstAnswerButton sizeToFit];
        [firstAnswerButton setFrame:CGRectMake(50, 15+MAX(size.height, 13.0f), firstAnswerButton.frame.size.width+5, 14)];
        [secondAnswerButton setTitle:[NSString stringWithFormat:@"%@: %@%%", [secondAnswersArray objectAtIndex:indexPath.row], [secondResultsArray objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
        [secondAnswerButton sizeToFit];
        [secondAnswerButton setFrame:CGRectMake(50, 15+MAX(size.height, 13.0f)+16, secondAnswerButton.frame.size.width+5, 14)];
       // [firstAnswerButton setFrame:CGRectMake(50, 15+MAX(size.height, 13.0f), 245, 14)];
        votesButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:11.0f];
        votesButton.titleLabel.textColor = [UIColor whiteColor];
        [votesButton setTitle:[NSString stringWithFormat:@"Votes: %@", [votesArray objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
        [votesButton sizeToFit];
        [votesButton setFrame:CGRectMake(50, 15+MAX(size.height, 13.0f)+32, votesButton.frame.size.width+5, 14)];

       // votesButton.titleLabel.text = [NSString stringWithFormat:@"Votes: %@", [votesArray objectAtIndex:indexPath.row]];
        
       /* firstResultLabel.text = [NSString stringWithFormat:@"%@%%", [firstResultsArray objectAtIndex:indexPath.row]];
        [firstResultLabel setFrame:CGRectMake(231, 15+MAX(size.height, 13.0f), 60, 21)];
        
        secondResultLabel.text = [NSString stringWithFormat:@"%@%%", [secondResultsArray objectAtIndex:indexPath.row]];
        [secondResultLabel setFrame:CGRectMake(231, 15+MAX(size.height, 13.0f)+14, 60, 21)];*/
        return cell;
        
    }else{
        static NSString *CellIdentifier = @"bottomCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            // cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        return cell;
    }

    


}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == [dichoIDsArray count]){
        if(internetActive==YES||hostActive==YES){
            [self checkInternetMyWay:self];
            if(myInternetActive==YES){
                NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
                int displayedNumber = dichoIDsArray.count;
                //call php with most recent to get back list of new dichos
                NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/getOwnDichos.php?displayedNumber=%d&userID=%@", displayedNumber, [prefs objectForKey:@"userID"]];
                NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
                
                //get back and trim
                NSString *returnedDichosList = [[NSString alloc] initWithData:dataURL encoding: NSUTF8StringEncoding];
                
                returnedDichosList = [returnedDichosList stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if(![returnedDichosList isEqualToString:@""]){
                    //NSLog(returnedDichosList);
                    NSArray *dichoIDsToBeAdded = [returnedDichosList componentsSeparatedByString:@","];
                    //NSLog(@"%d",dichoIDsToBeAdded.count);
                    //dichoIDsArray = [[NSMutableArray alloc] initWithObjects:nil];
                    for(int i=0; i<dichoIDsToBeAdded.count; i++){
                        [dichoIDsArray addObject:[dichoIDsToBeAdded objectAtIndex:i]];
                    }
                    
                    NSLog(@"checky");
                    
                    //get current dichoID and call php for full dichoString
                    for(int i=displayedNumber; i<dichoIDsArray.count; i++){
                        NSString *currentDichoNumber = [dichoIDsArray objectAtIndex:i];
                        NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/getOwnQuestionString.php?dichoID=%@&userID=%@", currentDichoNumber, [prefs objectForKey:@"userID"]];
                        NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
                        
                        //get question back, break it up, and add to various arrays (need to expand php to return lots of info)
                        NSString *strResult = [[NSString alloc] initWithData:dataURL encoding: NSUTF8StringEncoding];
                        //NSLog(strResult);
                        [fullDichoStringsArray addObject:strResult];
                        NSArray *dichoStringComponents = [strResult componentsSeparatedByString:@"|"];
                        // NSLog(@"%d", dichoStringComponents.count);
                        //store dicho, first answer, second answer, askerID, asker username, asker picture
                        [dichosArray addObject:[dichoStringComponents objectAtIndex:1]];
                        [firstAnswersArray addObject:[dichoStringComponents objectAtIndex:2]];
                        [secondAnswersArray addObject:[dichoStringComponents objectAtIndex:3]];
                        [picturesArray addObject:[dichoStringComponents objectAtIndex:5]];
                        [anonymousArray addObject:[dichoStringComponents objectAtIndex:6]];
                        [firstResultsArray addObject:[dichoStringComponents objectAtIndex:7]];
                        [secondResultsArray addObject:[dichoStringComponents objectAtIndex:8]];
                        [votesArray addObject:[dichoStringComponents objectAtIndex:9]];
                        [starsArray addObject:[dichoStringComponents objectAtIndex:10]];
                        
                        
                        
                        //do date and time stuff
                        NSArray *dateAndTimeParts = [[dichoStringComponents objectAtIndex:4] componentsSeparatedByString:@" "];
                        NSString *date = [dateAndTimeParts objectAtIndex:0];
                        NSString *time = [dateAndTimeParts objectAtIndex:1];
                        NSArray *dateParts = [date componentsSeparatedByString:@"-"];
                        //format and add date like 12/17/12
                        NSString *fullYear = [dateParts objectAtIndex:0];
                        NSString *endOfYear = [fullYear substringWithRange:NSMakeRange(2, 2)];
                        NSString *formattedDate = [NSString stringWithFormat:@"%@/%@/%@", [dateParts objectAtIndex:1], [dateParts objectAtIndex:2], endOfYear];
                        [datesArray addObject:formattedDate];
                        //format and add time like 11:46 PM
                        NSMutableArray *timeParts = [time componentsSeparatedByString:@":"];
                        if([[timeParts objectAtIndex:0] isEqualToString:@"01"]){
                            [timeParts replaceObjectAtIndex:0 withObject:@"1"];
                            [timeParts replaceObjectAtIndex:2 withObject:@"AM"];
                        }else if([[timeParts objectAtIndex:0] isEqualToString:@"02"]){
                            [timeParts replaceObjectAtIndex:0 withObject:@"2"];
                            [timeParts replaceObjectAtIndex:2 withObject:@"AM"];
                        }else if([[timeParts objectAtIndex:0] isEqualToString:@"03"]){
                            [timeParts replaceObjectAtIndex:0 withObject:@"3"];
                            [timeParts replaceObjectAtIndex:2 withObject:@"AM"];
                        }else if([[timeParts objectAtIndex:0] isEqualToString:@"04"]){
                            [timeParts replaceObjectAtIndex:0 withObject:@"4"];
                            [timeParts replaceObjectAtIndex:2 withObject:@"AM"];
                        }else if([[timeParts objectAtIndex:0] isEqualToString:@"05"]){
                            [timeParts replaceObjectAtIndex:0 withObject:@"5"];
                            [timeParts replaceObjectAtIndex:2 withObject:@"AM"];
                        }else if([[timeParts objectAtIndex:0] isEqualToString:@"06"]){
                            [timeParts replaceObjectAtIndex:0 withObject:@"6"];
                            [timeParts replaceObjectAtIndex:2 withObject:@"AM"];
                        }else if([[timeParts objectAtIndex:0] isEqualToString:@"07"]){
                            [timeParts replaceObjectAtIndex:0 withObject:@"7"];
                            [timeParts replaceObjectAtIndex:2 withObject:@"AM"];
                        }else if([[timeParts objectAtIndex:0] isEqualToString:@"08"]){
                            [timeParts replaceObjectAtIndex:0 withObject:@"8"];
                            [timeParts replaceObjectAtIndex:2 withObject:@"AM"];
                        }else if([[timeParts objectAtIndex:0] isEqualToString:@"09"]){
                            [timeParts replaceObjectAtIndex:0 withObject:@"9"];
                            [timeParts replaceObjectAtIndex:2 withObject:@"AM"];
                        }else if([[timeParts objectAtIndex:0] isEqualToString:@"10"]){
                            [timeParts replaceObjectAtIndex:2 withObject:@"AM"];
                        }else if([[timeParts objectAtIndex:0] isEqualToString:@"11"]){
                            [timeParts replaceObjectAtIndex:2 withObject:@"AM"];
                        }else if([[timeParts objectAtIndex:0] isEqualToString:@"12"]){
                            [timeParts replaceObjectAtIndex:2 withObject:@"PM"];
                        }else if([[timeParts objectAtIndex:0] isEqualToString:@"13"]){
                            [timeParts replaceObjectAtIndex:0 withObject:@"1"];
                            [timeParts replaceObjectAtIndex:2 withObject:@"PM"];
                        }else if([[timeParts objectAtIndex:0] isEqualToString:@"14"]){
                            [timeParts replaceObjectAtIndex:0 withObject:@"2"];
                            [timeParts replaceObjectAtIndex:2 withObject:@"PM"];
                        }else if([[timeParts objectAtIndex:0] isEqualToString:@"15"]){
                            [timeParts replaceObjectAtIndex:0 withObject:@"3"];
                            [timeParts replaceObjectAtIndex:2 withObject:@"PM"];
                        }else if([[timeParts objectAtIndex:0] isEqualToString:@"16"]){
                            [timeParts replaceObjectAtIndex:0 withObject:@"4"];
                            [timeParts replaceObjectAtIndex:2 withObject:@"PM"];
                        }else if([[timeParts objectAtIndex:0] isEqualToString:@"17"]){
                            [timeParts replaceObjectAtIndex:0 withObject:@"5"];
                            [timeParts replaceObjectAtIndex:2 withObject:@"PM"];
                        }else if([[timeParts objectAtIndex:0] isEqualToString:@"18"]){
                            [timeParts replaceObjectAtIndex:0 withObject:@"6"];
                            [timeParts replaceObjectAtIndex:2 withObject:@"PM"];
                        }else if([[timeParts objectAtIndex:0] isEqualToString:@"19"]){
                            [timeParts replaceObjectAtIndex:0 withObject:@"7"];
                            [timeParts replaceObjectAtIndex:2 withObject:@"PM"];
                        }else if([[timeParts objectAtIndex:0] isEqualToString:@"20"]){
                            [timeParts replaceObjectAtIndex:0 withObject:@"8"];
                            [timeParts replaceObjectAtIndex:2 withObject:@"PM"];
                        }else if([[timeParts objectAtIndex:0] isEqualToString:@"21"]){
                            [timeParts replaceObjectAtIndex:0 withObject:@"9"];
                            [timeParts replaceObjectAtIndex:2 withObject:@"PM"];
                        }else if([[timeParts objectAtIndex:0] isEqualToString:@"22"]){
                            [timeParts replaceObjectAtIndex:0 withObject:@"10"];
                            [timeParts replaceObjectAtIndex:2 withObject:@"PM"];
                        }else if([[timeParts objectAtIndex:0] isEqualToString:@"23"]){
                            [timeParts replaceObjectAtIndex:0 withObject:@"11"];
                            [timeParts replaceObjectAtIndex:2 withObject:@"PM"];
                        }else if([[timeParts objectAtIndex:0] isEqualToString:@"00"]){
                            [timeParts replaceObjectAtIndex:0 withObject:@"12"];
                            [timeParts replaceObjectAtIndex:2 withObject:@"AM"];
                        }
                        NSString *formattedTime = [NSString stringWithFormat:@"%@:%@ %@", [timeParts objectAtIndex:0], [timeParts objectAtIndex:1], [timeParts objectAtIndex:2]];
                        [timesArray addObject:formattedTime];
                        
                }
               
                }
                self.tableView.reloadData;
            }
        }else{
        notLoggedInAlert= [[UIAlertView alloc] initWithTitle:@"You Need an Internet Connection" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [notLoggedInAlert show];
        }
        }else{
            notLoggedInAlert= [[UIAlertView alloc] initWithTitle:@"You Need an Internet Connection" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [notLoggedInAlert show];
        

    }

}

-(void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            self.internetActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            self.internetActive = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            self.internetActive = YES;
            
            break;
        }
    }
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)
    {
        case NotReachable:
        {
            NSLog(@"A gateway to the host server is down.");
            self.hostActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"A gateway to the host server is working via WIFI.");
            self.hostActive = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"A gateway to the host server is working via WWAN.");
            self.hostActive = YES;
            
            break;
        }
    }
}

-(IBAction)checkInternetMyWay:(id)sender{
    NSLog(@"checkINtMyWAY");
    NSString *strURL = @"http://dichoapp.com/files/internetCheck.php";
    NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
    NSString *returnedInternetString = [[NSString alloc] initWithData:dataURL encoding: NSUTF8StringEncoding];
    NSArray *internetStringComponents = [returnedInternetString componentsSeparatedByString:@"%%"];
    if(internetStringComponents.count==1)
        myInternetActive=NO;
    else myInternetActive=YES;
}

-(IBAction)refresh:(id)sender{
    /////change this below to a method that gets called
    NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
    NSString *loginStatus = [prefs objectForKey:@"loggedIn"];
    if([loginStatus isEqualToString:@"yes"]){
        NSLog(@"checkers");
        NSLog(internetActive ? @"Yes" : @"No");
        NSLog(hostActive ? @"Yes" : @"No");
        //NSlog(internetActive);
        //NSlog(hostActive);
        if(internetActive==YES||hostActive==YES){
            [self checkInternetMyWay:self];
            if(myInternetActive==YES){
                //call php with most recent to get back list of new dichos
                NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/getOwnDichos.php?displayedNumber=0&userID=%@", [prefs objectForKey:@"userID"]];
                NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
                
                //get back and trim
                NSString *returnedDichosList = [[NSString alloc] initWithData:dataURL encoding: NSUTF8StringEncoding];
                returnedDichosList = [returnedDichosList stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                //NSLog(returnedDichosList);
                NSArray *dichoIDsToBeAdded = [returnedDichosList componentsSeparatedByString:@","];
                //NSLog(@"%d",dichoIDsToBeAdded.count);
                //dichoIDsArray = [[NSMutableArray alloc] initWithObjects:nil];
                [dichoIDsArray removeAllObjects];
                for(int i=0; i<dichoIDsToBeAdded.count; i++){
                    [dichoIDsArray addObject:[dichoIDsToBeAdded objectAtIndex:i]];
                }
                
                NSLog(@"checky");
                
                //get current dichoID and call php for full dichoString
                for(int i=0; i<dichoIDsArray.count; i++){
                    NSString *currentDichoNumber = [dichoIDsArray objectAtIndex:i];
                    NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/getOwnQuestionString.php?dichoID=%@&userID=%@", currentDichoNumber, [prefs objectForKey:@"userID"]];
                    NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
                    
                    //get question back, break it up, and add to various arrays (need to expand php to return lots of info)
                    NSString *strResult = [[NSString alloc] initWithData:dataURL encoding: NSUTF8StringEncoding];
                    //NSLog(strResult);
                    [fullDichoStringsArray addObject:strResult];
                    NSArray *dichoStringComponents = [strResult componentsSeparatedByString:@"|"];
                    // NSLog(@"%d", dichoStringComponents.count);
                    //store dicho, first answer, second answer, askerID, asker username, asker picture
                    [dichosArray addObject:[dichoStringComponents objectAtIndex:1]];
                    [firstAnswersArray addObject:[dichoStringComponents objectAtIndex:2]];
                    [secondAnswersArray addObject:[dichoStringComponents objectAtIndex:3]];
                    [picturesArray addObject:[dichoStringComponents objectAtIndex:5]];
                    [anonymousArray addObject:[dichoStringComponents objectAtIndex:6]];
                    [firstResultsArray addObject:[dichoStringComponents objectAtIndex:7]];
                    [secondResultsArray addObject:[dichoStringComponents objectAtIndex:8]];
                    [votesArray addObject:[dichoStringComponents objectAtIndex:9]];
                    [starsArray addObject:[dichoStringComponents objectAtIndex:10]];
                    
                    
                    
                    //do date and time stuff
                    NSArray *dateAndTimeParts = [[dichoStringComponents objectAtIndex:4] componentsSeparatedByString:@" "];
                    NSString *date = [dateAndTimeParts objectAtIndex:0];
                    NSString *time = [dateAndTimeParts objectAtIndex:1];
                    NSArray *dateParts = [date componentsSeparatedByString:@"-"];
                    //format and add date like 12/17/12
                    NSString *fullYear = [dateParts objectAtIndex:0];
                    NSString *endOfYear = [fullYear substringWithRange:NSMakeRange(2, 2)];
                    NSString *formattedDate = [NSString stringWithFormat:@"%@/%@/%@", [dateParts objectAtIndex:1], [dateParts objectAtIndex:2], endOfYear];
                    [datesArray addObject:formattedDate];
                    //format and add time like 11:46 PM
                    NSMutableArray *timeParts = [time componentsSeparatedByString:@":"];
                    if([[timeParts objectAtIndex:0] isEqualToString:@"01"]){
                        [timeParts replaceObjectAtIndex:0 withObject:@"1"];
                        [timeParts replaceObjectAtIndex:2 withObject:@"AM"];
                    }else if([[timeParts objectAtIndex:0] isEqualToString:@"02"]){
                        [timeParts replaceObjectAtIndex:0 withObject:@"2"];
                        [timeParts replaceObjectAtIndex:2 withObject:@"AM"];
                    }else if([[timeParts objectAtIndex:0] isEqualToString:@"03"]){
                        [timeParts replaceObjectAtIndex:0 withObject:@"3"];
                        [timeParts replaceObjectAtIndex:2 withObject:@"AM"];
                    }else if([[timeParts objectAtIndex:0] isEqualToString:@"04"]){
                        [timeParts replaceObjectAtIndex:0 withObject:@"4"];
                        [timeParts replaceObjectAtIndex:2 withObject:@"AM"];
                    }else if([[timeParts objectAtIndex:0] isEqualToString:@"05"]){
                        [timeParts replaceObjectAtIndex:0 withObject:@"5"];
                        [timeParts replaceObjectAtIndex:2 withObject:@"AM"];
                    }else if([[timeParts objectAtIndex:0] isEqualToString:@"06"]){
                        [timeParts replaceObjectAtIndex:0 withObject:@"6"];
                        [timeParts replaceObjectAtIndex:2 withObject:@"AM"];
                    }else if([[timeParts objectAtIndex:0] isEqualToString:@"07"]){
                        [timeParts replaceObjectAtIndex:0 withObject:@"7"];
                        [timeParts replaceObjectAtIndex:2 withObject:@"AM"];
                    }else if([[timeParts objectAtIndex:0] isEqualToString:@"08"]){
                        [timeParts replaceObjectAtIndex:0 withObject:@"8"];
                        [timeParts replaceObjectAtIndex:2 withObject:@"AM"];
                    }else if([[timeParts objectAtIndex:0] isEqualToString:@"09"]){
                        [timeParts replaceObjectAtIndex:0 withObject:@"9"];
                        [timeParts replaceObjectAtIndex:2 withObject:@"AM"];
                    }else if([[timeParts objectAtIndex:0] isEqualToString:@"10"]){
                        [timeParts replaceObjectAtIndex:2 withObject:@"AM"];
                    }else if([[timeParts objectAtIndex:0] isEqualToString:@"11"]){
                        [timeParts replaceObjectAtIndex:2 withObject:@"AM"];
                    }else if([[timeParts objectAtIndex:0] isEqualToString:@"12"]){
                        [timeParts replaceObjectAtIndex:2 withObject:@"PM"];
                    }else if([[timeParts objectAtIndex:0] isEqualToString:@"13"]){
                        [timeParts replaceObjectAtIndex:0 withObject:@"1"];
                        [timeParts replaceObjectAtIndex:2 withObject:@"PM"];
                    }else if([[timeParts objectAtIndex:0] isEqualToString:@"14"]){
                        [timeParts replaceObjectAtIndex:0 withObject:@"2"];
                        [timeParts replaceObjectAtIndex:2 withObject:@"PM"];
                    }else if([[timeParts objectAtIndex:0] isEqualToString:@"15"]){
                        [timeParts replaceObjectAtIndex:0 withObject:@"3"];
                        [timeParts replaceObjectAtIndex:2 withObject:@"PM"];
                    }else if([[timeParts objectAtIndex:0] isEqualToString:@"16"]){
                        [timeParts replaceObjectAtIndex:0 withObject:@"4"];
                        [timeParts replaceObjectAtIndex:2 withObject:@"PM"];
                    }else if([[timeParts objectAtIndex:0] isEqualToString:@"17"]){
                        [timeParts replaceObjectAtIndex:0 withObject:@"5"];
                        [timeParts replaceObjectAtIndex:2 withObject:@"PM"];
                    }else if([[timeParts objectAtIndex:0] isEqualToString:@"18"]){
                        [timeParts replaceObjectAtIndex:0 withObject:@"6"];
                        [timeParts replaceObjectAtIndex:2 withObject:@"PM"];
                    }else if([[timeParts objectAtIndex:0] isEqualToString:@"19"]){
                        [timeParts replaceObjectAtIndex:0 withObject:@"7"];
                        [timeParts replaceObjectAtIndex:2 withObject:@"PM"];
                    }else if([[timeParts objectAtIndex:0] isEqualToString:@"20"]){
                        [timeParts replaceObjectAtIndex:0 withObject:@"8"];
                        [timeParts replaceObjectAtIndex:2 withObject:@"PM"];
                    }else if([[timeParts objectAtIndex:0] isEqualToString:@"21"]){
                        [timeParts replaceObjectAtIndex:0 withObject:@"9"];
                        [timeParts replaceObjectAtIndex:2 withObject:@"PM"];
                    }else if([[timeParts objectAtIndex:0] isEqualToString:@"22"]){
                        [timeParts replaceObjectAtIndex:0 withObject:@"10"];
                        [timeParts replaceObjectAtIndex:2 withObject:@"PM"];
                    }else if([[timeParts objectAtIndex:0] isEqualToString:@"23"]){
                        [timeParts replaceObjectAtIndex:0 withObject:@"11"];
                        [timeParts replaceObjectAtIndex:2 withObject:@"PM"];
                    }else if([[timeParts objectAtIndex:0] isEqualToString:@"00"]){
                        [timeParts replaceObjectAtIndex:0 withObject:@"12"];
                        [timeParts replaceObjectAtIndex:2 withObject:@"AM"];
                    }
                    NSString *formattedTime = [NSString stringWithFormat:@"%@:%@ %@", [timeParts objectAtIndex:0], [timeParts objectAtIndex:1], [timeParts objectAtIndex:2]];
                    [timesArray addObject:formattedTime];
                    
                }
                self.tableView.reloadData;
                
            }else{
                notLoggedInAlert= [[UIAlertView alloc] initWithTitle:@"You Need an Internet Connection" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [notLoggedInAlert show];
            }
        }else{
            notLoggedInAlert= [[UIAlertView alloc] initWithTitle:@"You Need an Internet Connection" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [notLoggedInAlert show];
        }
        
    }
    else{
        notLoggedInAlert= [[UIAlertView alloc] initWithTitle:@"You Are Not Logged In" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [notLoggedInAlert show];
    }
}

- (IBAction)starADicho:(id)sender {
    //get indexpath
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[sender superview] superview]];
    NSLog(@"%d", indexPath.row);
    
    //change image by adding star in starredArray
    NSString *starredValue = @"1";
    [starsArray replaceObjectAtIndex:indexPath.row withObject:starredValue];
    
    //add star in database
    NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
    NSString *strURL = [NSString stringWithFormat: @"http://dichoapp.com/files/addStar.php?dichoID=%@&userID=%@", [dichoIDsArray objectAtIndex:indexPath.row], [prefs objectForKey:@"userID"]];
    NSData *dataURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
    
    //reload table
    self.tableView.reloadData;
}

- (IBAction)showThePicture:(id)sender {
    NSLog(@"pic!!");
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[sender superview] superview]];
    pictureAlert= [[UIAlertView alloc] initWithTitle:nil message:@"\n\n\n\n\n\n\n\n\n\n\n\n\n" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 265, 285)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    //.image = [UIImage imageNamed:@"fishtankaquariumcombo.jpg"];
    NSString *imageUrl= [NSString stringWithFormat:@"http://dichoapp.com/dichoImages/%@.jpeg", [dichoIDsArray objectAtIndex:indexPath.row]];
    //NSString *imageUrl= [NSString stringWithFormat:@"http://dichoapp.com/userImages/6.jpeg"];
    UIImage *dichoImage = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString:imageUrl]]];
    imageView.image = dichoImage;
    imageView.backgroundColor=[UIColor clearColor];
    [pictureAlert addSubview:imageView];
    [pictureAlert show];
}

-(IBAction)results:(id)sender{
    
}

@end
