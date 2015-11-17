#import "RootViewController.h"
#import "iPhoneXMPPAppDelegate.h"
#import "SettingsViewController.h"
#import "XMPPFramework.h"
#import "DDLog.h"
#import "ChatViewController.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@implementation RootViewController

#pragma mark ------------------ Accessors

- (iPhoneXMPPAppDelegate *)appDelegate
{
    return (iPhoneXMPPAppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark ------------------ View lifecycle---------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];
   // NSLog(@"%d",(int)[[[self fetchedResultsController]fetchedObjects]count]);
    [self fileUpload];
    
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

/*-(NSFetchedResultsController *)fetchedGroupsResultsController
{
    
    if (fetchedGroupsResultsController == nil) {
        NSManagedObjectContext *moc  =[[self appDelegate] managedObjectContext_roster];
        
        NSEntityDescription *groupEntity =[NSEntityDescription entityForName:@"XMPPGroupCoreDataStorageObject" inManagedObjectContext:moc];
        
        NSSortDescriptor *sortByName = [[NSSortDescriptor alloc]
                                        initWithKey:@"name" ascending:YES];
        NSArray *sortDescriptors = @[sortByName];

        
        NSFetchRequest *groupsFetchRequest = [[NSFetchRequest alloc] init];
        [groupsFetchRequest setEntity:groupEntity];
        [groupsFetchRequest setFetchBatchSize:10];
        [groupsFetchRequest setSortDescriptors:sortDescriptors];
        
        fetchedGroupsResultsController =[[NSFetchedResultsController alloc]
                                         initWithFetchRequest:groupsFetchRequest
                                         managedObjectContext:moc                                                                             sectionNameKeyPath:nil                                                                                      cacheName:nil];
        [fetchedGroupsResultsController setDelegate:self];
        
        NSError *error = nil;
        if (![fetchedGroupsResultsController performFetch:&error])
        {
            DDLogError(@"Error performing fetch: %@", error);
        }
        
        
    }
    return fetchedGroupsResultsController;
}*/

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
        
        cell.textLabel.text = user.displayName;
        
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


#pragma mark ------------------Actions-----------------------------------------

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


#pragma mark ------------------ Navigation ----------------------

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"CreateGroup"]) {
        self.popUpView.hidden=YES;
    }
}

#pragma mark ------------------File Upload

-(void)serviceDiscovery{
    
    
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


-(void)fileUpload{
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

@end
