//
//  RequestViewController.h
//  iPhoneXMPP
//
//  Created by RAHUL on 10/19/15.
//  Copyright © 2015 XMPPFramework. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPP.h"
#import "iPhoneXMPPAppDelegate.h"
#import "RequestTableViewCell.h"
#import "XMPPRoster.h"


@interface RequestViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,XMPPRosterDelegate>
{
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;

}

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
