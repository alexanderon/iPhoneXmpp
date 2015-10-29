//
//  ContactListViewController.m
//  iPhoneXMPP
//
//  Created by RAHUL on 10/29/15.
//  Copyright © 2015 XMPPFramework. All rights reserved.
//

#import "ContactListViewController.h"
#import "XMPPFramework.h"
#import "TLTagsControl.h"


@interface ContactListViewController ()<TLTagsControlDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet TLTagsControl *defaultEditingTagControl;
@end

@implementation ContactListViewController
{
    TLTagsControl *demoTagsControl;
    NSMutableArray *tags ;
}
@synthesize tableView;

#pragma mark ----------VIEW LIFECYCLE -------------
-(void)viewDidLoad
{
    [super viewDidLoad];
   
    [self showNavigation];
    [self hideNaviagation];
 
    [demoTagsControl reloadTagSubviews];
    [demoTagsControl setTapDelegate:self];
    
    [self.view addSubview:demoTagsControl];
    [self drawUnderLine:demoTagsControl.tag];
    
    tableView.delegate=self;
    tableView.dataSource=self;
    
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
     [self drawUnderLine:self.defaultEditingTagControl.tag];
   // [self.defaultEditingTagControl setBackgroundColor:[UIColor greenColor]];
}

-(void)drawUnderLine:(NSInteger *)tag{
    
        UIView  *view = [self.view viewWithTag:tag];
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.frame = CGRectMake(0.0f, view.frame.size.height-1 , view.frame.size.width,1.0f);
        bottomBorder.backgroundColor = [UIColor blackColor].CGColor;
        [view.layer insertSublayer:bottomBorder atIndex:(int)view.layer.sublayers.count];

}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ---------GENEREAL METHODS-----------------

-(void)showNavigation{
    self.navigationController.navigationBarHidden=NO;
}

-(void)hideNaviagation{
    self.navigationController.navigationBarHidden=YES;
}

#pragma mark ----------TABLE VIEW DELEGATE -------------

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[self fetchedResultsController] fetchedObjects] count];
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Favourite";
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

#pragma mark ----------TABLE VIEW DATASOURCE -----------

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell =[tableView  dequeueReusableCellWithIdentifier:@"ContactCell"];
    
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    cell.textLabel.text = user.displayName;
    
    [self configurePhotoForCell:cell user:user];

    return cell;
}



#pragma mark -------------UITABLECELL HELPERS-------------------


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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
