//
//  ChatViewController.m
//  iPhoneXMPP
//
//  Created by RAHUL on 10/17/15.
//  Copyright © 2015 XMPPFramework. All rights reserved.
//

#import "ChatViewController.h"
#import "iPhoneXMPPAppDelegate.h"
#import "NSString+Utils.h"

@interface ChatViewController ()

@end

@implementation ChatViewController

#pragma mark Accessors
- (iPhoneXMPPAppDelegate *)appDelegate{
    return (iPhoneXMPPAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (XMPPStream *)xmppStream {
    return [[self appDelegate] xmppStream];
}

- (id) initWithUser:(NSString *) userName {
    
    if (self = [super init]) {
        
        self.chatWithUser = userName;
    }
    
    return self;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self.tableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [[self xmppStream]addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.chatWindow becomeFirstResponder];
    
    turnSockets = [[NSMutableArray alloc] init];
    sentMessages= [[NSMutableArray alloc] init];
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationItem setTitle:self.chatWithUser];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Table view delegates


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"MessageCellIdentifier";
    UITableViewCell *cell  =[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.text=[[sentMessages objectAtIndex:indexPath.row] valueForKey:@"msg"];
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return  [sentMessages count];
    //  return 0;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}


#pragma mark -
#pragma mark Actions


- (IBAction)sendMessage {
    
    NSString *messageStr = self.chatWindow.text;
    
    if([messageStr length] > 0) {
        
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageStr];
        
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:self.chatWithUser];
        [message addChild:body];
        [[self  xmppStream] sendElement:message];
        self.chatWindow.text = @"";
        
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        [m setObject:[messageStr substituteEmoticons] forKey:@"msg"];
        [m setObject:@"you" forKey:@"sender"];
        [m setObject:[NSString getCurrentTime] forKey:@"time"];
        
        [sentMessages addObject:m];
        [self reloadTable];
        
    }
    
}

-(void)addMessageToTableView:(NSDictionary *) messageDict{
    
}

#pragma mark - handling messges notfications

-(void) reloadTable
{
    [self.tableview reloadData];
}


#pragma mark - XmppStream Delegate

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    
    // A simple example of inbound message handling.
    
    if ([message isChatMessageWithBody])
    {
        XMPPUserCoreDataStorageObject *user = [[self appDelegate].xmppRosterStorage userForJID:[message from]
                                                                                    xmppStream:[self xmppStream]
                                                                          managedObjectContext:[[self appDelegate] managedObjectContext_roster]];
        //  NSLog(@"%@",user.subscription);
        
        NSString *body = [[message elementForName:@"body"] stringValue];
        NSString *displayName = [user displayName];
        
        /*   NSDictionary* userInfo = @{@"af": self.jid,
         @"message": message ,
         @"thetime": [self currentGMTTime],
         @"delivered":@YES,
         kMessageId: messageId
         };*/
        
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        [m setObject:[body substituteEmoticons] forKey:@"msg"];
        [m setObject:displayName forKey:@"sender"];
        [m setObject:[NSString getCurrentTime] forKey:@"time"];
        [sentMessages addObject:m];
        
        [self.tableview beginUpdates];
        
        NSIndexPath *path1 = [NSIndexPath indexPathForRow:[sentMessages count]-1  inSection:0];
        
        [self.tableview insertRowsAtIndexPaths:@[path1]
                              withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableview endUpdates];
        
        if(![self.tableview.indexPathsForVisibleRows containsObject:path1])
        {
            [self.tableview scrollToRowAtIndexPath:path1 atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
        /*  if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
         {
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
         message:body
         delegate:nil
         cancelButtonTitle:@"Ok"
         otherButtonTitles:nil];
         [alertView show];
         }
         else
         {
         // We are not active, so use a local notification instead
         UILocalNotification *localNotification = [[UILocalNotification alloc] init];
         localNotification.alertAction = @"Ok";
         localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
         
         [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
         }*/
    }
}




@end
