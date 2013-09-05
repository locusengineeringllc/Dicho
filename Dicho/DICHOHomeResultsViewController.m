//
//  DICHOHomeResultsViewController.m
//  Dicho
//
//  Created by Tyler Droll on 5/24/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOHomeResultsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>

@interface DICHOHomeResultsViewController ()

@end

@implementation DICHOHomeResultsViewController
@synthesize homeResultsTable;
@synthesize resultsAlert;
@synthesize firstWidth;
@synthesize secondWidth;
@synthesize shareAlert;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated{
    NSString *loginStatus = [prefs objectForKey:@"loggedIn"];
    NSString *firstTimeStatus = [prefs objectForKey:@"firstTimeToHome"];
    
    if([loginStatus isEqualToString:@"no"]){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else if([firstTimeStatus isEqualToString:@"yes"]){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    prefs= [NSUserDefaults standardUserDefaults];
    homeResultsTable.backgroundView = nil;
    homeResultsTable.backgroundColor = [UIColor colorWithRed:0.94 green:0.98 blue:1.0 alpha:1.0];
    
    homeResultsTable.sectionFooterHeight= 0.0;
    homeResultsTable.sectionHeaderHeight = 8.0;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    NSString *fullDichoString = [prefs objectForKey:@"homeSelectedDichoString"];
    NSArray *dichoStringComponents = [fullDichoString componentsSeparatedByString:@"|"];
    
    dichoID = [dichoStringComponents objectAtIndex:0];
    dicho = [dichoStringComponents objectAtIndex:1];
    firstAnswer = [dichoStringComponents objectAtIndex:2];
    secondAnswer = [dichoStringComponents objectAtIndex:3];
    
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
        CGSize constraint = CGSizeMake(280, 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:17.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat height = MAX(size.height, 13.0f);
        return height + 10;
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
        CGSize constraint = CGSizeMake(280, 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont fontWithName:@"ArialMT" size:17.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        [questionLabel setFrame:CGRectMake(10, 5, 280, MAX(size.height, 13.0f))];
        
        return cell;
    }else if(indexPath.section==1 && indexPath.row==0){
        static NSString *CellIdentifier = @"resultsCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UILabel *firstAnswerLabel = (UILabel *) [cell viewWithTag:1];
        firstAnswerLabel.text = firstAnswer;
        UILabel *secondAnswerLabel = (UILabel *) [cell viewWithTag:2];
        secondAnswerLabel.text = secondAnswer;
        
        UILabel *firstAnswerBar = [[UILabel alloc] init];
        firstAnswerBar.text = [NSString stringWithFormat:@" %@%%", firstPercent];
        firstAnswerBar.textAlignment = NSTextAlignmentLeft;
        firstAnswerBar.frame = CGRectMake(10, 30, firstWidth, 30);
        firstAnswerBar.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0f];
        firstAnswerBar.textColor = [UIColor whiteColor];
        firstAnswerBar.backgroundColor = [UIColor  colorWithRed:0.0 green:0.25 blue:0.5 alpha:1.0];
        [cell.contentView addSubview:firstAnswerBar];
        
        UILabel *secondAnswerBar = [[UILabel alloc] init];
        secondAnswerBar.text = [NSString stringWithFormat:@"%@%% ", secondPercent];
        secondAnswerBar.textAlignment = NSTextAlignmentRight;
        secondAnswerBar.frame = CGRectMake(290-secondWidth, 30, secondWidth, 30);
        secondAnswerBar.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0f];
        secondAnswerBar.textColor = [UIColor whiteColor];
        secondAnswerBar.backgroundColor = [UIColor  colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0];
        [cell.contentView addSubview:secondAnswerBar];
        
        return cell;
        
    }else if(indexPath.section==2 && indexPath.row==0){
        static NSString *CellIdentifier = @"votesCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UILabel *firstAnswerLabel = (UILabel *) [cell viewWithTag:1];
        firstAnswerLabel.text = firstAnswer;
        UILabel *firstAnswerVotes = (UILabel *) [cell viewWithTag:2];
        firstAnswerVotes.text = [NSString stringWithFormat:@"%@", firstVotes];
        return cell;
        
    }else if(indexPath.section==2 && indexPath.row==1){
        static NSString *CellIdentifier = @"votesCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UILabel *secondAnswerLabel = (UILabel *) [cell viewWithTag:1];
        secondAnswerLabel.text = secondAnswer;
        UILabel *secondAnswerVotes = (UILabel *) [cell viewWithTag:2];
        secondAnswerVotes.text = [NSString stringWithFormat:@"%@", secondVotes];
        return cell;
        
    }else if(indexPath.section==2 && indexPath.row==2){
        static NSString *CellIdentifier = @"votesCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UILabel *totalVotesLabel = (UILabel *) [cell viewWithTag:1];
        totalVotesLabel.text = @"Total Votes";
        UILabel *totalVotesNumber = (UILabel *) [cell viewWithTag:2];
        totalVotesNumber.text = [NSString stringWithFormat:@"%@", totalVotes];
        return cell;
    }else{
        static NSString *CellIdentifier = @"showAnswerersCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
    }
    
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==3){
        [prefs setObject:dichoID forKey:@"homeSelectedDichoID"];
        [self performSegueWithIdentifier:@"homeResultsToShowAnswerers" sender:self];
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
    
    //278 pixels to split up
    float firstValue = [firstPercent floatValue];
    float secondValue = [secondPercent floatValue];
    
    if(firstValue==0 && secondValue==0){
        firstWidth=0;
        secondWidth=0;
    }else if(firstValue<10){
        firstWidth = 31;
        secondWidth = 247;
    }else if(firstValue<16){
        firstWidth = 39;
        secondWidth = 239;
    }else if(firstValue>90){
        firstWidth = 247;
        secondWidth = 31;
    }else if(firstValue>84){
        firstWidth = 239;
        secondWidth = 39;
    }else{
        firstWidth = 2.78*firstValue;
        secondWidth = 280-2-firstWidth;
    }
    NSIndexPath* barRow = [NSIndexPath indexPathForRow:0 inSection:1];
    NSIndexPath* votesRow0 = [NSIndexPath indexPathForRow:0 inSection:2];
    NSIndexPath* votesRow1 = [NSIndexPath indexPathForRow:1 inSection:2];
    NSIndexPath* votesRow2 = [NSIndexPath indexPathForRow:2 inSection:2];
    
    NSArray* rowsToReload = [NSArray arrayWithObjects:barRow, votesRow0, votesRow1, votesRow2, nil];
    [homeResultsTable reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    UIWindow *screenWindow = [[UIApplication sharedApplication] keyWindow];
    UIGraphicsBeginImageContextWithOptions(screenWindow.frame.size,YES,0.0f);
    [screenWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
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
