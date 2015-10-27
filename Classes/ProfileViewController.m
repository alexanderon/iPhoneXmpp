//
//  ProfileViewController.m
//  Restourant
//
//  Created by RAHUL on 9/7/15.
//  Copyright (c) 2015 RAHUL. All rights reserved.
//

#import "ProfileViewController.h"
#import "XMPPvCardTemp.h"

@interface ProfileViewController ()
{
    //   UIAlertView *myAlertView;
    UITextField *myTextField;
    
}
@property (copy, nonatomic) NSString *lastChosenMediaType;
@property (strong, nonatomic) UIImage *image;



@end

@implementation ProfileViewController
@synthesize user;

#pragma mark -view Loading
- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        
        
        NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
        NSData* myEncodedImageData = [userDefaults objectForKey:@"myEncodedImageDataKey"];
        
        UIImage* image = [UIImage imageWithData:myEncodedImageData];
        self.imgProfile.image=image;
        
        
        
        self.btnEdit = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnEdit .backgroundColor = [UIColor whiteColor];
        self.btnEdit .layer.borderColor = [UIColor blackColor].CGColor;
        self.btnEdit .layer.borderWidth = 0.5f;
        self.btnEdit .layer.cornerRadius = 10.0f;
        self.navigationController.navigationBarHidden=NO;
        
        
    }
    
    self.viewPassChanger.hidden =true;
    
    //setting round profile imageview
    self.imgProfile.layer.cornerRadius=(CGFloat) 50;
    self.imgProfile.clipsToBounds=YES;
    
    UIColor *borderColor = [UIColor colorWithRed:1.0 green:13.0 blue:1.0 alpha:1.0 ];
    [self.imgProfile.layer setBorderColor:borderColor.CGColor];
    [self.imgProfile.layer setBorderWidth:3.0];
    // [productView addSubview:viewImage];
    
    
    
    //laoding of the user data
    
    
    //making textfeild disabled
    self.txtEmial.enabled=NO;
    self.txtFirstName.enabled=NO;
    self.txtLastName.enabled=NO;
    self.txtPassword.enabled=NO;
    self.txtMobile.enabled=NO;
    self.txtNewPassword.enabled=NO;
    self.txtConfirmPassword.enabled=NO;
    
    
    
}



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self updateDisplay];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark- validation

- (NSString *)validateForm {
    NSString *errorMessage;
    
    NSString *regex = @"[^@]+@[A-Za-z0-9.-]+\\.[A-Za-z]+";
    NSString *regexMobile=@"[0-9]{10}$";
    
    
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    NSPredicate *mobilePredicate=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",regexMobile];
    
    if (!(self.txtFirstName.text.length >= 1)){
        errorMessage = @"Please enter a first name";
    }else if (!(self.txtLastName.text.length >= 1)){
        errorMessage = @"Please enter a last name";
    } else if (![emailPredicate evaluateWithObject:self.txtEmial.text]){
        errorMessage = @"Please enter a valid email address";
    }else if(!(self.txtPassword.text.length>=1)){
        errorMessage=@"Please enter Current Password";
    }else if (!(self.txtNewPassword.text.length >= 1)){
        errorMessage = @"Please enter a valid New password";
    }else if(![mobilePredicate evaluateWithObject:self.txtMobile.text]){
        errorMessage=@"Please enter a valid Mobile";
    }else if(![self.txtNewPassword.text    isEqual:self.txtConfirmPassword.text] ){
        errorMessage = @"Password Not Matching";
    }
    return errorMessage;
}







- (IBAction)btnSaveClick:(id)sender {
    [self.txtFirstName becomeFirstResponder];
    
    UIButton *buttonEdit =(UIButton *) sender;
    if([buttonEdit.titleLabel.text isEqual:@"Save"])
    {
        //making textfeild disabled
        self.txtFirstName.enabled=NO;
        self.txtLastName.enabled=NO;
        self.txtMobile.enabled=NO;
        
        self.txtFirstName.borderStyle=UITextBorderStyleNone;
        self.txtLastName.borderStyle=UITextBorderStyleNone;
        self.txtMobile.borderStyle=UITextBorderStyleNone;
        
      //  [self updateInfo];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Profile Updated" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
        
        [buttonEdit setTitle:@"Edit" forState:UIControlStateNormal];
        
    }else if([buttonEdit.titleLabel.text isEqual:@"Edit"]){
        
        
        self.txtFirstName.enabled=YES;
        self.txtLastName.enabled=YES;
        self.txtMobile.enabled=YES;
        
        self.txtFirstName.borderStyle=UITextBorderStyleLine;
        self.txtLastName.borderStyle=UITextBorderStyleLine;
        self.txtMobile.borderStyle=UITextBorderStyleLine;
        
        [buttonEdit setTitle:@"Save" forState:UIControlStateNormal];
    }
    
}

#pragma  -mark change password

- (IBAction)btnChangePassClick:(id)sender {
    
    
    UIButton  *buttonPassChange =(UIButton *)sender;
    
    
    if([buttonPassChange.titleLabel.text isEqual:@"Change Password"])
    {
        self.txtPassword.text=@"";
        self.txtPassword.borderStyle=UITextBorderStyleLine;
        self.txtNewPassword.borderStyle=UITextBorderStyleLine;
        self.txtConfirmPassword.borderStyle=UITextBorderStyleLine;
        
        
        self.txtPassword.enabled  =YES;
        self.txtNewPassword.enabled=YES;
        self.txtConfirmPassword.enabled=YES;
        
        
        [buttonPassChange setTitle:@"Update Password" forState:UIControlStateNormal];
        self.viewPassChanger.hidden =false;
        
    }else if([buttonPassChange.titleLabel.text isEqual:@"Update Password"] ){
        
        
        NSString *errorMessage =[self validateForm];
        
        if ( errorMessage !=nil) {
            
            [[[UIAlertView alloc]initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil]show ];
            return ;
        }
        
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Profile Updated" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
        
        self.txtPassword.borderStyle=UITextBorderStyleLine;
        self.txtConfirmPassword.borderStyle=UITextBorderStyleLine;
        self.txtNewPassword.borderStyle=UITextBorderStyleLine;
        
        
        self.txtPassword.enabled  =NO;
        self.txtNewPassword.enabled=NO;
        self.txtConfirmPassword.enabled=NO;
        
        
        self.txtConfirmPassword.text=@"";
        self.txtNewPassword.text=@"";
        self.txtPassword.text=@"";
        
        
        [buttonPassChange setTitle:@"Change Password" forState:UIControlStateNormal];
        
        self.viewPassChanger.hidden =true;
    }
    else
    {
        [[[UIAlertView alloc]initWithTitle:@"Alert" message:@"please enter valid Password " delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil]show];
    }
}


#pragma -mark limiting the textinput

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *currentString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    int length = (int)[currentString length];
    if ( textField.tag ==4 && length > 10) {
        return NO;
    }
    return YES;
}



- (IBAction)btnMenuClick:(id)sender {
    [self.navigationController.view endEditing:YES];
}


#pragma -mark image picker

- (IBAction)btnImagePickerClick:(id)sender {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"ALERT"
                                                                   message:@"PLEASE SELECT ONE OF THE OPTION."
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* gallaryAction = [UIAlertAction actionWithTitle:@"From Gallary" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              
                                                              [self pickMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
                                                              
                                                          }];
    UIAlertAction* cameraAction = [UIAlertAction actionWithTitle:@"Click from Camera"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [self pickMediaFromSource:UIImagePickerControllerSourceTypeCamera];
                                                         }];
    
    UIAlertAction* cancelAction=[UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                     
                                 }];
    
    
    [alert addAction:gallaryAction];
    [alert addAction:cameraAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
}

- (IBAction)btnCancelClick:(id)sender {
    self.txtPassword.borderStyle=UITextBorderStyleLine;
    self.txtConfirmPassword.borderStyle=UITextBorderStyleLine;
    self.txtNewPassword.borderStyle=UITextBorderStyleLine;
    
    
    self.txtPassword.enabled  =NO;
    self.txtNewPassword.enabled=NO;
    self.txtConfirmPassword.enabled=NO;
    
    
    self.txtConfirmPassword.text=@"";
    self.txtNewPassword.text=@"";
    self.txtPassword.text=@"";
    
    
    [self.btnChangePass setTitle:@"Change Password" forState:UIControlStateNormal];
    
    self.viewPassChanger.hidden =true;
    
}


#pragma -mark update Picture

- (void)updateDisplay
{
    if ([self.lastChosenMediaType isEqual:(NSString *)kUTTypeImage]) {
        self.imgProfile.image = self.image;
        self.imgProfile.hidden = NO;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSData* imageData = UIImagePNGRepresentation(self.image);
        [userDefaults setObject:imageData forKey:@"myEncodedImageDataKey"];
        [userDefaults synchronize];
    }
}


#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.lastChosenMediaType = info[UIImagePickerControllerMediaType];
    if ([self.lastChosenMediaType isEqual:(NSString *)kUTTypeImage]) {
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        self.image = [self shrinkImage:chosenImage
                                toSize:self.imgProfile.bounds.size];
    }
    [self uploadImage:self.image];

    [picker dismissViewControllerAnimated:YES completion:NULL];
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


- (UIImage *)shrinkImage:(UIImage *)original toSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    CGFloat originalAspect = original.size.width / original.size.height;
    CGFloat targetAspect = size.width / size.height;
    CGRect targetRect;
    if (originalAspect > targetAspect) {
        // original is wider than target
        targetRect.size.width = size.width;
        targetRect.size.height = size.height * targetAspect / originalAspect;
        targetRect.origin.x = 0;
        targetRect.origin.y = (size.height - targetRect.size.height) * 0.5;
    } else if (originalAspect < targetAspect) {
        // original is narrower than target
        targetRect.size.width = size.width * originalAspect / targetAspect;
        targetRect.size.height = size.height;
        targetRect.origin.x = (size.width - targetRect.size.width) * 0.5;
        targetRect.origin.y = 0;
    } else {
        // original and target have same aspect ratio
        targetRect = CGRectMake(0, 0, size.width, size.height);
    }
    [original drawInRect:targetRect];
    UIImage *final = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return final;
}

#pragma mark - Update Avtar Image
-(void)uploadImage:(UIImage *)image{
   
    
    NSData *imageData1 = UIImageJPEGRepresentation(image,0.0);
    
    NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
    NSXMLElement *photoXML = [NSXMLElement elementWithName:@"PHOTO"];
    NSXMLElement *typeXML = [NSXMLElement elementWithName:@"TYPE" stringValue:@"image/jpg"];
    
    NSString *image64 = [self encodeToBase64String:image];
    
    NSXMLElement *binvalXML = [NSXMLElement elementWithName:@"BINVAL" stringValue:image64];
    
    [photoXML addChild:typeXML];
    [photoXML addChild:binvalXML];
    [vCardXML addChild:photoXML];
    
   
   // XMPPvCardTemp *myvCardTemp = [[[self appDelegate] xmppvCardTempModule] myvCardTemp];
    
    XMPPvCardTemp *myvCardTemp =[[[self appDelegate] xmppvCardTempModule] vCardTempForJID:user.jid shouldFetch:YES];
    
    if (myvCardTemp) {
        [myvCardTemp setPhoto:imageData1];
    
     //   [[self appDelegate] xmppvCardTempModule] vCardTempForJID:<#(XMPPJID *)#> shouldFetch:<#(BOOL)#>
        [[[self appDelegate] xmppvCardTempModule] updateMyvCardTemp:myvCardTemp];
    }
}

- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

/*-(void)updateInfo{
    XMPPvCardTemp *myvCardTemp = [[[self appDelegate] xmppvCardTempModule] myvCardTemp];
    
    NSLog(@"%@",myvCardTemp);
    if (myvCardTemp) {
        [myvCardTemp setName:self.txtFirstName.text];
        [myvCardTemp setFamilyName:self.txtLastName.text];
        [myvCardTemp setEmailAddresses:@[self.txtLastName.text]];
        [myvCardTemp setTelecomsAddresses:@[self.txtMobile.text]];
        
        [[[self appDelegate] xmppvCardTempModule] updateMyvCardTemp:myvCardTemp];
    }

}*/

- (iPhoneXMPPAppDelegate *)appDelegate{
    return (iPhoneXMPPAppDelegate *)[[UIApplication sharedApplication] delegate];
}
@end
