//
//  DICHOSingleUserResultsViewController.m
//  Dicho
//
//  Created by Tyler Droll on 5/13/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOSingleUserResultsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>
#import "DICHOSUShowAnswerersViewController.h"

@interface DICHOSingleUserResultsViewController ()

@end

@implementation DICHOSingleUserResultsViewController
@synthesize resultsAlert;
@synthesize firstWidth;
@synthesize secondWidth;
@synthesize shareAlert;

- (id)initWithStyle:(UITableViewStyle)style
{
    style = UITableViewStyleGrouped;
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithDichoID:(NSString*)aDichoID Dicho:(NSString*)aDicho FirstAnswer:(NSString*)aFirstAnswer SecondAnswer:(NSString*)aSecondAnswer{
    self = [super init];
    if( !self) return nil;
    self.title = @"Dicho Results";

    dichoID = aDichoID;
    dicho = aDicho;
    firstAnswer = aFirstAnswer;
    secondAnswer = aSecondAnswer;
    
    return self;
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
- (void)viewDidLoad
{
    [super viewDidLoad];
    prefs= [NSUserDefaults standardUserDefaults];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.94 green:0.98 blue:1.0 alpha:1.0];
    self.tableView.contentInset = UIEdgeInsetsMake(-20.0, 0, 0, 0);

    
    self.tableView.sectionFooterHeight= 0.0;
    self.tableView.sectionHeaderHeight = 10.0;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Share"
                                                                    style:UIBarButtonItemStyleBordered target:self action:@selector(share:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0];

    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    
    firstPercent = @"0";
    secondPercent = @"0";
    firstVotes = @"0";
    secondVotes = @"0";
    totalVotes = @"0";
    firstWidth = 0;
    secondWidth = 0;
    
    
    NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/results.php?dichoID=%@", dichoID];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 10.0];
    resultsConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==2)
        return 3;
    else return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0){
        NSString *text = dicho;
        CGSize constraint = CGSizeMake(292, 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont fontWithName:@"ArialMT" size:17.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat height = MAX(size.height, 13.0f);
        return height + 20;
    }if(indexPath.section==1)
        return 90;
    else return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0){
        static NSString *CellIdentifier = @"dichoCell";
       
        UILabel *questionLabel;
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            //create, format, and add question label
            questionLabel = [[UILabel alloc] init];
            questionLabel.tag =1;
            questionLabel.numberOfLines = 0;
            [questionLabel sizeToFit];
            questionLabel.font = [UIFont fontWithName:@"ArialMT" size:17.0f];
            questionLabel.textAlignment = NSTextAlignmentLeft;
            questionLabel.textColor = [UIColor blackColor];
            questionLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:questionLabel];
            
            
        }else{
            questionLabel = (UILabel *)[cell.contentView viewWithTag:1];
        }
        
        questionLabel.text =dicho;
        NSString *text = dicho;
        CGSize constraint = CGSizeMake(292, 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont fontWithName:@"ArialMT" size:17.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        [questionLabel setFrame:CGRectMake(10, 10, 300, MAX(size.height, 13.0f))];
        
        
        return cell;
    }else if(indexPath.section==1 && indexPath.row==0){
        static NSString *CellIdentifier = @"resultsCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        
        UILabel *firstAnswerLabel;
        UILabel *secondAnswerLabel;
        UILabel *firstAnswerBar;
        UILabel *secondAnswerBar;
        UILabel *secondAnswerBarLabel;
        
                
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            firstAnswerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 300, 21)];
            firstAnswerLabel.text = firstAnswer;
            firstAnswerLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:17.0];
            firstAnswerLabel.textColor = [UIColor blackColor];
            firstAnswerLabel.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:firstAnswerLabel];
            
            secondAnswerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 64, 300, 21)];
            secondAnswerLabel.text = secondAnswer;
            secondAnswerLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:17.0];
            secondAnswerLabel.textColor = [UIColor blackColor];
            secondAnswerLabel.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:secondAnswerLabel];
            
            firstAnswerBar = [[UILabel alloc] init];
            firstAnswerBar.text = [NSString stringWithFormat:@" %@%%", firstPercent];
            firstAnswerBar.textAlignment = NSTextAlignmentLeft;
            firstAnswerBar.frame = CGRectMake(10, 30, firstWidth, 30);
            firstAnswerBar.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0f];
            firstAnswerBar.textColor = [UIColor whiteColor];
            firstAnswerBar.backgroundColor = [UIColor  colorWithRed:0.0 green:0.25 blue:0.5 alpha:1.0];
            [cell.contentView addSubview:firstAnswerBar];
            
            secondAnswerBar = [[UILabel alloc] init];
            secondAnswerBar.frame = CGRectMake(310-secondWidth, 30, secondWidth, 30);
            secondAnswerBar.backgroundColor = [UIColor  colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0];
            [cell.contentView addSubview:secondAnswerBar];
            
            secondAnswerBarLabel = [[UILabel alloc] init];
            secondAnswerBarLabel.text = [NSString stringWithFormat:@"%@%%", secondPercent];
            secondAnswerBarLabel.textAlignment = NSTextAlignmentRight;
            secondAnswerBarLabel.frame = CGRectMake(310-secondWidth, 30, secondWidth-5, 30);
            secondAnswerBarLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0f];
            secondAnswerBarLabel.textColor = [UIColor whiteColor];
            secondAnswerBarLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:secondAnswerBarLabel];
            
        }
        return cell;
        
    }else if(indexPath.section==2 && indexPath.row==0){
        static NSString *CellIdentifier = @"votesCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UILabel* firstAnswerLabel;
        UILabel* firstAnswerVotes;
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            firstAnswerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 11, 232, 21)];
            firstAnswerLabel.text = firstAnswer;
            firstAnswerLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:14.0];
            firstAnswerLabel.textColor = [UIColor blackColor];
            firstAnswerLabel.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:firstAnswerLabel];
            
            firstAnswerVotes = [[UILabel alloc] initWithFrame:CGRectMake(252, 11, 58, 21)];
            firstAnswerVotes.text = [NSString stringWithFormat:@"%@", firstVotes];
            firstAnswerVotes.font = [UIFont fontWithName:@"ArialMT" size:14.0];
            firstAnswerVotes.textColor = [UIColor blackColor];
            firstAnswerVotes.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:firstAnswerVotes];
        }
        return cell;
        
    }else if(indexPath.section==2 && indexPath.row==1){
        static NSString *CellIdentifier = @"votesCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UILabel *secondAnswerLabel;
        UILabel *secondAnswerVotes;
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            secondAnswerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 11, 232, 21)];
            secondAnswerLabel.text = secondAnswer;
            secondAnswerLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:14.0];
            secondAnswerLabel.textColor = [UIColor blackColor];
            secondAnswerLabel.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:secondAnswerLabel];
            
            secondAnswerVotes = [[UILabel alloc] initWithFrame:CGRectMake(252, 11, 58, 21)];
            secondAnswerVotes.text = [NSString stringWithFormat:@"%@", secondVotes];
            secondAnswerVotes.font = [UIFont fontWithName:@"ArialMT" size:14.0];
            secondAnswerVotes.textColor = [UIColor blackColor];
            secondAnswerVotes.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:secondAnswerVotes];
        }
        return cell;
        
    }else if(indexPath.section==2 && indexPath.row==2){
        static NSString *CellIdentifier = @"votesCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UILabel *totalVotesLabel;
        UILabel *totalVotesNumber;
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            totalVotesLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 11, 232, 21)];
            totalVotesLabel.text = @"Total Votes";
            totalVotesLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:14.0];
            totalVotesLabel.textColor = [UIColor blackColor];
            totalVotesLabel.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:totalVotesLabel];
            
            totalVotesNumber = [[UILabel alloc] initWithFrame:CGRectMake(252, 11, 58, 21)];
            totalVotesNumber.text = [NSString stringWithFormat:@"%@", totalVotes];
            totalVotesNumber.font = [UIFont fontWithName:@"ArialMT" size:14.0];
            totalVotesNumber.textColor = [UIColor blackColor];
            totalVotesNumber.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:totalVotesNumber];
        }
        return cell;
    }else{
        static NSString *CellIdentifier = @"showAnswerersCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
        
        UILabel *seeAnswerersLabel;
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            seeAnswerersLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, 11, 193, 21)];
            seeAnswerersLabel.text = @"See Answerers";
            seeAnswerersLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:16.0];
            seeAnswerersLabel.textColor = [UIColor blackColor];
            seeAnswerersLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:seeAnswerersLabel];
        }
        
        return cell;
    }

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==3){        
        DICHOSUShowAnswerersViewController *nextVC = [[DICHOSUShowAnswerersViewController alloc] initWithDichoID:dichoID];
        [self.navigationController pushViewController:nextVC animated:YES];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    resultsData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [resultsData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self parseGoodResults];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self handleResultsFail];
}

-(void)parseGoodResults{
    NSString *returnedResults = [[NSString alloc] initWithData:resultsData encoding: NSUTF8StringEncoding];
    returnedResults  = [returnedResults stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *resultsStringComponents = [returnedResults componentsSeparatedByString:@"%%"];
    firstPercent = [resultsStringComponents objectAtIndex:1];
    secondPercent = [resultsStringComponents objectAtIndex:2];
    firstVotes = [resultsStringComponents objectAtIndex:3];
    secondVotes = [resultsStringComponents objectAtIndex:4];
    totalVotes = [resultsStringComponents objectAtIndex:5];
    
    
    //298 pixels to split up
    float firstValue = [firstPercent floatValue];
    float secondValue = [secondPercent floatValue];
    
    
    if(firstValue==0 && secondValue==0){
        firstWidth=0;
        secondWidth=0;
    }else if(firstValue<10){
        firstWidth = 31;
        secondWidth = 267;
    }else if(firstValue<13){
        firstWidth = 38;
        secondWidth = 260;
    }else if(firstValue>90){
        firstWidth = 267;
        secondWidth = 31;
    }else if(firstValue>87){
        firstWidth = 260;
        secondWidth = 38;
    }else{
        firstWidth = 2.98*firstValue;
        secondWidth = 300-2-firstWidth;
    }
    
    NSIndexPath* barRow = [NSIndexPath indexPathForRow:0 inSection:1];
    NSIndexPath* votesRow0 = [NSIndexPath indexPathForRow:0 inSection:2];
    NSIndexPath* votesRow1 = [NSIndexPath indexPathForRow:1 inSection:2];
    NSIndexPath* votesRow2 = [NSIndexPath indexPathForRow:2 inSection:2];
    
    NSArray* rowsToReload = [NSArray arrayWithObjects:barRow, votesRow0, votesRow1, votesRow2, nil];
    [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
    

     [self performSelector:@selector(takeScreenshot) withObject:nil afterDelay:0.5];
    
    

}

-(void)takeScreenshot{
    
    UIWindow *screenWindow = [[UIApplication sharedApplication] keyWindow];
    UIGraphicsBeginImageContextWithOptions(screenWindow.frame.size,YES,0.0f);
    [screenWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.navigationItem.rightBarButtonItem.enabled = YES;

}

-(void)handleResultsFail{
    resultsAlert = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [resultsAlert show];
    
}
- (IBAction)share:(id)sender {
    shareAlert = [[UIAlertView alloc] initWithTitle:@"Share Results" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Twitter", @"Facebook", nil];
    [shareAlert show];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView==shareAlert)
    {
        if(buttonIndex==1){ //share to Twitter
            
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
            {
                SLComposeViewController *tweetSheet = [SLComposeViewController
                                                       composeViewControllerForServiceType:SLServiceTypeTwitter];
                [tweetSheet setInitialText:@"Check out these results on Dicho!"];
                [tweetSheet addImage:screenshot];
                
                [self presentViewController:tweetSheet animated:YES completion:nil];
            }
            
        }else if(buttonIndex==2){ //share To Facebook
            
            if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
                SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                
                [controller setInitialText:@"Check out these results on Dicho!"];
                [controller addImage:screenshot];
                
                [self presentViewController:controller animated:YES completion:Nil];
            }
        }
    }
}
@end
