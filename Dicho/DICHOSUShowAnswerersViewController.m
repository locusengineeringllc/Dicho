//
//  DICHOSUShowAnswerersViewController.m
//  Dicho
//
//  Created by Tyler Droll on 5/13/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOSUShowAnswerersViewController.h"
#import "DICHOSingleUserViewController.h"

@interface DICHOSUShowAnswerersViewController ()

@end

@implementation DICHOSUShowAnswerersViewController
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

-(id)initWithDichoID:(NSString *)aDichoID{
    self = [super init];
    if( !self) return nil;
    self.title = @"Answerers";
    selectedDichoID = aDichoID;
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
    
	// Do any additional setup after loading the view.
    firstAnswerersTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 160, self.view.bounds.size.height) style:UITableViewStylePlain];
    firstAnswerersTable.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    firstAnswerersTable.dataSource = self;
    firstAnswerersTable.delegate = self;
    [self.view addSubview:firstAnswerersTable];
    
    secondAnswerersTable = [[UITableView alloc] initWithFrame:CGRectMake(160, 0, 160, self.view.bounds.size.height) style:UITableViewStylePlain];
    secondAnswerersTable.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    secondAnswerersTable.dataSource = self;
    secondAnswerersTable.delegate = self;
    [self.view addSubview:secondAnswerersTable];
    secondAnswerersTable.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0);

    
    
    firstNamesArray = [[NSMutableArray alloc] init];
    firstUserIDsArray = [[NSMutableArray alloc] init];
    secondNamesArray = [[NSMutableArray alloc] init];
    secondUserIDsArray = [[NSMutableArray alloc] init];
    
    self.firstAnswerersTable.layer.borderWidth = 1.0;
    self.secondAnswerersTable.layer.borderWidth = 1.0;
    self.firstAnswerersTable.layer.borderColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0].CGColor;
    self.secondAnswerersTable.layer.borderColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0].CGColor;
    
    firstAnswerersTable.userInteractionEnabled = NO;
    //call php for each array of names
    NSString *firstURL = [NSString stringWithFormat:@"http://dichoapp.com/files/showAnswerers2.php?dichoID=%@&answer=1&displayedNumber=0", selectedDichoID];
    NSURLRequest* request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:firstURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 15.0];
    firstNamesConnection = [[NSURLConnection alloc] initWithRequest:request1 delegate:self];
    
    secondAnswerersTable.userInteractionEnabled = NO;
    //now for the second
    NSString *secondURL = [NSString stringWithFormat:@"http://dichoapp.com/files/showAnswerers2.php?dichoID=%@&answer=2&displayedNumber=0", selectedDichoID];
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
        return [firstUserIDsArray count]+1;
    else return [secondUserIDsArray count]+1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == self.firstAnswerersTable){
        if(indexPath.row == [firstUserIDsArray count])
            return 50;
        else return 30;
    }else{
        if(indexPath.row == [secondUserIDsArray count])
            return 50;
        else return 30;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == firstAnswerersTable){
        if(indexPath.row<[firstUserIDsArray count]){
            static NSString *CellIdentifier = @"answererCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            UILabel *name;
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.backgroundColor = [UIColor whiteColor];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                
                name = [[UILabel alloc] initWithFrame:CGRectMake(5, 4, 150, 21)];
                name.tag = 1;
                name.text = [firstNamesArray objectAtIndex:indexPath.row];
                name.font = [UIFont fontWithName:@"Arial-BoldMT" size:14.0];
                name.adjustsFontSizeToFitWidth = YES;
                name.textColor = [UIColor blackColor];
                name.textAlignment = NSTextAlignmentLeft;
                [cell.contentView addSubview:name];
                
            }else{
                name = (UILabel *)[cell.contentView viewWithTag:1];
            }
            name.text = [firstNamesArray objectAtIndex:indexPath.row];

            return cell;
            
        }else{
            static NSString *CellIdentifier = @"loadMoreCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            UILabel *loadMoreLabel;
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.backgroundColor = [UIColor whiteColor];
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                
                loadMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(23, 14, 114, 21)];
                loadMoreLabel.text = @"Load more...";
                loadMoreLabel.font = [UIFont fontWithName:@"ArialMT" size:14.0];
                loadMoreLabel.textColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0];
                loadMoreLabel.textAlignment = NSTextAlignmentCenter;
                [cell.contentView addSubview:loadMoreLabel];
                
            }
            return cell;
            
        }
    }else{
        if(indexPath.row<[secondUserIDsArray count]){
            static NSString *CellIdentifier = @"answererCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            UILabel *name;
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.backgroundColor = [UIColor whiteColor];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                
                name = [[UILabel alloc] initWithFrame:CGRectMake(5, 4, 150, 21)];
                name.tag = 1;
                name.text = [secondNamesArray objectAtIndex:indexPath.row];
                name.font = [UIFont fontWithName:@"Arial-BoldMT" size:14.0];
                name.adjustsFontSizeToFitWidth = YES;
                name.textColor = [UIColor blackColor];
                name.textAlignment = NSTextAlignmentLeft;
                [cell.contentView addSubview:name];
                
            }else{
                name = (UILabel *)[cell.contentView viewWithTag:1];
            }
            name.text = [secondNamesArray objectAtIndex:indexPath.row];

            return cell;
            
        }else{
            static NSString *CellIdentifier = @"loadMoreCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            UILabel *loadMoreLabel;
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.backgroundColor = [UIColor whiteColor];
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                
                loadMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(23, 14, 114, 21)];
                loadMoreLabel.text = @"Load more...";
                loadMoreLabel.font = [UIFont fontWithName:@"ArialMT" size:14.0];
                loadMoreLabel.textColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0];
                loadMoreLabel.textAlignment = NSTextAlignmentCenter;
                [cell.contentView addSubview:loadMoreLabel];
                
            }
            return cell;
            
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.firstAnswerersTable){
        if(indexPath.row == [firstUserIDsArray count]){
            firstAnswerersTable.userInteractionEnabled = NO;
            
            NSString *firstURL = [NSString stringWithFormat:@"http://dichoapp.com/files/showAnswerers2.php?dichoID=%@&answer=1&displayedNumber=%d", selectedDichoID, [firstNamesArray count]];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:firstURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 15.0];
            firstLoadMoreConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        }else{
            DICHOSingleUserViewController *nextVC = [[DICHOSingleUserViewController alloc] initWithUsername: [firstNamesArray objectAtIndex:indexPath.row] askerID:[firstUserIDsArray objectAtIndex:indexPath.row]];
            [self.navigationController pushViewController:nextVC animated:YES];
        }
    }else if(tableView == self.secondAnswerersTable){
        if(indexPath.row == [secondUserIDsArray count]){
            secondAnswerersTable.userInteractionEnabled = NO;
            
            NSString *secondURL = [NSString stringWithFormat:@"http://dichoapp.com/files/showAnswerers2.php?dichoID=%@&answer=2&displayedNumber=%d", selectedDichoID, [secondNamesArray count]];
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:secondURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 15.0];
            secondLoadMoreConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        }else{
            DICHOSingleUserViewController *nextVC = [[DICHOSingleUserViewController alloc] initWithUsername: [secondNamesArray objectAtIndex:indexPath.row] askerID:[secondUserIDsArray objectAtIndex:indexPath.row]];
            [self.navigationController pushViewController:nextVC animated:YES];
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
        i=i+1;
        [firstUserIDsArray addObject:[firstNamesNSArray objectAtIndex:i]];
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
        i=i+1;
        [secondUserIDsArray addObject:[secondNamesNSArray objectAtIndex:i]];
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
            i=i+1;
            [firstUserIDsArray addObject:[firstNamesNSArray objectAtIndex:i]];
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
            i=i+1;
            [secondUserIDsArray addObject:[secondNamesNSArray objectAtIndex:i]];
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
