//
//  SettingsViewController.m
//  iPhoneXMPP
//
//  Created by Eric Chamberlain on 3/18/11.
//  Copyright 2011 RF.com. All rights reserved.
//

#import "SettingsViewController.h"
#import "iPhoneXMPPAppDelegate.h"

NSString *const kXMPPmyJID = @"kXMPPmyJID";
NSString *const kXMPPmyPassword = @"kXMPPmyPassword";


@implementation SettingsViewController


#pragma mark Init/dealloc methods

#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
  
    self.jidField.text=[[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyJID];
    self.passwordField.text=[[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyPassword];
}

#pragma mark ------------------ Accessors

- (iPhoneXMPPAppDelegate *)appDelegate
{
    return (iPhoneXMPPAppDelegate *)[[UIApplication sharedApplication] delegate];
}


#pragma mark Private


- (void)setField:(UITextField *)field forKey:(NSString *)key
{
  if (field.text != nil) 
  {
    [[NSUserDefaults standardUserDefaults] setObject:field.text forKey:key];
  } else {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
  }
}


#pragma mark Actions


- (IBAction)done:(id)sender
{
    [[self appDelegate] disconnect];
    [self setField:self.jidField forKey:kXMPPmyJID];
    [self setField:self.passwordField forKey:kXMPPmyPassword];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)hideKeyboard:(id)sender {
  [sender resignFirstResponder];
  [self done:sender];
}

- (IBAction)switchValueChanged:(id)sender {
   
    /*UISwitch *switchh = (UISwitch *)sender;
    if (switchh.selected == NO) {
        [[self appDelegate] ];
    }*/
    
}


#pragma mark Getter/setter methods



@end
