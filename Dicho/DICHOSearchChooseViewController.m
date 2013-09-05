//
//  DICHOSearchChooseViewController.m
//  Dicho
//
//  Created by Tyler Droll on 11/20/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import "DICHOSearchChooseViewController.h"

@interface DICHOSearchChooseViewController ()

@end

@implementation DICHOSearchChooseViewController

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
        [self.tabBarController setSelectedIndex:4];
    }else if([firstTimeStatus isEqualToString:@"yes"]){
        [prefs setObject:@"no" forKey:@"firstTimeToSearch"];
    }

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    prefs= [NSUserDefaults standardUserDefaults];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:1.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
        return 2;
    else
        return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if(indexPath.section==0 && indexPath.row==0)
        cell.textLabel.text = @"Dichos of the Day";
    else if(indexPath.section==0 && indexPath.row==1)
        cell.textLabel.text = @"Interesting People to Answer";
    else if(indexPath.section == 1 && indexPath.row == 0)
        cell.textLabel.text = @"Search by Username";
    else if(indexPath.section==1 && indexPath.row == 1)
        cell.textLabel.text = @"Search by Full Name";
    else
        cell.textLabel.text = @"Find Groups to Join";
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if(indexPath.section==0 && indexPath.row==0)
        [self performSegueWithIdentifier:@"popularDichos" sender:self];
    else if(indexPath.section==0 && indexPath.row==1)
        [self performSegueWithIdentifier:@"interestingPeople" sender:self];
    else if(indexPath.section == 1 && indexPath.row == 0)
        [self performSegueWithIdentifier:@"searchByUsername" sender:self];
    else if(indexPath.section==1 && indexPath.row == 1)
        [self performSegueWithIdentifier:@"searchByFullName" sender:self];
    else
        [self performSegueWithIdentifier:@"findGroups" sender:self];
    
}

@end
