//
//  DICHOGroupAskViewController.h
//  Dicho
//
//  Created by Tyler Droll on 8/3/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOGroupAskViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSString *userID;
    NSString *groupID;
    NSUserDefaults *prefs;
        
    NSURLConnection *submitConnection;
    NSMutableData *submitData;
    
}
-(id)initWithGroupID:(NSString*)givenGroupID;

@property (strong, nonatomic) IBOutlet UITextView *typeQuestion;
@property (strong, nonatomic) IBOutlet UILabel *characterLabel;

- (IBAction)ask:(id)sender;

@property (strong, nonatomic) IBOutlet UISegmentedControl *anonymousBar;
@property int isAnonymous;
@property (strong, nonatomic) IBOutlet UITextField *firstAnswerTextField;
@property (strong, nonatomic) IBOutlet UITextField *secondAnswerTextField;
-(IBAction)textField1Changed:(id)sender;
-(IBAction)textField2Changed:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *textField1Label;
@property (strong, nonatomic) IBOutlet UILabel *textField2Label;

- (IBAction)addPicture:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *addPictureButton;
@property (strong, nonatomic) IBOutlet UILabel *photoLabel;
@property (strong, nonatomic) IBOutlet UIImageView *clearImageView;
@property (strong, nonatomic) IBOutlet UIImageView *selectedImage;
@property int hasPicture;
@property (strong, nonatomic) IBOutlet UIButton *removePictureButton;
- (IBAction)removePicture:(id)sender;

@property (nonatomic) IBOutlet UIAlertView *submitAlert;
-(void)parseSubmitData;
-(void)handleSubmitFail;


@end
