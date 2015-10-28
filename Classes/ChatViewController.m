//
//  ChatViewController.m
//  iPhoneXMPP
//
//  Created by RAHUL on 10/17/15.
//  Copyright © 2015 XMPPFramework. All rights reserved.
//

#import "ChatViewController.h"
#import "ProfileViewController.h"


@interface ChatViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic) UIImage *image;
@property (copy, nonatomic) NSString *lastChosenMediaType;
@property (nonatomic, strong) XMPPOutgoingFileTransfer *fileTransfer;
@end

@implementation ChatViewController
@synthesize user;
@synthesize imgUser;
@synthesize lblUserName;

#pragma mark Accessors
- (iPhoneXMPPAppDelegate *)appDelegate{
    return (iPhoneXMPPAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (XMPPStream *)xmppStream {
    return [[self appDelegate] xmppStream];
}

- (XMPPMessageArchiving *)xmppMessageArchivingModule{
    return [[self appDelegate] xmppMessageArchivingModule];
}



#pragma mark -View Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self.tableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [[self xmppStream]addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [[self appDelegate].xmppIncomingFileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self.chatWindow becomeFirstResponder];
    
    sentMessages= [[NSMutableArray alloc] init];
    turnSockets = [[NSMutableArray alloc] init];
    
    TURNSocket *turnSocket = [[TURNSocket alloc] initWithStream:[self xmppStream] toJID:[XMPPJID jidWithString:user.jidStr]];
    [turnSockets addObject:turnSocket];
    [turnSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [[self xmppMessageArchivingModule] activate:[self xmppStream]];

    [self loadarchivemsg];
  
    
    chatFeild =[[HPGrowingTextView alloc]initWithFrame:[self.contentView frame]];
    [chatFeild setTintColor:[UIColor blueColor]];
    
    chatFeild.minNumberOfLines=1;
    chatFeild.maxNumberOfLines=4;
    
    chatFeild.font = [UIFont systemFontOfSize:15.0f];
    chatFeild.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    chatFeild.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    chatFeild.animateHeightChange=YES;
    [chatFeild.internalTextView becomeFirstResponder];
  
    //To make the border look very close to a UITextField
    [chatFeild.internalTextView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [chatFeild.internalTextView.layer setBorderWidth:2.0];
    
    //The rounded corner part, where you specify your view's corner radius:
    chatFeild.internalTextView.layer.cornerRadius = 5;
    chatFeild.internalTextView.clipsToBounds = YES;

    
    [self.contentView addSubview:chatFeild];
    
    chatFeild.delegate=self;

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden=YES;
   
    [self setUpImage];
    [self setUserName];
    self.tableview.estimatedRowHeight = 70.0; // for example. Set your average height
    self.tableview.rowHeight = UITableViewAutomaticDimension;
    [self.tableview reloadData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -=SetUp Image =-

- (void)setUpImage{
       
    if (user.photo != nil)
    {
        self.imgUser.image=user.photo;
    }
    else
    {
        NSData *photoData = [[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:user.jid];
        
        if (photoData != nil)
           imgUser.image = [UIImage imageWithData:photoData];
        else
            imgUser.image = [UIImage imageNamed:@"defaultPerson"];
    }

}

- (void)setUserName{
    lblUserName.text=user.displayName;
}

-(NSString *)getResource{
    return [[[user primaryResource]jid] resource];
}
#pragma mark Table view delegates


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    /* static NSString *CellIdentifier = @"MessageCellIdentifier";
     UITableViewCell *cell  =[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
     cell.textLabel.text=[[sentMessages objectAtIndex:indexPath.row] valueForKey:@"msg"];
     return cell;*/
    
    
    
    NSDictionary *s = (NSDictionary *) [sentMessages objectAtIndex:indexPath.row];
    NSString *sender = [s objectForKey:@"sender"];
    NSString *message = [s objectForKey:@"msg"];
    NSString *time = [s objectForKey:@"time"];
    UIImage *image =[s objectForKey:@"image"];
    static NSString *CellIdentifier =@"";
    
    
    CellIdentifier = image == nil ? @"MessageCell" : @"ImageCell";
    
    
    MessageCell *cell = (MessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ([CellIdentifier  isEqualToString:@"MessageCell"]) {
        
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MessageCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        
        
        
        cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@ %@", sender, time];
        
        if ([sender isEqualToString:@"you"])
        {
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
   
        
    }else{
        
        ImageViewCell *cell =(ImageViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ImageViewCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        
        if ([sender isEqualToString:@"you"])
        {
            cell.rightView.hidden=YES;
            cell.leftView.hidden=NO;
            cell.imgLeft.image=image;
        }
        else
        {
            cell.rightView.hidden=NO;
            cell.leftView.hidden=YES;
            cell.imgRight.image=image;
        }
        
        //  NSLog(@"%f",cell.contentView.frame.size.height);
        return cell;
        
    }
    
    
    
    
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    NSDictionary * currentTweet = [sentMessages objectAtIndex: indexPath.row];
    
    
    NSString * tweetTextString = [currentTweet objectForKey: @"msg"];
    
 //   CGSize textSize = [tweetTextString sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:CGSizeMake(240, 20000) lineBreakMode: UILineBreakModeWordWrap]; //Assuming your width is 240
    
   // available only on ios7.0 sdk.
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:15]};

    CGRect rect = [tweetTextString boundingRectWithSize:CGSizeMake(240, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil];
    
    
//    float heightToAdd = MIN(textSize.height, 100.0f); //Some fix height is returned if height is small or change it to MAX(textSize.height, 150.0f); // whatever best fits for you
    float heightToAdd = MIN(rect.size.height, 100.0f);
    return heightToAdd+30.0f;
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
    
    NSString *messageStr = chatFeild.text;
    
    
    if([messageStr length] > 0 || [self.image isKindOfClass:[UIImage class]] )
        
    {
        
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        
        [body setStringValue:messageStr];
        
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        
        [message addAttributeWithName:@"to" stringValue:user.jidStr];
        
        [message addChild:body];
        
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        
        if([self.image isKindOfClass:[UIImage class]] && self.image !=nil)
            
        {
            [m setObject:self.image forKey:@"image"];
            
            NSData *dataPic =  UIImagePNGRepresentation(self.image);
            
            NSXMLElement *photo = [NSXMLElement elementWithName:@"image"];
            
            //  NSXMLElement *binval = [NSXMLElement elementWithName:@"BINVAL"];
            
            //[photo addChild:photo];
            
            NSString *base64String = [dataPic base64EncodedStringWithOptions:0];
            
            [photo setStringValue:base64String];
            
            [message addChild:photo];
        }
        
        [[self appDelegate].xmppStream sendElement:message];
        
        self.chatWindow.text = @"";
     
        chatFeild.text=@"";
        [m setObject:[messageStr substituteEmoticons] forKey:@"msg"];
        [m setObject:@"you" forKey:@"sender"];
        [m setObject:[NSString getCurrentTime] forKey:@"time"];
        
        [sentMessages addObject:m];
        [self.tableview reloadData];
        self.image=nil;
        
    }
    
    
    NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:sentMessages.count-1
                                                   inSection:0];
    
    [self.tableview scrollToRowAtIndexPath:topIndexPath
                      atScrollPosition:UITableViewScrollPositionMiddle
                              animated:YES];

    
}

- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData
{
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:
                    NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
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
        
        NSString *body = [[message elementForName:@"body"] stringValue];
        NSString *displayName = [user displayName];
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        
        
        [m setObject:[body substituteEmoticons] forKey:@"msg"];
        [m setObject:displayName forKey:@"sender"];
        [m setObject:[NSString getCurrentTime] forKey:@"time"];
        
        if ([[message elementForName:@"image"] stringValue]!=nil)
            [m setObject:[self decodeBase64ToImage:[[message elementForName:@"image"] stringValue]] forKey:@"image"];
        [sentMessages addObject:m];
        
        NSIndexPath *path1 = [NSIndexPath indexPathForRow:[sentMessages count]-1  inSection:0];
        
        [self.tableview beginUpdates];
        [self.tableview insertRowsAtIndexPaths:@[path1] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableview endUpdates];
        
        if(![self.tableview.indexPathsForVisibleRows containsObject:path1])
        {
            [self.tableview scrollToRowAtIndexPath:path1 atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
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
    //   [request setFetchLimit:1];
    [request setFetchBatchSize:20];
    
    NSError *error;
    NSString *predicateFrmt = @"bareJidStr == %@";
    NSPredicate *predicate =[NSPredicate predicateWithFormat:predicateFrmt,user.jidStr];
    request.predicate = predicate;
    NSArray *messages = [moc executeFetchRequest:request error:&error];
    
    
    for (XMPPMessageArchiving_Message_CoreDataObject *message in messages) {
        
        NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message.messageStr error:nil];
        
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        [m setObject:message.body forKey:@"msg"];
        
        if ([[element attributeStringValueForName:@"to"] isEqualToString:user.jidStr])
        {
            
            [m setObject:@"you" forKey:@"sender"];
            
        }
        else
        {
            [m setObject:user.jidStr forKey:@"sender"];
        }
        
      //  n(@"%@",[element elementForName:@"image"] );
        
        NSDate *date = message.timestamp;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [m setObject:[dateFormatter stringFromDate:date] forKey:@"time"];
        
        if ([element elementForName:@"image"]) {
             [m setObject:[self decodeBase64ToImage:[[element elementForName:@"image"] stringValue ] ] forKey:@"image"];
        }
       
        [sentMessages addObject:m];
        
    }
    [self.tableview reloadData];

}

#pragma mark - Decode Image

/*- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData
{
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:
                    NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}*/

#pragma mark - select Image From Gallary
- (IBAction)btnChooseImageClick:(id)sender{
    [self pickMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)pickMediaFromSource:(UIImagePickerControllerSourceType)sourceType
{
    NSArray *mediaTypes = [UIImagePickerController
                           availableMediaTypesForSourceType:sourceType];
    if ([UIImagePickerController
         isSourceTypeAvailable:sourceType] && [mediaTypes count] > 0) {
        NSArray *mediaTypes = [UIImagePickerController
                               availableMediaTypesForSourceType:sourceType];
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.mediaTypes = mediaTypes;
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:NULL];
    } else {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"Error accessing media"
                                   message:@"Unsupported media source."
                                  delegate:nil
                         cancelButtonTitle:@"Drat!"
                         otherButtonTitles:nil];
        [alert show];
    }
}


#pragma mark -send File 

- (IBAction)btnFileSendClick:(id)sender {
    if (!_fileTransfer) {
        _fileTransfer = [[XMPPOutgoingFileTransfer alloc]
                         initWithDispatchQueue:dispatch_get_main_queue()];
        [_fileTransfer activate:[self appDelegate].xmppStream];
        _fileTransfer.disableSOCKS5=YES;
        [_fileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    
   
   
    NSString *filename = @"aqua.png";
    
    // do error checking fun stuff...
    
   /* NSString *fullPath = [[self documentsDirectory] stringByAppendingPathComponent:filename];
    NSData *data = [NSData dataWithContentsOfFile:fullPath];
    
    NSError *err;
    if (![_fileTransfer sendData:data
                           named:filename
                     toRecipient:[XMPPJID jidWithString:recipient]
                     description:@"Baal's Soulstone, obviously."
                           error:&err]) {
      _inputRecipient.text;*/
  //  NSLog(@"%@",self.resource);
    
    NSString *fullPath =[[NSBundle mainBundle]pathForResource:@"aqua" ofType:@"png"];
//NSLog(@"%@",fullPath);
    NSData *data =[NSData dataWithContentsOfFile:fullPath];
    NSError *error;
    if (![_fileTransfer sendData:data
                           named:filename
                     toRecipient:[XMPPJID jidWithString:user.jidStr resource:[self getResource]]
                     description:@"Baal's Soulstone, obviously."
                           error:&error]) {
        NSLog(@"Error in the File Transfer");
    }

}


#pragma mark - XMPPOutgoingFileTransferDelegate Methods

- (void)xmppOutgoingFileTransfer:(XMPPOutgoingFileTransfer *)sender
                didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"There was an error sending your file. See the logs."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)xmppOutgoingFileTransferDidSucceed:(XMPPOutgoingFileTransfer *)sender
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                    message:@"Your file was sent successfully."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


#pragma mark - Image Picker Controller delegate methods



-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    self.lastChosenMediaType = info[UIImagePickerControllerMediaType];
    if ([self.lastChosenMediaType isEqual:(NSString *)kUTTypeImage]) {
        self.image = info[UIImagePickerControllerOriginalImage];
        
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}




#pragma mark - Back Button Click
- (IBAction)btnBackClick:(id)sender {
    self.navigationController.navigationBarHidden=FALSE;
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Show Profile


- (IBAction)showProfile:(id)sender {
    
    ProfileViewController *vc =[self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    vc.user=user;
    [self.navigationController pushViewController:vc animated:YES];
}



# pragma mark Textview delegeate functions

-(void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height{
    
    float diff = (growingTextView.frame.size.height - height);
    CGRect r = self.contentView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    self.contentView.frame = r;
    
}
@end
