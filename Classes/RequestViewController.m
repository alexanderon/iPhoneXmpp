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

#pragma mark Core Data

- (NSManagedObjectContext *)managedObjectContext_roster{
    return [xmppRosterStorage mainThreadManagedObjectContext];
}




#pragma mark -view load methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    [[self appDelegate].xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [[self appDelegate].xmppStream  addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
      pendingRequests =[[NSMutableArray alloc]initWithArray:[[self appDelegate].pendingRequests allObjects]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -
#pragma mark Table view delegates


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"RequestCell";
    RequestTableViewCell *cell  =(RequestTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    
    NSDictionary *dictUser = (NSDictionary *)[pendingRequests objectAtIndex:indexPath.row];
   
    NSLog(@"%@",dictUser);
 //   cell.lblRequestFromUser.text =[(NSMutableDictionary *)[pendingRequests objectAtIndex:indexPath.row] valueForKey:@"fromStr"];
    
    cell.lblRequestFromUser.text =[NSString stringWithFormat:@"%@",[pendingRequests objectAtIndex:indexPath.row]];
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([pendingRequests count] == 0) {
        return 1;
    }else{
        return [pendingRequests count];
        
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

#pragma mark XMPPRosterDelegate
-(void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    
    NSLog(@"request from:%@",[presence fromStr]);
    
    NSMutableDictionary *dictUser = [[NSMutableDictionary alloc]init];
    [dictUser  setValue:[presence fromStr] forKey:@"fromStr"];
    
    if (!pendingRequests) {
        pendingRequests =[[NSMutableArray alloc]initWithArray:[[self appDelegate].pendingRequests allObjects]];
    }
    [pendingRequests addObject:dictUser];
    [self.tableView reloadData];
}


#pragma mark  - XMPPSTREAM Delegate

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    
    //   NSString *presenceFromStr =[presence fromStr];
    NSLog(@"%@",[presence fromStr]);
    
   // DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
    
    
}


-(BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    
    return NO;
}
@end
