//
//  SendRequestViewController.h
//  iPhoneXMPP
//
//  Created by RAHUL on 10/20/15.
//  Copyright © 2015 XMPPFramework. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPP.h"

@interface SendRequestViewController : UIViewController
{
    NSString *nameOfRequestedUser;
    NSString *JIDofRequestedUser;
}

@property (weak, nonatomic) IBOutlet UITextField *txtJIDofUser;
@property (weak, nonatomic) IBOutlet UITextField *txtNameofUser;

- (IBAction)btnRequestClick:(id)sender;

@end
