//
//  DICHOSettingsViewController.m
//  Dicho
//
//  Created by Tyler Droll on 10/31/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import "DICHOSettingsViewController.h"
#import "DICHOAsyncImageViewRound.h"
#import <QuartzCore/QuartzCore.h>


@interface DICHOSettingsViewController ()

@end

@implementation DICHOSettingsViewController
@synthesize settingsTable;
@synthesize alert;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [settingsTable reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    prefs= [NSUserDefaults standardUserDefaults];

    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0];
	// Do any additional setup after loading the view.
    settingsTable.contentInset = UIEdgeInsetsMake(-13.0, 0, 0, 0);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
        return 5;
    if(section == 1)
        return 2;
    else
        return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0&&indexPath.row==2)
        return 44;
    else return 40;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *textCellIdentifier = @"textCell";
    UITableViewCell *textCell = [tableView dequeueReusableCellWithIdentifier:textCellIdentifier];
    UILabel *nameTypeLabel = (UILabel *) [textCell viewWithTag:1];
    UILabel *actualNameLabel = (UILabel *) [textCell viewWithTag:2];

    static NSString *passwordCellIdentifier = @"passwordCell";
    UITableViewCell *passwordCell = [tableView dequeueReusableCellWithIdentifier:passwordCellIdentifier];
    UILabel *passwordLabel = (UILabel *) [passwordCell viewWithTag:1];

    static NSString *pictureCellIdentifier = @"pictureCell";
    UITableViewCell *pictureCell = [tableView dequeueReusableCellWithIdentifier:pictureCellIdentifier];
    UIImageView *pictureView = (UIImageView *) [pictureCell viewWithTag:1];
    
    static NSString *Cell2Identifier = @"Cell2";
    UITableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:Cell2Identifier];
    UILabel *cell2Label = (UILabel *) [cell2 viewWithTag:1];
    
    
    if(indexPath.section==0&&indexPath.row== 0){
        [nameTypeLabel setText:@"Name"];
        [actualNameLabel setText:[NSString stringWithFormat:@"%@", [prefs objectForKey:@"name"]]];
        return textCell;
    }else if(indexPath.section==0&&indexPath.row== 1){
         [nameTypeLabel setText:@"Username"];
         [actualNameLabel setText:[NSString stringWithFormat:@"%@", [prefs objectForKey:@"username"]]];
         return textCell;
    }else if(indexPath.section==0&&indexPath.row== 2){
        
        if (pictureCell == nil) {
            pictureCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:pictureCellIdentifier];
        }else{
            
            DICHOAsyncImageViewRound* oldImage = (DICHOAsyncImageViewRound*)[pictureCell.contentView viewWithTag:5];
            [oldImage removeFromSuperview];
        }
        DICHOAsyncImageViewRound* askerImage = [[DICHOAsyncImageViewRound alloc]
                                                initWithFrame:CGRectMake(240, 2, 40, 40)];
        askerImage.tag = 5;
        //use userID to pull userImage
        NSString *imageUrl;
        imageUrl= [NSString stringWithFormat:@"http://dichoapp.com/userImages/%@.jpeg", [prefs objectForKey:@"userID"]];
        [askerImage loadImageFromURL:[NSURL URLWithString:imageUrl]];
        [pictureCell.contentView addSubview:askerImage];
        
        pictureView.layer.cornerRadius = 5.0;
        return pictureCell;
    }else if(indexPath.section==0&&indexPath.row== 3){
        NSMutableString *dottedPassword = [NSMutableString new];
        for (int i = 0; i < [[prefs objectForKey:@"password"] length]; i++)
        {
            [dottedPassword appendString:@"●"];
        }
        [passwordLabel setText:[NSString stringWithFormat:@"%@", dottedPassword]];
        return passwordCell;
    }else if(indexPath.section==0&&indexPath.row==4){
        [nameTypeLabel setText:@"E-mail"];
        [actualNameLabel setText:[NSString stringWithFormat:@"%@", [prefs objectForKey:@"email"]]];
        return textCell;
    }else if(indexPath.section==1&&indexPath.row== 0){
        [cell2Label setText:@"Log In"];
        return cell2;
    }else if(indexPath.section==1&&indexPath.row==1){
        [cell2Label setText:@"Log Out"];
        return cell2;
    }else if(indexPath.section==2){
        [cell2Label setText:@"Create Account"];
        return cell2;
    }else{
        [cell2Label setText:@"Contact Us"];
        return cell2;
    }
        
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    alert= [[UIAlertView alloc] initWithTitle:@"You Are Not Logged In" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    
    if(indexPath.section==0 && indexPath.row==0){
        if([[prefs objectForKey:@"loggedIn"] isEqualToString:@"yes"])
            [self performSegueWithIdentifier:@"settingsToName" sender:self];
        else [alert show];
    }else if(indexPath.section==0 && indexPath.row==1){
        if([[prefs objectForKey:@"loggedIn"] isEqualToString:@"yes"])
            [self performSegueWithIdentifier:@"settingsToUsername" sender:self];
        else [alert show];
    }else if(indexPath.section==0 && indexPath.row==2){
        if([[prefs objectForKey:@"loggedIn"] isEqualToString:@"yes"])
            [self performSegueWithIdentifier:@"settingsToProfilePicture" sender:self];
        else [alert show];
    }else if(indexPath.section==0 && indexPath.row==3){
        if([[prefs objectForKey:@"loggedIn"] isEqualToString:@"yes"])
            [self performSegueWithIdentifier:@"settingsToPassword" sender:self];
        else [alert show];
    }else if(indexPath.section==0 && indexPath.row==4){
        if([[prefs objectForKey:@"loggedIn"] isEqualToString:@"yes"])
            [self performSegueWithIdentifier:@"settingsToEmailAddress" sender:self];
        else [alert show];
    }else if(indexPath.section==1 && indexPath.row==0){
        if([[prefs objectForKey:@"loggedIn"] isEqualToString:@"no"])
            [self performSegueWithIdentifier:@"settingsToLogIn" sender:self];
        else{
            alert= [[UIAlertView alloc] initWithTitle:@"You Are Already Logged In" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
    }else if(indexPath.section==1 && indexPath.row==1){
        [prefs setObject:@"no" forKey:@"loggedIn"];
        [prefs setObject:@"" forKey:@"userID"];
        [prefs setObject:@"Not Logged In" forKey:@"username"];
        [prefs setObject:@"Not Logged In" forKey:@"name"];
        [prefs setObject:@"Not Logged In" forKey:@"email"];
        [prefs setObject:@"" forKey:@"password"];
        
        
        [settingsTable reloadData];
        alert= [[UIAlertView alloc] initWithTitle:@"You Are Logged Out" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }else if(indexPath.section==2 && indexPath.row==0){
        [self performSegueWithIdentifier:@"settingsToCreateAccount" sender:self];
    }else if(indexPath.section==3){
        [self performSegueWithIdentifier:@"settingsToContactUs" sender:self];

        //alert= [[UIAlertView alloc] initWithTitle:@"Talk to Us" message:@"If you have any issues, comments, suggestions, or questions regarding the app then please email us. We love getting feedback from our users! \n\n support@dichoapp.com" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        //[alert show];
    }
    
    
}



@end
