//
//  ContactListViewController.m
//  iPhoneXMPP
//
//  Created by RAHUL on 10/29/15.
//  Copyright © 2015 XMPPFramework. All rights reserved.
//

#import "ContactListViewController.h"
#import "iPhoneXMPPAppDelegate.h"
#import "TLTagsControl.h"
#import "XMPPRoomMemoryStorage.h"
#import "XMPPMUC.h"
#import "Rest.h"

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif


@interface ContactListViewController ()<UITableViewDataSource,UITableViewDelegate,XMPPStreamDelegate,XMPPRoomDelegate,XMPPMUCDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet TLTagsControl *defaultEditingTagControl;
@end

@implementation ContactListViewController
{
    NSMutableArray *tags ;
    XMPPMUC *muc;
}
@synthesize tableView;


#pragma  mark -PATH TO DOCUMENT DIRECTORY------------
-(void)pathToDocumetDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/MyFolder"];
    NSLog(@"%@",dataPath);
}

#pragma mark ----------------VIEW LIFECYCLE -------------
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self showNavigation];
    [self hideNaviagation];
    
    // [self.defaultEditingTagControl setMode:TLTagsControlModeList];
    [self.defaultEditingTagControl setTapDelegate:self];
    //[demoTagsControl reloadTagSubviews];
    //[demoTagsControl setTapDelegate:self];
    
    
    //[self.view addSubview:demoTagsControl];
    //[self drawUnderLine:demoTagsControl.tag];
    // self.defaultEditingTagControl.delegate = self;
    
    tableView.delegate=self;
    tableView.dataSource=self;
    
    // [self getRooms];
    [[[self appDelegate] xmppStream]addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    muc =[[XMPPMUC alloc]init];
    [muc activate:[self appDelegate].xmppStream];
    [muc addDelegate:self delegateQueue:dispatch_get_main_queue()];
    // [self createGroup:@"hello"];
    // [self getChildrenOfNode:@"hello"];
    //[self getItemsInCollection:@"hello"];
    // [self serviceDiscovery];
    //[self messageToExtendedAdress];
    
    [self pathToDocumetDirectory];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self drawUnderLine:self.defaultEditingTagControl.tag];
}

-(void)drawUnderLine:(NSInteger *)tag
{
    
    UIView  *view = [self.view viewWithTag:tag];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, view.frame.size.height-1 , view.frame.size.width,1.0f);
    bottomBorder.backgroundColor = [UIColor blackColor].CGColor;
    [view.layer insertSublayer:bottomBorder atIndex:(int)view.layer.sublayers.count];
    
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark ----------------GENEREAL METHODS-----------------

-(void)showNavigation
{
    self.navigationController.navigationBarHidden=NO;
}

-(void)hideNaviagation
{
    self.navigationController.navigationBarHidden=YES;
}




#pragma mark ----------------TABLE VIEW DELEGATE -------------

-(void)tableView:(UITableView *)tabView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tabView cellForRowAtIndexPath:indexPath];
    NSString *object =[NSString stringWithFormat:@"%@",cell.textLabel.text];
    NSString *index =[NSString stringWithFormat:@"%d",(int)indexPath.row];
    
    NSDictionary *dict =@{@"object":object,
                          @"index":index};
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.defaultEditingTagControl.tags removeObject:dict];
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.defaultEditingTagControl.tags addObject:dict];
    }
    
    [self.defaultEditingTagControl reloadTagSubviews];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self fetchedResultsController] fetchedObjects] count];
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Favourite";
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

#pragma mark ----------------TABLE VIEW DATASOURCE ----------------

-(UITableViewCell *)tableView:(UITableView *)tabView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell =[tabView  dequeueReusableCellWithIdentifier:@"ContactCell"];
    
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController].fetchedObjects objectAtIndex:indexPath.row];
    cell.textLabel.text = user.jidStr;
    [self configurePhotoForCell:cell user:user];
    return cell;
}

#pragma mark ----------------UITABLECELL HELPERS---------------------

- (void)configurePhotoForCell:(UITableViewCell *)cell user:(XMPPUserCoreDataStorageObject *)user
{
    // Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
    // We only need to ask the avatar module for a photo, if the roster doesn't have it.
    
    if (user.photo != nil)
    {
        cell.imageView.image = user.photo;
    }
    else
    {
        NSData *photoData = [[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:user.jid];
        
        if (photoData != nil)
            cell.imageView.image = [UIImage imageWithData:photoData];
        else
            cell.imageView.image = [UIImage imageNamed:@"defaultPerson"];
    }
}

#pragma mark ----------------TLTAG-CONTROL-DELEGATE--------------------

-(void)tagsControl:(TLTagsControl *)tagsControl tappedAtIndex:(NSInteger)index
{
    NSLog(@"%ld",(long)index);
    NSDictionary *dict=[self.defaultEditingTagControl.tags objectAtIndex:index];
    NSLog(@"%@",[dict valueForKey:@"index"]);
}

-(void)tagsControl:(TLTagsControl *)tagsControl deletedAtIndex:(NSInteger)index
{
    
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathWithIndex:index] animated:YES];
    NSIndexPath *path =[NSIndexPath indexPathForRow:index inSection:0];
    UITableViewCell *cell =[self.tableView cellForRowAtIndexPath:path];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    
}



#pragma mark ----------------XMPP ROOM DELEGATE -------------------------

- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    [sender fetchConfigurationForm];
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}



#pragma mark ---------------XMPP MUC DELEGATE----------------------------

-(void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *)roomJID didReceiveInvitation:(XMPPMessage *)message{
    
    NSLog(@"Requst For :%@ ,with Message:%@",roomJID ,message);
    XMPPRoomMemoryStorage *roomMemory=[[XMPPRoomMemoryStorage alloc]init];
    
    XMPPRoom *xmppRoom =[[XMPPRoom alloc]initWithRoomStorage:roomMemory
                                                         jid:roomJID
                                               dispatchQueue:dispatch_get_main_queue()];
    
    [xmppRoom activate:[[self appDelegate] xmppStream]];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoom joinRoomUsingNickname:[[self appDelegate].xmppStream.myJID bare] history:nil password:nil];
    
    
}

-(void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *)roomJID didReceiveInvitationDecline:(XMPPMessage *)message{
    NSLog(@"");
}



#pragma mark ----------------IB ACTION -GROUP CREATION -----------------

- (IBAction)btnCreateGroupClick:(id)sender
{
    [[Rest sharedInstance]setUser:@"dipesh" Password:@"Test105*"];
  
    [[Rest sharedInstance]createGroupWithName:self.groupName Description:@"descrition" withCompletionHandler:^(int data) {
        NSLog(@"%d",data);
        NSLog(@"%@",self.defaultEditingTagControl.tags);
        for (NSDictionary *dict  in self.defaultEditingTagControl.tags) {
            
            NSString *user =[dict objectForKey:@"object"];
            [[Rest sharedInstance]addUser:user ToGroup:self.groupName];
        }
        [[Rest sharedInstance]addUser:@"dipesh" ToGroup:self.groupName];
    }] ;
    
  
    
    [[Rest sharedInstance]createChatRoomWithName:self.groupName Description:@"description" withCompletionHandler:^(int data) {
        
            NSLog(@"%d",data);
            
            for (NSDictionary *dict  in self.defaultEditingTagControl.tags) {
                
                NSString *user =[dict objectForKey:@"object"];
                
                [[Rest sharedInstance]addUser:user ToChatRoom:self.groupName Role:@"members"];
            }
            [[Rest sharedInstance]addUser:@"dipesh" ToChatRoom:self.groupName Role:@"admins"];
        
    } ];
    
    
    
    //  [[Rest sharedInstance]createChatRoomWithName:self.groupName];
    // [[Rest sharedInstance]addUser:@"test1@192.168.0.120" ToGroup:self.groupName];
    
    
    
    //    XMPPRoomMemoryStorage *roomMemory=[[XMPPRoomMemoryStorage alloc]init];
    //    NSString *roomID=@"google@conference.192.168.0.120";
    //    XMPPJID *roomJID =[XMPPJID jidWithString:roomID];
    //
    //
    //    XMPPRoom *xmppRoom =[[XMPPRoom alloc]initWithRoomStorage:roomMemory
    //                                                         jid:roomJID
    //                                               dispatchQueue:dispatch_get_main_queue()];
    //    [xmppRoom activate:[[self appDelegate] xmppStream]];
    //    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    //    [xmppRoom joinRoomUsingNickname:@"nickName" history:nil password:nil];
    //    [xmppRoom fetchConfigurationForm];
    //    [xmppRoom inviteUser:[XMPPJID jidWithString:@"test4@192.168.0.120"] withMessage:@"hi"];
    
}

- (IBAction)btnBackClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}



@end
