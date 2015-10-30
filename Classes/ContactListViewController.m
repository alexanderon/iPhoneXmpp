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
    // [self drawUnderLine:demoTagsControl.tag];
    // self.defaultEditingTagControl.delegate = self;
    
    tableView.delegate=self;
    tableView.dataSource=self;
    
    [self getRooms];
    [[[self appDelegate] xmppStream]addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    muc =[[XMPPMUC alloc]init];
    [muc activate:[self appDelegate].xmppStream];
    [muc addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
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

-(void)getRooms
{
    NSString* server = @"192.168.0.120"; //or whatever the server address for muc is
    XMPPJID *servrJID = [XMPPJID jidWithString:server];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:servrJID];
    [iq addAttributeWithName:@"from" stringValue:[[[self appDelegate]xmppStream] myJID].full];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/disco#items"];
    [iq addChild:query];
    [[[self appDelegate]xmppStream] sendElement:iq];
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

#pragma mark ----------------XMPP STREAM -DELEGATE ---------------------

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    NSLog(@"%@",[iq description]);
    return NO;
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

- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm
{
    NSXMLElement *newConfig = [configForm copy];
    NSArray *fields = [newConfig elementsForName:@"field"];
    
    for (NSXMLElement *field in fields)
    {
        NSString *var = [field attributeStringValueForName:@"var"];
        // Make Room Persistent
        if ([var isEqualToString:@"muc#roomconfig_persistentroom"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
        }
    }
    
    for (NSDictionary *dict in self.defaultEditingTagControl.tags) {
        NSString *object =[dict valueForKey:@"object"];
        [sender inviteUser:[XMPPJID jidWithString:object] withMessage:@"GReetings"];
    }
    
    [sender configureRoomUsingOptions:newConfig];
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
    
    XMPPRoomMemoryStorage *roomMemory=[[XMPPRoomMemoryStorage alloc]init];
    NSString *roomID=@"hello@conference.192.168.0.120";
    XMPPJID *roomJID =[XMPPJID jidWithString:roomID];
    
    
    XMPPRoom *xmppRoom =[[XMPPRoom alloc]initWithRoomStorage:roomMemory
                                                         jid:roomJID
                                               dispatchQueue:dispatch_get_main_queue()];
    [xmppRoom activate:[[self appDelegate] xmppStream]];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoom joinRoomUsingNickname:@"nickName" history:nil password:nil];
    [self getRooms];
}

- (IBAction)btnBackClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
