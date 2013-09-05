//
//  DICHOShowAnswerersViewController.m
//  Dicho
//
//  Created by Tyler Droll on 1/3/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOShowAnswerersViewController.h"

@interface DICHOShowAnswerersViewController ()

@end

@implementation DICHOShowAnswerersViewController
@synthesize firstAnswerersTable;
@synthesize secondAnswerersTable;
@synthesize showAnswerersAlert;

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
    NSString *firstTimeStatus = [prefs objectForKey:@"firstTimeToDicho"];
    
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

	// Do any additional setup after loading the view.
    firstNamesArray = [[NSMutableArray alloc] init];
    secondNamesArray = [[NSMutableArray alloc] init];
    self.firstAnswerersTable.layer.borderWidth = 1.0;
    self.secondAnswerersTable.layer.borderWidth = 1.0;
    self.firstAnswerersTable.layer.borderColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0].CGColor;
    self.secondAnswerersTable.layer.borderColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0].CGColor;
    

    firstAnswerersTable.userInteractionEnabled = NO;
    //call php for each array of names
    selectedDichoID = [prefs objectForKey:@"mainSelectedDichoID"];
    NSString *firstURL = [NSString stringWithFormat:@"http://dichoapp.com/files/showAnswerers.php?dichoID=%@&answer=1&displayedNumber=0", selectedDichoID];
    NSURLRequest* request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:firstURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 15.0];
    firstNamesConnection = [[NSURLConnection alloc] initWithRequest:request1 delegate:self];
    
    secondAnswerersTable.userInteractionEnabled = NO;
    //now for the second
    NSString *secondURL = [NSString stringWithFormat:@"http://dichoapp.com/files/showAnswerers.php?dichoID=%@&answer=2&displayedNumber=0", selectedDichoID];
    NSURLRequest* request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:secondURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 15.0];
    secondNamesConnection = [[NSURLConnection alloc] initWithRequest:request2 delegate:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.firstAnswerersTable)
        return [firstNamesArray count]+1;
    else return [secondNamesArray count]+1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == self.firstAnswerersTable){
        if(indexPath.row == [firstNamesArray count])
            return 50;
        else return 30;
    }else{
        if(indexPath.row == [secondNamesArray count])
            return 50;
        else return 30;
    }    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.firstAnswerersTable){
        if(indexPath.row<[firstNamesArray count]){
            static NSString *CellIdentifier = @"answererCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            UILabel *name = (UILabel *)[cell viewWithTag:1];
            name.text = [firstNamesArray objectAtIndex:indexPath.row];
            return cell;
            
        }else{
            static NSString *CellIdentifier = @"loadMoreCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];            
            return cell;
        }
    }else{
        if(indexPath.row<[secondNamesArray count]){
            static NSString *CellIdentifier = @"answererCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            UILabel *name = (UILabel *)[cell viewWithTag:1];
            name.text = [secondNamesArray objectAtIndex:indexPath.row];
            return cell;
            
        }else{
        static NSString *CellIdentifier = @"loadMoreCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.firstAnswerersTable){
        if(indexPath.row == [firstNamesArray count]){
            firstAnswerersTable.userInteractionEnabled = NO;

            NSString *firstURL = [NSString stringWithFormat:@"http://dichoapp.com/files/showAnswerers.php?dichoID=%@&answer=1&displayedNumber=%d", selectedDichoID, [firstNamesArray count]];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:firstURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 15.0];
            firstLoadMoreConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        }
    }else if(tableView == self.secondAnswerersTable){
        if(indexPath.row == [secondNamesArray count]){
            secondAnswerersTable.userInteractionEnabled = NO;

            NSString *secondURL = [NSString stringWithFormat:@"http://dichoapp.com/files/showAnswerers.php?dichoID=%@&answer=2&displayedNumber=%d", selectedDichoID, [secondNamesArray count]];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:secondURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 15.0];
            secondLoadMoreConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if(connection==firstNamesConnection){
        firstNamesData = [[NSMutableData alloc] init];
    }else if(connection==secondNamesConnection){
        secondNamesData = [[NSMutableData alloc] init];
    }else if(connection==firstLoadMoreConnection){
        firstLoadMoreData = [[NSMutableData alloc] init];
    }else if(connection==secondLoadMoreConnection){
        secondLoadMoreData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(connection==firstNamesConnection){
        [firstNamesData appendData:data];
    }else if(connection==secondNamesConnection){
        [secondNamesData appendData:data];
    }else if(connection==firstLoadMoreConnection){
        [firstLoadMoreData appendData:data];
    }else if(connection==secondLoadMoreConnection){
        [secondLoadMoreData appendData:data];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(connection==firstNamesConnection){
        [self parseFirstNamesData];
    }else if(connection==secondNamesConnection){
        [self parseSecondNamesData];
    }else if(connection==firstLoadMoreConnection){
        [self parseFirstLoadMoreData];
    }else if(connection==secondLoadMoreConnection){
        [self parseSecondLoadMoreData];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self handleConnectionFail];
}

-(void)parseFirstNamesData{
    NSString *firstReturnedNames = [[NSString alloc] initWithData:firstNamesData encoding: NSUTF8StringEncoding];
    firstReturnedNames = [firstReturnedNames stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *firstNamesNSArray= [firstReturnedNames componentsSeparatedByString:@"|"];
    for(int i=0;i<[firstNamesNSArray count]-1; i++){
        [firstNamesArray addObject:[firstNamesNSArray objectAtIndex:i]];
    }
    [firstAnswerersTable reloadData];
    firstAnswerersTable.userInteractionEnabled = YES;

}
-(void)parseSecondNamesData{
    NSString *secondReturnedNames = [[NSString alloc] initWithData:secondNamesData encoding: NSUTF8StringEncoding];
    secondReturnedNames = [secondReturnedNames stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *secondNamesNSArray= [secondReturnedNames componentsSeparatedByString:@"|"];
    for(int i=0;i<[secondNamesNSArray count]-1; i++){
        [secondNamesArray addObject:[secondNamesNSArray objectAtIndex:i]];
    }
    [secondAnswerersTable reloadData];
    secondAnswerersTable.userInteractionEnabled = YES;

}
-(void)parseFirstLoadMoreData{
    NSString *firstReturnedNames = [[NSString alloc] initWithData:firstLoadMoreData encoding: NSUTF8StringEncoding];
    firstReturnedNames = [firstReturnedNames stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([firstReturnedNames isEqualToString:@""]){
        showAnswerersAlert= [[UIAlertView alloc] initWithTitle:@"End of Answerers List" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [showAnswerersAlert show];
        [self.firstAnswerersTable deselectRowAtIndexPath:[NSIndexPath indexPathForRow:[firstNamesArray count] inSection:0] animated:YES];
    }else{
        NSArray *firstNamesNSArray= [firstReturnedNames componentsSeparatedByString:@"|"];
        for(int i=0;i<[firstNamesNSArray count]-1; i++){
            [firstNamesArray addObject:[firstNamesNSArray objectAtIndex:i]];
        }
        [firstAnswerersTable reloadData];
    }
    firstAnswerersTable.userInteractionEnabled = YES;
}
-(void)parseSecondLoadMoreData{
    NSString *secondReturnedNames = [[NSString alloc] initWithData:secondLoadMoreData encoding: NSUTF8StringEncoding];
    secondReturnedNames = [secondReturnedNames stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([secondReturnedNames isEqualToString:@""]){
        showAnswerersAlert= [[UIAlertView alloc] initWithTitle:@"End of Answerers List" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [showAnswerersAlert show];
        [self.secondAnswerersTable deselectRowAtIndexPath:[NSIndexPath indexPathForRow:[secondNamesArray count] inSection:0] animated:YES];
    }else{
        NSArray *secondNamesNSArray= [secondReturnedNames componentsSeparatedByString:@"|"];
        for(int i=0;i<[secondNamesNSArray count]-1; i++){
            [secondNamesArray addObject:[secondNamesNSArray objectAtIndex:i]];
        }
        [secondAnswerersTable reloadData];
    }
    secondAnswerersTable.userInteractionEnabled = YES;

}
-(void)handleConnectionFail{
    showAnswerersAlert = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [showAnswerersAlert show];
    firstAnswerersTable.userInteractionEnabled = YES;
    secondAnswerersTable.userInteractionEnabled = YES;

    
}

@end
