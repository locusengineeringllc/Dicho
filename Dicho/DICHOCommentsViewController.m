//
//  DICHOCommentsViewController.m
//  Dicho
//
//  Created by Tyler Droll on 8/17/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOCommentsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DICHOSingleUserViewController.h"
#import "DICHOShowLikesViewController.h"

@interface DICHOCommentsViewController ()

@end

@implementation DICHOCommentsViewController
@synthesize commentTextView;
@synthesize postButton;
@synthesize commentsTable;
@synthesize loadedAll;
@synthesize likingRow;
@synthesize deletingRow;
@synthesize progressAlert;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithDichoID:(NSString*)aDichoID{
    self = [super init];
    if( !self) return nil;
    self.title = @"Comments";
    selectedDichoID = aDichoID;
    loadedAll = NO;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    prefs= [NSUserDefaults standardUserDefaults];
    userID = [prefs objectForKey:@"userID"];

    self.view.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    
    //make comment box
    commentTextView = [[UITextView alloc] initWithFrame:CGRectMake(7, self.view.bounds.size.height-90, 253, 33)];    //134, 33
    commentTextView.text = @"Add a comment...";
    commentTextView.font = [UIFont fontWithName:@"ArialMT" size:14.0];
    commentTextView.textAlignment = NSTextAlignmentLeft;
    commentTextView.keyboardType = UIKeyboardTypeASCIICapable;
    commentTextView.delegate = self;
    commentTextView.textColor = [UIColor lightGrayColor];
    commentTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    commentTextView.layer.cornerRadius = 3.0;
    commentTextView.contentInset = UIEdgeInsetsMake(-64, 0, -64, 0);
    [self.view addSubview:commentTextView];


    
    //create and add post button and title
    postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [postButton addTarget:self action:@selector(postComment:) forControlEvents:UIControlEventTouchUpInside];
    [postButton setFrame:CGRectMake(267, self.view.bounds.size.height-90, 46, 33)]; //134
    [postButton setTitle:@"Post" forState:UIControlStateNormal];
    postButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:14.0f];
    postButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.45 blue:0.9 alpha:0.5];
    postButton.layer.cornerRadius = 3.0f;
    postButton.enabled = NO;
    postButton.showsTouchWhenHighlighted = YES;
    [postButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    postButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.view addSubview:postButton];
    
    //make comments table
    commentsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 320, self.view.bounds.size.height-161) style:UITableViewStylePlain];//was -47
    commentsTable.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    commentsTable.dataSource = self;
    commentsTable.delegate = self;
    commentsTable.userInteractionEnabled = NO;
    [self.view addSubview:commentsTable];
    
    
    //add doubletap recognizer to dismiss keyboard
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    commentsIDsArray = [[NSMutableArray alloc] init];
    userIDsArray = [[NSMutableArray alloc] init];
    usernamesArray = [[NSMutableArray alloc] init];
    timesSinceArray = [[NSMutableArray alloc] init];
    commentsArray = [[NSMutableArray alloc] init];
    likedArray = [[NSMutableArray alloc] init];
    numberOfLikesArray = [[NSMutableArray alloc] init];
    userImagesArray = [[NSMutableArray alloc] init];
    imageQueue = [[NSOperationQueue alloc] init];
    imageQueue.maxConcurrentOperationCount = 6;
    
    //get list of comments info
    NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/getComments.php?dichoID=%@&displayedNumber=0&userID=%@", selectedDichoID, userID];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 15.0];
    commentsInfosConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(void)viewDidAppear:(BOOL)animated{
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
        }else if(self.tabBarController.selectedIndex == 2){
            if([[prefs objectForKey:@"firstTimeToSearch"] isEqualToString:@"yes"]){
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [commentsIDsArray count] + 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        return 58;
    }else{
        NSString *text = [commentsArray objectAtIndex:indexPath.row-1];
        CGSize constraint = CGSizeMake(252, 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont fontWithName:@"ArialMT" size:14.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat height = MAX(size.height, 13.0f);
        return height + 45;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        static NSString *CellIdentifier = @"loadMoreCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UILabel *loadMoreLabel;
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            
            loadMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 18, 220, 21)];
            loadMoreLabel.tag = 1;
            loadMoreLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0];
            loadMoreLabel.textColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0];
            loadMoreLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:loadMoreLabel];
        }else{
            loadMoreLabel = (UILabel *)[cell.contentView viewWithTag:1];
        }
        
        if(loadedAll==YES){
            loadMoreLabel.text = @"Loaded all comments";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }else{
            loadMoreLabel.text = @"Load previous comments...";
        }
        
        return cell;
    }else{
            
        static NSString *CellIdentifier = @"commentCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
        UIImageView *userImageView;
        UIButton *userImageButton;
        UILabel *usernameLabel;
        UILabel *timeLabel;
        UILabel *commentLabel;
        UIButton *likeButton;
        UIButton *numberOfLikesButton;
            
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
            userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 8, 42, 42)];
            userImageView.tag = 1;
            userImageView.backgroundColor = [UIColor lightGrayColor];
            userImageView.contentMode = UIViewContentModeScaleAspectFill;
            userImageView.clipsToBounds = YES;
            userImageView.layer.cornerRadius = 5.0;
            [cell.contentView addSubview:userImageView];
                
            //create, format, and add userimagebutton
            userImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
            userImageButton.tag = 2;
            [userImageButton setFrame:CGRectMake(6, 8, 42, 42)];
            userImageButton.showsTouchWhenHighlighted = YES;
            [userImageButton setTitle:nil forState:UIControlStateNormal];
            [userImageButton addTarget:self action:@selector(goToUser:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:userImageButton];
                
            usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(56, 6, 220, 18)];
            usernameLabel.tag = 3;
            usernameLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:14.0];
            usernameLabel.textColor = [UIColor blackColor];
            usernameLabel.textAlignment = NSTextAlignmentLeft;
            usernameLabel.adjustsFontSizeToFitWidth = YES;
            [cell.contentView addSubview:usernameLabel];
                
            timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(276, 6, 40, 18)];
            timeLabel.tag = 4;
            timeLabel.font = [UIFont fontWithName:@"ArialMT" size:14.0];
            timeLabel.textColor = [UIColor colorWithWhite:0.65 alpha:1.0];
            timeLabel.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:timeLabel];
                
            commentLabel = [[UILabel alloc] init];
            commentLabel.tag = 5;
            commentLabel.numberOfLines = 0;
            commentLabel.font = [UIFont fontWithName:@"ArialMT" size:14.0];
            commentLabel.textColor = [UIColor blackColor];
            commentLabel.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:commentLabel];
                
            NSString *text = [commentsArray objectAtIndex:indexPath.row-1];
            CGSize constraint = CGSizeMake(252, 20000.0f);
            CGSize size = [text sizeWithFont:[UIFont fontWithName:@"ArialMT" size:14.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
                
            likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            likeButton.tag = 6;
            [likeButton addTarget:self action:@selector(like:) forControlEvents:UIControlEventTouchUpInside];
            [likeButton setFrame:CGRectMake(195, 17+MAX(size.height, 13.0f), 59, 30)];
            [likeButton setUserInteractionEnabled:YES];
            likeButton.showsTouchWhenHighlighted = YES;
            [likeButton setTitleColor:[UIColor colorWithWhite:0.55 alpha:1.0] forState:UIControlStateNormal];
            likeButton.titleLabel.font = [UIFont fontWithName:@"ArialMT" size:14.0f];
            likeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            if([[likedArray objectAtIndex:indexPath.row-1] isEqualToString:@"1"]){
                [likeButton setTitle:@"Unlike  •" forState:UIControlStateNormal];
            }else{
                [likeButton setTitle:@"Like  •" forState:UIControlStateNormal];
            }
            [cell.contentView addSubview:likeButton];
                
            numberOfLikesButton = [UIButton buttonWithType:UIButtonTypeCustom];
            numberOfLikesButton.tag = 7;
            [numberOfLikesButton addTarget:self action:@selector(goToLikes:) forControlEvents:UIControlEventTouchUpInside];
            [numberOfLikesButton setFrame:CGRectMake(261, 17+MAX(size.height, 13.0f), 64, 30)];
            [numberOfLikesButton setUserInteractionEnabled:YES];
            numberOfLikesButton.showsTouchWhenHighlighted = YES;
            numberOfLikesButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            [numberOfLikesButton setTitleColor:[UIColor colorWithWhite:0.55 alpha:1.0] forState:UIControlStateNormal];
            numberOfLikesButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            numberOfLikesButton.titleLabel.font = [UIFont fontWithName:@"ArialMT" size:14.0f];
            [cell.contentView addSubview:numberOfLikesButton];
                
                
        }else{
            userImageView = (UIImageView *)[cell.contentView viewWithTag:1];
            userImageButton = (UIButton *)[cell.contentView viewWithTag:2];
            usernameLabel = (UILabel *)[cell.contentView viewWithTag:3];
            timeLabel = (UILabel *)[cell.contentView viewWithTag:4];
            commentLabel = (UILabel *)[cell.contentView viewWithTag:5];
            likeButton = (UIButton *)[cell.contentView viewWithTag:6];
            numberOfLikesButton = (UIButton *)[cell.contentView viewWithTag:7];
        }
            
            
        userImageView.image = [userImagesArray objectAtIndex:indexPath.row-1];
        usernameLabel.text = [usernamesArray objectAtIndex:indexPath.row-1];
        timeLabel.text = [timesSinceArray objectAtIndex:indexPath.row-1];
            
        commentLabel.text = [commentsArray objectAtIndex:indexPath.row-1];
        NSString *text = [commentsArray objectAtIndex:indexPath.row-1];
        CGSize constraint = CGSizeMake(252, 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont fontWithName:@"ArialMT" size:14.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        [commentLabel setFrame:CGRectMake(56, 24, 260, MAX(size.height, 13.0f))];
            
        //set like button frame, format, and text
        [likeButton setFrame:CGRectMake(195, 17+MAX(size.height, 13.0f), 59, 30)];
            
        if([[likedArray objectAtIndex:indexPath.row-1] isEqualToString:@"1"]){
                [likeButton setTitle:@"Unlike  •" forState:UIControlStateNormal];
        }else{
                [likeButton setTitle:@"Like  •" forState:UIControlStateNormal];
        }
            
            
        //set number of likes button frame, and text
        [numberOfLikesButton setFrame:CGRectMake(261, 17+MAX(size.height, 13.0f), 64, 30)];
        [numberOfLikesButton setTitle:[NSString stringWithFormat:@"%@ likes", [numberOfLikesArray objectAtIndex:indexPath.row-1]] forState:UIControlStateNormal];
            
        return cell;
    }

}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row>0){
        if([[userIDsArray objectAtIndex:indexPath.row-1] isEqualToString:userID]){
            return YES;
        }else return NO;
    }else return NO;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        progressAlert= [[UIAlertView alloc] initWithTitle:nil message:@"Deleting..." delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [progressAlert show];
        
        //set delete row
        deletingRow = indexPath.row;
        
        //call delete php
        NSString *strURL = [NSString stringWithFormat: @"http://dichoapp.com/files/deleteComment.php?dichoID=%@&commentID=%@", selectedDichoID, [commentsIDsArray objectAtIndex:indexPath.row-1]];
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
        deleteConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }   
      
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ///load more!
    if(indexPath.row == 0 && loadedAll==NO){
        commentsTable.userInteractionEnabled = NO;
        
        NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/getComments.php?dichoID=%@&displayedNumber=%d&userID=%@", selectedDichoID, [commentsIDsArray count], userID];
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 15.0];
        commentsInfosConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

#pragma mark - Connection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if(connection==commentsInfosConnection){
        commentsInfosData = [[NSMutableData alloc] init];
    }else if(connection==postCommentConnection){
        postCommentData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(connection==commentsInfosConnection){
        [commentsInfosData appendData:data];
    }else if(connection==postCommentConnection){
        [postCommentData appendData:data];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(connection==commentsInfosConnection){
        [self parseCommentsInfosData];
    }else if(connection==likingConnection){
        [self parseLikingData];
    }else if(connection==unlikingConnection){
        [self parseUnlikingData];
    }else if(connection==deleteConnection){
        [self handleGoodDelete];
    }else if(connection==postCommentConnection){
        [self parsePostCommentData];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if(connection==commentsInfosConnection){
        [self handleCommentsInfosFail];
    }else if(connection==likingConnection){
        [self handleLikingFail];
    }else if(connection==unlikingConnection){
        [self handleLikingFail];
    }else if(connection==deleteConnection){
        [self handleDeleteFail];
    }else if(connection==postCommentConnection){
        [self handlePostCommentFail];
    }
}

-(void)parseCommentsInfosData{
    NSString *returnedString = [[NSString alloc] initWithData:commentsInfosData encoding: NSUTF8StringEncoding];
    returnedString = [returnedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([returnedString isEqualToString:@""]){
        commentsTable.userInteractionEnabled = YES;
        loadedAll = YES;
        [commentsTable reloadData];
    }else{
        int addedRows = 0;
        
        NSArray *infoArray = [returnedString componentsSeparatedByString:@"|"];
        for(int i=0; i<infoArray.count-1; i=i+7){
            addedRows++;
            [commentsIDsArray insertObject:[infoArray objectAtIndex:i] atIndex:0];
            [userIDsArray insertObject:[infoArray objectAtIndex:i+1] atIndex:0];
            [usernamesArray insertObject:[infoArray objectAtIndex:i+2] atIndex:0];
            [commentsArray insertObject:[infoArray objectAtIndex:i+3] atIndex:0];
            [numberOfLikesArray insertObject:[infoArray objectAtIndex:i+4] atIndex:0];
           
            ////use date/time to get timeSince
            NSString *dichoDateString = [infoArray objectAtIndex:i+5];
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
                [timesSinceArray insertObject: [NSString stringWithFormat:@"%ds", seconds] atIndex:0];
            }
            //entered minutes range
            else if (secondsBetween < 3600)
            {
                int diff = round(secondsBetween / 60);
                [timesSinceArray insertObject:[NSString stringWithFormat:@"%dm", diff] atIndex:0];
            }
            //entering hours range
            else if (secondsBetween < 86400)
            {
                int diff = round(secondsBetween / 60 / 60);
                [timesSinceArray insertObject:[NSString stringWithFormat:@"%dh", diff] atIndex:0];
            }
            //otherwise we have entered days
            else if (secondsBetween < 604800)
            {
                int diff = round(secondsBetween / 60 / 60 / 24);
                [timesSinceArray insertObject:[NSString stringWithFormat:@"%dd", diff] atIndex:0];
            }
            else //if(ti<31556916)
            {
                int diff = round(secondsBetween / 60 / 60 / 24 / 7);
                [timesSinceArray insertObject:[NSString stringWithFormat:@"%dw", diff] atIndex:0];
            }
        
            //add liked and picture
            [likedArray insertObject:[infoArray objectAtIndex:i+6] atIndex:0];
            [userImagesArray insertObject:[UIImage imageNamed:@"dichoTabBarIcon.png"] atIndex:0];
        }
        [commentsTable reloadData];
        
        //////scroll to bottom of table!
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[commentsIDsArray count] inSection:0];
        [commentsTable scrollToRowAtIndexPath:indexPath
                             atScrollPosition:UITableViewScrollPositionBottom
                                     animated:NO];
        commentsTable.userInteractionEnabled = YES;
        for(int i=addedRows; i>0; i--){
            
            NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                    selector:@selector(loadUserImage:)
                                                                                      object:[NSNumber numberWithInt:i]];
            [imageQueue addOperation:operation];
            
        }
    }
}

-(void)loadUserImage:(NSNumber*)aRowNumber{
    int rowNumber = [aRowNumber intValue];
    NSURL * imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://dichoapp.com/userImages/%@.jpeg", [userIDsArray objectAtIndex:rowNumber-1]]];
    NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
    if(imageData != nil){
        UIImage * image = [UIImage imageWithData:imageData];
        
        //resize image to let tableview scroll more smoothly
        CGFloat widthFactor = image.size.width/42;
        CGFloat heightFactor = image.size.height/42;
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
        [userImagesArray replaceObjectAtIndex:rowNumber-1 withObject:newImage];
        
        NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:rowNumber inSection:0];
        NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
        
        [commentsTable performSelectorOnMainThread:@selector(reloadRowsAtIndexPaths:withRowAnimation:) withObject:rowsToReload waitUntilDone:NO];
    }
}

-(void)handleCommentsInfosFail{
    commentsTable.userInteractionEnabled = YES;
    UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [fail show];
}

-(IBAction)like:(id)sender{
    NSIndexPath *indexPath = [commentsTable indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    likingRow = indexPath.row;
    if([[likedArray objectAtIndex:indexPath.row-1] isEqualToString:@"0"]){
        //add like for this comment
        progressAlert = [[UIAlertView alloc] initWithTitle:@"Liking..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [progressAlert show];
        NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/likeComment.php?commentID=%@&userID=%@", [commentsIDsArray objectAtIndex:indexPath.row-1], userID];
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 10.0];
        likingConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
    }else if([[likedArray objectAtIndex:indexPath.row-1] isEqualToString:@"1"]){
        //remove like for this comment
        progressAlert = [[UIAlertView alloc] initWithTitle:@"Unliking..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [progressAlert show];
        NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/unlikeComment.php?commentID=%@&userID=%@", [commentsIDsArray objectAtIndex:indexPath.row-1], userID];
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 10.0];
        unlikingConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

-(void)parseLikingData{
    [likedArray replaceObjectAtIndex:likingRow-1 withObject:@"1"];
    
    int likeCount = [[numberOfLikesArray objectAtIndex:likingRow-1] intValue];
    likeCount = likeCount + 1;
    [numberOfLikesArray replaceObjectAtIndex:likingRow-1 withObject:[NSString stringWithFormat:@"%d", likeCount]];

    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:likingRow inSection:0];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [commentsTable reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];

}

-(void)parseUnlikingData{
    [likedArray replaceObjectAtIndex:likingRow-1 withObject:@"0"];
    
    int likeCount = [[numberOfLikesArray objectAtIndex:likingRow-1] intValue];
    likeCount = likeCount - 1;
    [numberOfLikesArray replaceObjectAtIndex:likingRow-1 withObject:[NSString stringWithFormat:@"%d", likeCount]];
    
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:likingRow inSection:0];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [commentsTable reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)handleLikingFail{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [fail show];
}

-(void)handleGoodDelete{
    //remove from all mutablearrays
    [commentsIDsArray removeObjectAtIndex:deletingRow-1];
    [userIDsArray removeObjectAtIndex:deletingRow-1];
    [usernamesArray removeObjectAtIndex:deletingRow-1];
    [timesSinceArray removeObjectAtIndex:deletingRow-1];
    [commentsArray removeObjectAtIndex:deletingRow-1];
    [likedArray removeObjectAtIndex:deletingRow-1];
    [numberOfLikesArray removeObjectAtIndex:deletingRow-1];
    [userImagesArray removeObjectAtIndex:deletingRow-1];
    
    [commentsTable reloadData];
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)handleDeleteFail{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *deletingFail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection and try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [deletingFail show];
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    //change frame locations
    if(commentTextView.contentSize.height<102){
        commentTextView.frame = CGRectMake(7, self.view.bounds.size.height-216-7-commentTextView.contentSize.height, 253, commentTextView.contentSize.height);//-176
        commentsTable.frame = CGRectMake(0, 64, 320, self.view.bounds.size.height-216-64-14-commentTextView.contentSize.height);
    }else{
        commentTextView.frame = CGRectMake(7, self.view.bounds.size.height-216-7-101, 253, 101);
        commentsTable.frame = CGRectMake(0, 64, 320, self.view.bounds.size.height-216-64-14-101);
    }
    
    [postButton setFrame:CGRectMake(267, self.view.bounds.size.height-216-40, 46, 33)];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[commentsIDsArray count] inSection:0];
    [commentsTable scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:NO];

    if(commentTextView.textColor == [UIColor lightGrayColor]){
        commentTextView.text = @"";
    }
    commentTextView.textColor = [UIColor blackColor];
    return YES;
}

- (BOOL) textViewShouldEndEditing:(UITextView *)textView{
    //need to set frames at bottom but including comments    
    if(commentTextView.contentSize.height<102){
        commentTextView.frame = CGRectMake(7, self.view.bounds.size.height-50-7-commentTextView.contentSize.height, 253, self.commentTextView.contentSize.height);
        commentsTable.frame = CGRectMake(0, 64, 320, self.view.bounds.size.height-64-50-14-commentTextView.contentSize.height);
    }else{
        commentTextView.frame = CGRectMake(7, self.view.bounds.size.height-50-7-101, 253, 101);
        commentsTable.frame = CGRectMake(0, 64, 320, self.view.bounds.size.height-64-50-14-101);
    }
    
    
    [postButton setFrame:CGRectMake(267, self.view.bounds.size.height-90, 46, 33)];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[commentsIDsArray count] inSection:0];
    [commentsTable scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionBottom
                                 animated:NO];
    return YES;
}

-(void)textViewDidChange:(UITextView *)commentTextView{

    if(self.commentTextView.text.length == 0){
        self.commentTextView.textColor = [UIColor lightGrayColor];
        self.commentTextView.text = @"Add a comment...";
        [self.commentTextView resignFirstResponder];
        postButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.45 blue:0.9 alpha:0.5];
        postButton.enabled = NO;
        self.commentTextView.frame = CGRectMake(7, self.view.bounds.size.height-50-7-self.commentTextView.contentSize.height, 253, self.commentTextView.contentSize.height);
        commentsTable.frame = CGRectMake(0, 64, 320, self.view.bounds.size.height-64-50-14-self.commentTextView.contentSize.height);
    }else{
        if(self.commentTextView.text.length>0&&self.commentTextView.text.length<141){
            if ([self.commentTextView.text rangeOfString:@"|"].location==NSNotFound) {
                postButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.45 blue:0.9 alpha:0.9];
                postButton.enabled = YES;
            }else{
                postButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.45 blue:0.9 alpha:0.5];
                postButton.enabled = NO;
            }
        }else{
            postButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.45 blue:0.9 alpha:0.5];
            postButton.enabled = NO;
        }
    
    
        if(self.commentTextView.contentSize.height<102){
            self.commentTextView.frame = CGRectMake(7, self.view.bounds.size.height-216-7-self.commentTextView.contentSize.height, 253, self.commentTextView.contentSize.height);
            commentsTable.frame = CGRectMake(0, 64, 320, self.view.bounds.size.height-216-64-14-self.commentTextView.contentSize.height);
        }else{
            self.commentTextView.frame = CGRectMake(7, self.view.bounds.size.height-216-7-101, 253, 101);
            commentsTable.frame = CGRectMake(0, 64, 320, self.view.bounds.size.height-216-64-14-101);
        }
    }
}

-(void)dismissKeyboard {
    [commentTextView resignFirstResponder];
}

-(IBAction)postComment:(id)sender{
    progressAlert= [[UIAlertView alloc] initWithTitle:@"Posting..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [progressAlert show];
    [commentTextView resignFirstResponder];
    
    //set posted comment and replace new lines with spaces
    postedComment = commentTextView.text;
    postedComment = [postedComment stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    //encode the comment
    NSString *encodedComment = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                      NULL,
                                                                                                      (__bridge CFStringRef) postedComment,
                                                                                                      NULL,
                                                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                      kCFStringEncodingUTF8));
    //post comment php
    NSString *strURL = [NSString stringWithFormat:@"http://dichoapp.com/files/postComment.php?dichoID=%@&userID=%@&comment=%@", selectedDichoID, userID, encodedComment];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 20.0];
    postCommentConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(void)parsePostCommentData{
    //get back comment id
    NSString *returnedCommentID = [[NSString alloc] initWithData:postCommentData encoding: NSUTF8StringEncoding];
    returnedCommentID = [returnedCommentID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //add all info to arrays
    [commentsIDsArray addObject:returnedCommentID];
    [userIDsArray addObject:userID];
    [usernamesArray addObject:[prefs objectForKey:@"username"]];
    [timesSinceArray addObject:@"1s"];
    [commentsArray addObject:postedComment];
    [likedArray addObject:@"0"];
    [numberOfLikesArray addObject:@"0"];
    [userImagesArray addObject:[UIImage imageNamed:@"dichoTabBarIcon.png"]];

    //reload table
    [commentsTable reloadData];
    
    //scroll to bottom
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[commentsIDsArray count] inSection:0];
    [commentsTable scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionBottom
                                 animated:NO];
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];

    //add get image operation
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(loadUserImage:)
                                                                              object:[NSNumber numberWithInt:[commentsIDsArray count]]];
    [imageQueue addOperation:operation];

}

-(void)handlePostCommentFail{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *deletingFail = [[UIAlertView alloc] initWithTitle:@"Connection error." message:@"Please make sure you have a stable internet connection and try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [deletingFail show];
}

-(IBAction)goToLikes:(id)sender{
    NSIndexPath *indexPath = [commentsTable indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    
    DICHOShowLikesViewController *nextVC = [[DICHOShowLikesViewController alloc] initWithCommentID:[commentsIDsArray objectAtIndex:indexPath.row-1]];
    [self.navigationController pushViewController:nextVC animated:YES];

}

-(IBAction)goToUser:(id)sender{
    NSIndexPath *indexPath = [commentsTable indexPathForCell:(UITableViewCell*)[[[sender superview] superview]superview]];
    
    DICHOSingleUserViewController *nextVC = [[DICHOSingleUserViewController alloc] initWithUsername: [usernamesArray objectAtIndex:indexPath.row-1] askerID:[userIDsArray objectAtIndex:indexPath.row-1]];
    [self.navigationController pushViewController:nextVC animated:YES];
    
}

@end
