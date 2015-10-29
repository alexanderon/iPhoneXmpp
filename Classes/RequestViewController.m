//
//  RequestViewController.m
//  iPhoneXMPP
//
//  Created by RAHUL on 10/19/15.
//  Copyright © 2015 XMPPFramework. All rights reserved.
//

#import "RequestViewController.h"

@interface RequestViewController ()
{
    NSMutableArray *pendingRequests;
}

@end

@implementation RequestViewController

- (iPhoneXMPPAppDelegate *)appDelegate{
    
    return (iPhoneXMPPAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (XMPPStream *)xmppStream {
    
    return [[self appDelegate] xmppStream];
}



#pragma mark -view load methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    [[self appDelegate].xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [[self appDelegate].xmppStream  addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
   // pendingRequests =[[NSMutableArray alloc]initWithArray:[[self appDelegate].pendingRequests allObjects]];
    pendingRequests=[[NSMutableArray alloc]init];
    [self FetchFriends];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table view delegates


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"RequestCell";
    RequestTableViewCell *cell  =(RequestTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ([pendingRequests count]) {
        cell.lblRequestFromUser.text =[NSString stringWithFormat:@"%@",[pendingRequests objectAtIndex:indexPath.row]];
    }else{
        cell.lblRequestFromUser.text=@"No Pending Requests";
    }
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([pendingRequests count] == 0) {
        return 0;
    }else{
        return [pendingRequests count];
        
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

#pragma mark XMPPRosterDelegate

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    
  /*  NSLog(@"request from:%@",[presence fromStr]);
    
    NSMutableDictionary *dictUser = [[NSMutableDictionary alloc]init];
    [dictUser  setValue:[presence fromStr] forKey:@"fromStr"];
    
    if (!pendingRequests) {
        pendingRequests =[[NSMutableArray alloc]initWithArray:[[self appDelegate].pendingRequests allObjects]];
    }
    [pendingRequests addObject:dictUser];
    [self.tableView reloadData];*/
}

#pragma mark  - XMPPSTREAM Delegate


- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    
    /*if ([presence.type isEqualToString:@"subscribe"]) {
     if (!pendingRequests) {
     pendingRequests =[[NSMutableSet alloc]init];
     }
     [pendingRequests addObject:presence.from];
     }*/
    
    
}


- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    
    NSXMLElement *queryElement = [iq elementForName: @"query" xmlns: @"jabber:iq:roster"];
    if (queryElement)
    {
        NSArray *itemElements = [queryElement elementsForName: @"item"];
        for (int i=0; i<[itemElements count]; i++)
        {
            NSLog(@"Friend: %@",[[itemElements[i] attributeForName:@"jid"]stringValue]);
            if ([[[itemElements[i] attributeForName:@"subscription"]stringValue] isEqualToString:@"from"]) {
                NSLog(@"Request From: %@",itemElements[i]);
            
                if (!pendingRequests) {
                    pendingRequests=[[NSMutableArray alloc]init];
                }
                [pendingRequests addObject:[itemElements[i] attributeForName:@"jid"]];
                
                
            }
        }
    }
    return NO;
    
    
}

#pragma mark - Request Actions

- (IBAction)btnAcceptClick:(id)sender {
    
    [[self appDelegate].xmppRoster acceptPresenceSubscriptionRequestFrom:[pendingRequests objectAtIndex:[self.tableView indexPathForSelectedRow].row] andAddToRoster:YES];
    [self.tableView reloadData];
}

- (IBAction)btnRejectClick:(id)sender {
    [[self appDelegate].xmppRoster rejectPresenceSubscriptionRequestFrom:[pendingRequests objectAtIndex:[self.tableView indexPathForSelectedRow].row]];
}

- (void)FetchFriends{
    NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyJID];
    
    NSError *error = [[NSError alloc] init];
    NSXMLElement *query = [[NSXMLElement alloc] initWithXMLString:@"<query xmlns='jabber:iq:roster'/>"error:&error];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"id" stringValue:myJID];
    [iq addAttributeWithName:@"from" stringValue:myJID];
    [iq addChild:query];
    [[self xmppStream] sendElement:iq];
}




@end
