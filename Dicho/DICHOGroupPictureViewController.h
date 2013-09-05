//
//  DICHOGroupPictureViewController.h
//  Dicho
//
//  Created by Tyler Droll on 8/4/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOGroupPictureViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSUserDefaults *prefs;

    NSString *groupID;
    UIImage *groupImage;

    NSURLConnection *imageConnection;
    NSMutableData *receivedImageData;
}

-(id)initWithGroupID:(NSString*)givenGroupID;

@property (strong, nonatomic) IBOutlet UIImageView *groupImageView;

@property (nonatomic) IBOutlet UIAlertView *progressAlert;

-(void)parseImageData;
-(void)handleiImageFail;
@end
