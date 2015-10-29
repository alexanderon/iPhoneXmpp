//
//  SendRequestViewController.m
//  iPhoneXMPP
//
//  Created by RAHUL on 10/20/15.
//  Copyright © 2015 XMPPFramework. All rights reserved.
//

#import "SendRequestViewController.h"
#import "iPhoneXMPPAppDelegate.h"

@interface SendRequestViewController ()

@end

@implementation SendRequestViewController


#pragma mark - view Loading
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)btnRequestClick:(id)sender {
    
    nameOfRequestedUser =self.txtNameofUser.text;
    JIDofRequestedUser=self.txtJIDofUser.text;
    
    [[self appDelegate].xmppRoster addUser:[XMPPJID jidWithString:JIDofRequestedUser] withNickname:nameOfRequestedUser];

}

#pragma mark Accessors
- (iPhoneXMPPAppDelegate *)appDelegate{
    return (iPhoneXMPPAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (XMPPStream *)xmppStream {
    return [[self appDelegate] xmppStream];
}

@end
