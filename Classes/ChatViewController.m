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
#import "XMPPMessageArchivingCoreDataStorage.h"

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

- (IBAction)btnChooseImageClick:(id)sender {
}

#pragma mark -View Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self.tableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [[self xmppStream]addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.chatWindow becomeFirstResponder];
    
    turnSockets = [[NSMutableArray alloc] init];
    sentMessages= [[NSMutableArray alloc] init];
    
    
    /* chatInput = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, self.view.frame.size.width-80, 40)];
     chatInput.backgroundColor =[UIColor yellowColor];
     chatInput.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
     
     chatInput.minNumberOfLines = 1;
     chatInput.maxNumberOfLines = 8;
     
     chatInput.font = [UIFont systemFontOfSize:15.0f];
     chatInput.delegate = self;
     chatInput.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
     chatInput.backgroundColor = [UIColor whiteColor];
     
     chatInput.autoresizingMask = UIViewAutoresizingFlexibleWidth;
     [self.contentView setFrame:self.chatWindow.frame];
     //  [self.contentView addSubview:chatInput];
     [self.chatWindow addSubview:chatInput];*/
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationItem setTitle:self.chatWithUser];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
     [self loadarchivemsg];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Table view delegates


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    /* static NSString *CellIdentifier = @"MessageCellIdentifier";
     UITableViewCell *cell  =[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
     cell.textLabel.text=[[sentMessages objectAtIndex:indexPath.row] valueForKey:@"msg"];
     return cell;*/
    
    static NSString *CellIdentifier = @"MessageCell";
    
    NSDictionary *s = (NSDictionary *) [sentMessages objectAtIndex:indexPath.row];
    
    
    MessageCell *cell = (MessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        //   cell = [[MessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier ];
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MessageCell" owner:self options:nil];
        
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    NSString *sender = [s objectForKey:@"sender"];
    NSString *message = [s objectForKey:@"msg"];
    NSString *time = [s objectForKey:@"time"];
    
    cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@ %@", sender, time];
    if ([sender isEqualToString:@"you"])
    { // left aligned
        cell.ViewRight.hidden = YES;
        cell.ViewLeft.hidden = NO;
        cell.lblMessageLeft.text = message;
        [cell.lblMessageLeft sizeToFit];
        UIImage *bubble = [[UIImage imageNamed:@"orange.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
        cell.ivLeft.image = bubble;
    }
    else
    {
        cell.ViewRight.hidden = NO;
        cell.ViewLeft.hidden = YES;
        cell.lblMessageRight.text = message;
        [cell.lblMessageRight sizeToFit];
        UIImage *bubble = [[UIImage imageNamed:@"aqua.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
        cell.ivRight.image = bubble;
    }
    return cell;
    
    
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    
    return  [sentMessages count];
    
 //   NSLog(@"%lu",[[self fetchedResultsController].fetchedObjects count]);
    
    
    
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
        NSLog(@"%@",sentMessages);
        [self reloadTable];
        
    }
    
}

- (void)addMessageToTableView:(NSDictionary *) messageDict{
    
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


#pragma  mark- Load Previous Messages

-(void)loadarchivemsg
{
    
    XMPPMessageArchivingCoreDataStorage *_xmppMsgStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    NSManagedObjectContext *moc = [_xmppMsgStorage mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
                                                         inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDescription];
    //[request setFetchLimit:20];
    
    NSError *error;
    NSString *predicateFrmt = @"bareJidStr == %@";
    NSPredicate *predicate =[NSPredicate predicateWithFormat:predicateFrmt,_chatWithUser];
    request.predicate = predicate;
    NSArray *messages = [moc executeFetchRequest:request error:&error];
    NSLog(@"%@",messages);
    
    for (XMPPMessageArchiving_Message_CoreDataObject *message in messages) {
        
        NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message.messageStr error:nil];
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        [m setObject:message.body forKey:@"msg"];
        
        if ([[element attributeStringValueForName:@"to"] isEqualToString:_chatWithUser])
        {
            
            [m setObject:@"you" forKey:@"sender"];
        }
        else
        {
            [m setObject:_chatWithUser forKey:@"sender"];
        }
        NSDate *date = message.timestamp;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [m setObject:[dateFormatter stringFromDate:date] forKey:@"time"];
        
        
        [sentMessages addObject:m];
        [self.tableview reloadData];
        
        /*  NSLog(@"bareJid param is %@",message.bareJid);
         NSLog(@"bareJidStr param is %@",message.bareJidStr);
         NSLog(@"body param is %@",message.body);
         NSLog(@"timestamp param is %@",message.timestamp);
         NSLog(@"outgoing param is %d",[message.outgoing intValue]);*/
    }
}




@end
