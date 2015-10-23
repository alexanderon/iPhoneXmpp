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
#import "HPGrowingTextView.h"
#import "MessageCell.h"



@interface ChatViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,HPGrowingTextViewDelegate>
{
    NSFetchedResultsController *fetchedResultsController;
    NSMutableArray *turnSockets;
    NSMutableArray *sentMessages;
    
    NSMutableArray* _messagelist;
    
    HPGrowingTextView *chatInput;
}

@property (weak, nonatomic) IBOutlet UITextField *chatWindow;



@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak ,nonatomic) NSString *chatWithUser;
@property (strong, nonatomic) IBOutlet UIView *contentView;
- (id) initWithUser:(NSString *) userName ;
- (IBAction)btnChooseImageClick:(id)sender;

@end
