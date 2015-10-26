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
#import "XMPPMessageArchiving.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ImageViewCell.h"

@interface ChatViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic) UIImage *image;
@property (copy, nonatomic) NSString *lastChosenMediaType;
@end

@implementation ChatViewController

#pragma mark Accessors
- (iPhoneXMPPAppDelegate *)appDelegate{
    return (iPhoneXMPPAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (XMPPStream *)xmppStream {
    return [[self appDelegate] xmppStream];
}

-(XMPPMessageArchiving *)xmppMessageArchivingModule{
    return [[self appDelegate] xmppMessageArchivingModule];
}

- (id) initWithUser:(NSString *) userName {
    
    if (self = [super init]) {
        
        self.chatWithUser = userName;
    }
    
    return self;
    
}


#pragma mark -View Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self.tableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [[self xmppStream]addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.chatWindow becomeFirstResponder];
    
    sentMessages= [[NSMutableArray alloc] init];
    turnSockets = [[NSMutableArray alloc] init];
    
    TURNSocket *turnSocket = [[TURNSocket alloc] initWithStream:[self xmppStream] toJID:[XMPPJID jidWithString:_chatWithUser]];
    [turnSockets addObject:turnSocket];
    [turnSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [[self xmppMessageArchivingModule] activate:[self xmppStream]];
    
   
    [self loadarchivemsg];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationItem setTitle:self.chatWithUser];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    
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
        return cell;
        
    }
    
    
    
    
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
    
    /*NSString *messageStr = self.chatWindow.text;
    
    if([messageStr length] > 0) {
        
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageStr];
        
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:self.chatWithUser];
        [message addChild:body];
        
        if (self.image) {
            NSData *dataPic =UIImagePNGRepresentation(self.image);
            NSXMLElement *photo =[NSXMLElement elementWithName:@"image"];
            //     NSXMLElement *binval =[NSXMLElement elementWithName:@"BINVAL"];
            NSString *base64String =[dataPic base64EncodedStringWithOptions:0];
            [photo setStringValue:base64String];
            //        [photo addChild:binval];
            [message addChild:photo];
        }
       
        
        [[self  xmppStream] sendElement:message];
        
        self.chatWindow.text = @"";
        
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        [m setObject:[messageStr substituteEmoticons] forKey:@"msg"];
        [m setObject:@"you" forKey:@"sender"];
        [m setObject:[NSString getCurrentTime] forKey:@"time"];
        [m setObject:self.image forKey:@"image"];
        [sentMessages addObject:m];
        
        [self reloadTable];
        self.image=nil;
    }*/
    
    NSString *messageStr = self.chatWindow.text;
    
   // UIImage *imagePic = [UIImage imageNamed:@"logo.png"];
 //   self.image=[UIImage imageNamed:@"defaultPerson.png"];
    
    if([messageStr length] > 0 || [self.image isKindOfClass:[UIImage class]] )
        
    {
        
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        
        [body setStringValue:messageStr];
        
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        
        [message addAttributeWithName:@"to" stringValue:self.chatWithUser];
        
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
    NSPredicate *predicate =[NSPredicate predicateWithFormat:predicateFrmt,_chatWithUser];
    request.predicate = predicate;
    NSArray *messages = [moc executeFetchRequest:request error:&error];
    
    
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
        
      //  NSLog(@"%@",[element elementForName:@"image"] );
        
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

@end
