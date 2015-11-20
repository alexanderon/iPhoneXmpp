//
//  RegistrationViewController.m
//  iPhoneXMPP
//
//  Created by RAHUL on 11/18/15.
//  Copyright © 2015 XMPPFramework. All rights reserved.
//
@import AddressBook;
#import "RegistrationViewController.h"
#import "CountryListViewController.h"
#import "CountryListDataSource.h"
#import "iPhoneXMPPAppDelegate.h"
#import "Rest.h"


@interface RegistrationViewController()<CountryListViewDelegate,UITextFieldDelegate>
@end

@implementation RegistrationViewController
@synthesize btnChooseCountry;

#pragma mark ------------------ Accessors

- (iPhoneXMPPAppDelegate *)appDelegate
{
    return (iPhoneXMPPAppDelegate *)[[UIApplication sharedApplication] delegate];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [[[self appDelegate]xmppStream] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    btnChooseCountry.layer.borderWidth=1.0;
    self.txtCountryCode.enabled=NO;
    self.txtmobileNumber.delegate=self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnCountryClick:(id)sender
{
    
    CountryListViewController *cv = [[CountryListViewController alloc] initWithNibName:@"CountryListViewController" delegate:self];
    [self presentViewController:cv animated:YES completion:NULL];
}

- (void)didSelectCountry:(NSDictionary *)country
{
    NSLog(@"Selected Country : %@", country);
    self.txtCountryCode.text=[country valueForKey:@"dial_code"];
    [btnChooseCountry setTitle:[country valueForKey:@"name"] forState:UIControlStateNormal];
}

#pragma mark -------------------TEXT FEILD DELEGATE

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    return (self.txtmobileNumber.text.length <10);
}

#pragma mark -------------------CREATE USER

- (IBAction)btnCreateUser:(id)sender
{
    
    [self createUserwithName:self.txtmobileNumber.text Password:@"123"];
}

- (void)createUserwithName:(NSString *)username
                  Password:(NSString *)password
{
    [[Rest sharedInstance]createUserwithName:username Password:password];
    [self fetchContact];
    
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
    
    NSMutableArray *rosterItems =[[NSMutableArray alloc]init];
   
    
    
    for (int i=0;i<count;i++)
    {
        ABRecordRef record = (__bridge ABRecordRef)([allContacts objectAtIndex:i]);
        NSString *firstName= CFBridgingRelease(ABRecordCopyValue(record, kABPersonFirstNameProperty));
        ABMultiValueRef *phones  =ABRecordCopyValue(record, kABPersonPhoneProperty);
        NSMutableDictionary *contactInfo=[[NSDictionary alloc]init];
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

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    
    NSXMLElement *query=[iq elementForName:@"query" xmlns:@"jabber:iq:search"];
    
    NSXMLElement * x=[query elementForName:@"x"];
    NSLog(@"%@",x);
    NSXMLElement *item =[x elementForName:@"item"];
    NSLog(@"%@",item);
    
    NSLog(@"%@",item.children);
    for (NSXMLElement *field in item.children)
    {
        NSLog(@"%@",field);
        NSLog(@"%@",[field attributes]);
        NSXMLElement *value = [field elementForName:@"value"];
        
        if ([[value stringValue] isEqualToString:@"Name"]) {
            
        }
        NSLog(@"%@",[value stringValue]);
    }
    
    /* for (int i=0; i<[item childCount]; i++) {
     
     NSXMLElement *field =[item elementForName:@"field"];
     NSLog(@"%@",field);
     NSXMLElement *value =[item elementForName:@"value"];
     NSLog(@"%@",value);
     NSLog(@"%@",value.);
     
     
     /*    if ([[field attributeStringValueForName:@"var"] isEqualToString:@"Name"] ) {
     NSXMLElement *value =[item elementForName:@"value"];
     
     NSLog(@"%@",   [[value elementForName:@"value"] stringValue]);
     }
     
     
     }*/
    
    //     if (field) {
    //
    //
    //
    //        if ([[field attributeStringValueForName:@"var"] isEqualToString:@"Name"] ) {
    //            NSXMLElement *field =[item elementForName:@"value"];
    //            [field]
    //            NSLog(@"%@",field);
    //        }
    //
    //    }
    
    
}

@end
