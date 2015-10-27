//
//  ChatViewController.h
//  iPhoneXMPP
//
//  Created by RAHUL on 10/17/15.
//  Copyright © 2015 XMPPFramework. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "XMPP.h"
#import "TURNSocket.h"
#import "RootViewController.h"
#import "MessageCell.h"
#import "XMPPOutgoingFileTransfer.h"
#import "XMPPIncomingFileTransfer.h"
#import "iPhoneXMPPAppDelegate.h"
#import "NSString+Utils.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "XMPPMessageArchiving.h"
#import "ImageViewCell.h"



@interface ChatViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,XMPPOutgoingFileTransferDelegate,XMPPIncomingFileTransferDelegate>
{
    NSFetchedResultsController *fetchedResultsController;
    NSMutableArray *turnSockets;
    NSMutableArray *sentMessages;
    NSMutableArray* _messagelist;
    
}

@property (weak, nonatomic) IBOutlet UITextField *chatWindow;
@property (strong,nonatomic) NSString * resource;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak,nonatomic) XMPPUserCoreDataStorageObject *user;

- (id) initWithUser:(NSString *) userName ;
- (IBAction)btnChooseImageClick:(id)sender;

@end
