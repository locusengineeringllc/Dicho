//
//  DICHOSubmitViewController.h
//  Dicho
//
//  Created by Tyler Droll on 9/22/12.
//  Copyright (c) 2012 Locus Engineering LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICHOSubmitViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    UIImageView *clearImageView;
    NSUserDefaults *prefs;
    
    NSURLConnection *submitConnection;
    NSMutableData *submitData;
}

@property (weak, nonatomic) IBOutlet UITextView *typeQuestion;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
- (IBAction)submitButton:(id)sender;
- (IBAction)clearButton:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *characterLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *anonymousBar;

@property int isAnonymous;
@property (weak, nonatomic) IBOutlet UITextField *firstAnswerTextField;
@property (weak, nonatomic) IBOutlet UITextField *secondAnswerTextField;
-(IBAction)textField1Changed:(id)sender;
-(IBAction)textField2Changed:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *textField2Label;

@property (weak, nonatomic) IBOutlet UILabel *textField1Label;
- (IBAction)addPicture:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImage;
@property int hasPicture;
@property (weak, nonatomic) IBOutlet UIButton *removePictureButton;
- (IBAction)removePicture:(id)sender;
@property (nonatomic) IBOutlet UIAlertView *submitAlert;

-(void)parseSubmitData;
-(void)handleSubmitFail;


@end
