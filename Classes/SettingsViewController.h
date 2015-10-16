//
//  SettingsViewController.h
//  iPhoneXMPP
//
//  Created by Eric Chamberlain on 3/18/11.
//  Copyright 2011 RF.com. All rights reserved.
//

#import <UIKit/UIKit.h>


extern NSString *const kXMPPmyJID;
extern NSString *const kXMPPmyPassword;


@interface SettingsViewController : UIViewController 

@property (weak, nonatomic) IBOutlet UITextField *jidField;
@property (nonatomic,weak) IBOutlet UITextField *passwordField;

- (IBAction)done:(id)sender;
- (IBAction)hideKeyboard:(id)sender;

@end
