//
//  DICHOPictureViewController.h
//  Dicho
//
//  Created by Tyler Droll on 8/31/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOPictureViewController : UIViewController
{
    NSString *selectedDichoID;
    
    NSURLConnection *imageConnection;
    NSMutableData *imageData;
}


-(id)initWithDichoID:(NSString*)aDichoID;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

@property (strong, nonatomic) IBOutlet UIButton *dismissButton;
-(IBAction)dismissView:(id)sender;


@end
