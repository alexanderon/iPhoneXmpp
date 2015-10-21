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


@interface RequestViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,XMPPRosterDelegate,XMPPStreamDelegate,NSFetchedResultsControllerDelegate>
//
//{
//    XMPPRoster *xmppRoster;
//    XMPPRosterCoreDataStorage *xmppRosterStorage;
//    
//}
{
    NSFetchedResultsController *fetchedResultsController;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)btnAcceptClick:(id)sender;
- (IBAction)btnRejectClick:(id)sender;


@end
