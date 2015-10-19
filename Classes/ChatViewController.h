//
//  ChatViewController.h
//  iPhoneXMPP
//
//  Created by RAHUL on 10/17/15.
//  Copyright © 2015 XMPPFramework. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPP.h"
#import "TURNSocket.h"
#import "RootViewController.h"

@interface ChatViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController *fetchedResultsController;
    NSMutableArray *turnSockets;
    NSMutableArray *sentMessages;
}

@property (weak, nonatomic) IBOutlet UITextField *chatWindow;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak ,nonatomic) NSString *chatWithUser;
- (id) initWithUser:(NSString *) userName ;

@end
