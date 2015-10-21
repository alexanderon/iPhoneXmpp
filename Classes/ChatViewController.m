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
        [self.tableview reloadData];
       // [m release];
        
    }
    
}

-(void)addMessageToTableView:(NSDictionary *) messageDict{

}

#pragma xmppstream



@end
