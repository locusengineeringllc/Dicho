//
//  DICHOResultsViewController.m
//  Dicho
//
//  Created by Tyler Droll on 11/25/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import "DICHOResultsViewController.h"

@interface DICHOResultsViewController ()

@end

@implementation DICHOResultsViewController
@synthesize resultsTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
        return 1;
    if(section == 1)
        return 2;
    if(section == 2)
        return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0&&indexPath.row==0)
        return 80;
    else
        return 35;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"questionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *questionLabel = (UILabel *) [cell viewWithTag:1];
    
    
    static NSString *Cell2Identifier = @"Cell2";
    UITableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:Cell2Identifier];
    UILabel *answerLabel = (UILabel *) [cell2 viewWithTag:1];
    UILabel *numberLabel = (UILabel *) [cell2 viewWithTag:2];
    
    
    
    if(indexPath.section==0&&indexPath.row== 0){
        [questionLabel setText:@"There will be some really long question here. What do you think it would say? Do you think the Packers will win?"];
        return cell;
    }else if(indexPath.section==1&&indexPath.row== 0){
        [answerLabel setText:@"Asker"];
        [numberLabel setText:@"PolitcalDicho"];
        return cell2;
    }else if(indexPath.section==1&&indexPath.row== 1){
        [answerLabel setText:@"11/25/2012"];
        [numberLabel setText:@"11:42 P.M."];
        return cell2;
    }
    else if(indexPath.section==2&&indexPath.row== 0){
        [answerLabel setText:@"The Packers"];
        [numberLabel setText:@"47%"];
        return cell2;
    }else if(indexPath.section==2&&indexPath.row==1){
        [answerLabel setText:@"The Giants"];
        [numberLabel setText:@"53%"];
        return cell2;
    }else{
        [answerLabel setText:@"Total Votes"];
        [numberLabel setText:@"72"];
        return cell2;
    }
    
}


@end
