@import AddressBook;
#import "RootViewController.h"
#import "iPhoneXMPPAppDelegate.h"
#import "SettingsViewController.h"
#import "XMPPFramework.h"
#import "DDLog.h"
#import "ChatViewController.h"
#import "Rest.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@implementation RootViewController
{
    NSMutableURLRequest *request;
    NSData *pngData;
#define URL            @"http://localhost:8080/demo/yourServerScript.php"  // change this URL
    NSMutableArray *rosterItems;
    
    
}

#pragma mark ------------------ Accessors

- (iPhoneXMPPAppDelegate *)appDelegate
{
    return (iPhoneXMPPAppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark ------------------ View lifecycle---------------------------------

- (void)viewDidLoad
{
    pngData=nil;
    [super viewDidLoad];
    [self fetchedResultsController];
    // [self fileUpload];
    // [self uploadImageAsync1:nil];
    [self fetchContact];
    if (rosterItems) {
        [self getAuthorized];
        for (NSDictionary *contact in rosterItems) {
            [self getDetailsofRegisteredUser:[contact valueForKey:@"name"]];
        }
    }
    
    [[[self appDelegate]xmppStream] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor darkTextColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    titleLabel.numberOfLines = 1;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    if ([[self appDelegate] connect])
    {
        titleLabel.text = [[[[self appDelegate] xmppStream] myJID] bare];
        NSLog(@"%@",titleLabel.text);
    } else
    {
        titleLabel.text = @"No JID";
    }
    
    [titleLabel sizeToFit];
    
    self.navigationItem.titleView = titleLabel;
    self.popUpView.superview.hidden=YES;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    //[[self appDelegate] disconnect];
    [[[self appDelegate] xmppvCardTempModule] removeDelegate:self];
    
    [super viewWillDisappear:animated];
    
}

#pragma mark -------------------NSFetchedResultsController

-(NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController == nil)
    {
        NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_roster];
        
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
        NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
        
        NSArray *sortDescriptors = @[sd1, sd2];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:10];
        
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                       managedObjectContext:moc
                                                                         sectionNameKeyPath:@"sectionNum"
                                                                                  cacheName:nil];
        [fetchedResultsController setDelegate:self];
        
        
        NSError *error = nil;
        if (![fetchedResultsController performFetch:&error])
        {
            DDLogError(@"Error performing fetch: %@", error);
        }
        
    }
    
    return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] reloadData];
}

#pragma mark ------------------UITableViewCell helpers

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

#pragma mark ------------------UITableView


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return [[[self fetchedResultsController] sections] count];
    
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
    NSArray *sections = [[self fetchedResultsController] sections];
    //  NSArray *sectionGroup=[[self fetchedGroupsResultsController] sections];
    //   NSLog(@"%lu",(unsigned long)sectionGroup.count);
    NSLog(@"%lu",(unsigned long)(int)[sections count]);
    
    if (sectionIndex < [sections count])
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = sections[sectionIndex];
        
        int section = [sectionInfo.name intValue];
        switch (section)
        {
            case 0  : return @"Available";
            case 1  : return @"Away";
            default : return @"Offline";
        }
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    /* {
     NSLog(@"%d",(int)[[[self fetchedResultsController]fetchedObjects]count]);
     NSLog(@"%d",(int)[[[self fetchedGroupsResultsController]fetchedObjects]count]);
     
     NSLog(@"%@", [[self fetchedGroupsResultsController].fetchedObjects objectAtIndex:0]);
     
     XMPPGroupCoreDataStorageObject *obj =[[self fetchedGroupsResultsController].fetchedObjects objectAtIndex:0];
     NSLog(@"%@",obj.name);
     }*/
    
    NSArray *sections = [[self fetchedResultsController] sections];
    
    if (sectionIndex < [sections count])
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = sections[sectionIndex];
        return sectionInfo.numberOfObjects;
        NSLog(@"%lu",(unsigned long)sectionInfo.numberOfObjects);
    }
    
    /* else
     {
     return [[[self fetchedGroupsResultsController]fetchedObjects]count];
     }*/
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    
    NSLog(@"%d",(int)[[[self fetchedResultsController]fetchedObjects]count]);
    
    
    if (indexPath.row<(int)[[[self fetchedResultsController]fetchedObjects]count]) {
        
        XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        cell.textLabel.text = (user.displayName == nil || [user.displayName isEqualToString:@"null"])?user.jid.user:user.displayName;
        
        [self configurePhotoForCell:cell user:user];
        
        NSLog(@"%@",[[[self appDelegate] xmppvCardTempModule] vCardTempForJID:user.jid shouldFetch:YES]);
        
        
    }/*else{
      int row =indexPath.row-(int)[[[self fetchedResultsController]fetchedObjects]count];
      
      XMPPGroupCoreDataStorageObject *group=[[self fetchedGroupsResultsController]objectAtIndexPath:[indexPath initWithIndex:row]];
      
      cell.textLabel.text=group.name;
      return cell;
      
      }*/
    
    
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    
    ChatViewController *vc =[self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"] ;
    vc.resource=[[[user primaryResource]jid]resource];
    vc.user=user;
    
    
    [self.navigationController pushViewController:vc animated:YES] ;
}


#pragma mark ------------------Actions

- (IBAction)settings:(id)sender
{
    SettingsViewController* settingsViewController = [(UIStoryboard *)[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

- (IBAction)btnAddClick:(id)sender
{
    
    if(self.popUpView.hidden ==NO   ){
        self.popUpView.hidden=YES;
        self.popUpView.superview.hidden=YES;
    }else{
        self.popUpView.hidden=NO;
        self.popUpView.superview.hidden=NO;
    }
    
}

#pragma mark ------------------ Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"CreateGroup"]) {
        self.popUpView.hidden=YES;
    }
}

#pragma mark ------------------File Upload

-(void)serviceDiscovery
{
    
    
    NSXMLElement *request =[NSXMLElement elementWithName:@"request"];
    [request addAttributeWithName:@"urn:xmpp:http:upload" stringValue:@""];
    
    NSXMLElement *filename =[NSXMLElement elementWithName:@"filename"];
    [filename setStringValue:@"aqua.png"];
    
    
    NSXMLElement *size =[NSXMLElement elementWithName:@"size"];
    [size setStringValue:@"1355"];
    
    NSXMLElement *contentType =[NSXMLElement elementWithName:@"content-type"];
    [contentType setStringValue:@"image/png"];
    
    [request addChild:filename];
    [request addChild:size];
    [request addChild:contentType];
    
    
    
    
    
    XMPPIQ *iq =[[XMPPIQ alloc]initWithType:@"get" to:[XMPPJID jidWithString:@"192.168.0.154"] elementID:@"step_3" child:request];
    [iq addAttributeWithName:@"from" stringValue:[[XMPPJID jidWithString:@"test4@192.168.0.154/9spl"] full]];
    [[[self appDelegate] xmppStream] sendElement:iq];
    NSLog(@"%@",iq);
}

-(void)fileUpload
{
    NSString *filePath=[[NSBundle mainBundle]pathForResource:@"divan" ofType:@"mp3"];
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSMutableString *urlString = [[NSMutableString alloc] initWithFormat:@"name=thefile&&filename=recording"];
    [urlString appendFormat:@"%@", data];
    NSData *postData = [urlString dataUsingEncoding:NSASCIIStringEncoding
                               allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    NSString *baseurl = @"http://localhost:8080/demo/yourServerScript.php";
    
    NSURL *url = [NSURL URLWithString:baseurl];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod: @"POST"];
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setValue:@"application/x-www-form-urlencoded"
      forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPBody:postData];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    [connection start];
    
    NSLog(@"Started!");
}

#pragma mark -----------------USER DETAILS

-(void)getAuthorized
{
    /* <iq type='set' id='auth2'>
     <query xmlns='jabber:iq:auth'>
     <username>bill</username>
     <password>Calli0pe</password>
     <resource>globe</resource>
     </query>
     </iq>*/
    
    
    NSXMLElement *query =[NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:auth"];
    
    NSXMLElement *username =[NSXMLElement elementWithName:@"username"];
    NSXMLElement *password =[NSXMLElement elementWithName:@"password"];
    NSXMLElement *resource =[NSXMLElement elementWithName:@"resource"];
    
    [username setStringValue:@"test4"];
    [password setStringValue:@"123"];
    [resource setStringValue:@"9spl"];
    
    [query addChild:username];
    [query addChild:password];
    [query addChild:resource];
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:[XMPPJID jidWithString:servername] elementID:@"auth" child:query];
    [iq addAttributeWithName:@"xml:lang" stringValue:@"en"];
    [iq addAttributeWithName:@"from" stringValue:[[[[self appDelegate] xmppStream] myJID] full]];
    [[[self appDelegate]xmppStream ] sendElement:iq];
    
    NSLog(@"%@",iq);
    
    
}

-(void)getSearchFeilds
{
    NSXMLElement *query =[NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:search"];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:[XMPPJID jidWithString:servername] elementID:@"search" child:query];
    [iq addAttributeWithName:@"xml:lang" stringValue:@"en"];
    [iq addAttributeWithName:@"from" stringValue:[[[[self appDelegate] xmppStream] myJID] full]];
    [[[self appDelegate]xmppStream ] sendElement:iq];
    NSLog(@"%@",iq);
    
}

- (void)getDetailsofRegisteredUser :(NSString *)SearchString
{
    
    //To Search Peticular User either by using their name, email or username
    //
    NSString *userBare1  = [[[[self appDelegate] xmppStream] myJID] bare];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:search"];
    
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    [x addAttributeWithName:@"type" stringValue:@"submit"];
    
    NSXMLElement *formType = [NSXMLElement elementWithName:@"field"];
    [formType addAttributeWithName:@"type" stringValue:@"hidden"];
    [formType addAttributeWithName:@"var" stringValue:@"FORM_TYPE"];
    [formType addChild:[NSXMLElement elementWithName:@"value" stringValue:@"jabber:iq:search" ]];
    
    NSXMLElement *userName = [NSXMLElement elementWithName:@"field"];
    [userName addAttributeWithName:@"var" stringValue:@"Username"];
    [userName addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1" ]];
    
    NSXMLElement *name = [NSXMLElement elementWithName:@"field"];
    [name addAttributeWithName:@"var" stringValue:@"Name"];
    [name addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    
    NSXMLElement *email = [NSXMLElement elementWithName:@"field"];
    [email addAttributeWithName:@"var" stringValue:@"Email"];
    [email addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    
    //Here in the place of SearchString we have to provide registered user name or emailid or username(if it matches in Server it provide registered user details otherwise Server provides response as empty)
    NSXMLElement *search = [NSXMLElement elementWithName:@"field"];
    [search addAttributeWithName:@"var" stringValue:@"search"];
    [search addChild:[NSXMLElement elementWithName:@"value" stringValue:[NSString stringWithFormat:@"%@", SearchString]]];
    
    [x addChild:formType];
    [x addChild:userName];
    [x addChild:name];
    [x addChild:email];
    [x addChild:search];
    [query addChild:x];
    
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"searchByUserName"];
    [iq addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"search.%@",servername]];
    [iq addAttributeWithName:@"from" stringValue:userBare1];
    [iq addChild:query];
    [[[self appDelegate] xmppStream] sendElement:iq];
    
    /* NSString *bareJID  = [[[[self appDelegate]xmppStream] myJID] full];
     
     NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
     [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:search"];
     
     NSXMLElement *email = [NSXMLElement elementWithName:@"email" stringValue:SearchString];
     [query addChild:email];
     
     NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
     [iq addAttributeWithName:@"type" stringValue:@"set"];
     [iq addAttributeWithName:@"id" stringValue:@"search2"];
     [iq addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"search.%@",[[[self appDelegate]xmppStream] myJID].domain]];
     [iq addAttributeWithName:@"from" stringValue:bareJID];
     [iq addAttributeWithName:@"xml:lang" stringValue:@"en"];
     [iq addChild:query];
     [[[self appDelegate]xmppStream] sendElement:iq];*/
}

//We will get response here

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    
    NSXMLElement *query=[iq elementForName:@"query" xmlns:@"jabber:iq:search"];
    
    NSXMLElement * x=[query elementForName:@"x"];
    // NSLog(@"%@",x);
    NSXMLElement *item =[x elementForName:@"item"];
    //  NSLog(@"%@",item);
    
    for (NSXMLElement *field in item.children)
    {
        //NSLog(@"%@",field);
        NSLog(@"%@",[field attributesAsDictionary]);
        
        NSXMLElement *value = [field elementForName:@"value"];
        NSLog(@"%@",[value stringValue]);
        
        if([[[field attributesAsDictionary] valueForKey:@"var"] isEqualToString:@"Name"])
        {
            //     [[Rest sharedInstance]addRoster:[value stringValue] toUser:[[[self appDelegate] xmppStream] myJID].user];
            
            NSString *myUserName =[[[self appDelegate] xmppStream] myJID].user;
            
            [[Rest sharedInstance]getRosterItemsforUser:myUserName withCompletionHandler:^(NSData *data) {
                
                NSLog(@"%@",[[NSMutableString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
                
            }];
            
            if (!myUserName) {
                [self addUser:[value stringValue]];
            }
            
        }
        
    }
    
    return  YES;
}

-(void)addUser:(NSString *)user
{
    [[Rest sharedInstance]addRoster:user toUser:[[[self appDelegate] xmppStream] myJID].user];
}

- (void)fetchContact
{
    
    ABAddressBookRef addressBook;
    __block BOOL userDidGrantAddressBookAccess;
    
    CFErrorRef addressBookError = NULL;
    
    if ( ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized )
    {
        addressBook = ABAddressBookCreateWithOptions(NULL, &addressBookError);
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error){
            userDidGrantAddressBookAccess = granted;
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else
    {
        if ( ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
            ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted )
        {
            // Display an error.
        }
    }
    
    NSArray *allContacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    NSLog(@"%@",allContacts);
    
    int count =(int)[allContacts count];
    
    rosterItems =[[NSMutableArray alloc]init];
    
    
    
    for (int i=0;i<count;i++)
    {
        ABRecordRef record = (__bridge ABRecordRef)([allContacts objectAtIndex:i]);
        NSString *firstName= CFBridgingRelease(ABRecordCopyValue(record, kABPersonFirstNameProperty));
        ABMultiValueRef *phones  =ABRecordCopyValue(record, kABPersonPhoneProperty);
        NSMutableDictionary *contactInfo=[[NSMutableDictionary alloc]init];
        
        [contactInfo setValue:firstName forKey:@"name"];
        
        NSMutableArray *mobiles =[[NSMutableArray alloc]init];
        for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
        {
            CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);
            CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phones, j);
            NSString *phoneLabel =(__bridge NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
            //CFRelease(phones);
            NSString *phoneNumber = (__bridge NSString *)phoneNumberRef;
            CFRelease(phoneNumberRef);
            CFRelease(locLabel);
            [mobiles addObject:phoneNumber];
            NSLog(@"  - %@ (%@)", phoneNumber, phoneLabel);
        }
        
        [contactInfo setObject:mobiles forKey:@"mobiles"];
        NSLog(@"%@",firstName);
        [rosterItems addObject:contactInfo];
    }
    
    
}

@end