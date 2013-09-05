//
//  DICHOProfilePictureViewController.h
//  Dicho
//
//  Created by Tyler Droll on 12/29/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOProfilePictureViewController : UITableViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    NSUserDefaults *prefs;
    NSURLConnection *pictureConnection;
    NSMutableData *pictureData;
    
    
}
@property (weak, nonatomic) IBOutlet UIImageView *currentPicture;
@property (weak, nonatomic) IBOutlet UIImageView *selectedPicture;
@property (nonatomic) IBOutlet UIAlertView *pictureAlert;

-(void)parsePictureData;
-(void)handlePictureFail;

@end
