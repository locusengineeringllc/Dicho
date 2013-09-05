//
//  DICHOSettingsViewController.h
//  Dicho
//
//  Created by Tyler Droll on 10/31/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSUserDefaults *prefs;
}

@property (weak, nonatomic) IBOutlet UITableView *settingsTable;
@property (nonatomic) IBOutlet UIAlertView *alert;
@end
