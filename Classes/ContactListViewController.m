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


@interface ContactListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet TLTagsControl *defaultEditingTagControl;
@end

@implementation ContactListViewController
{
    NSMutableArray *tags ;
}
@synthesize tableView;

#pragma mark ----------VIEW LIFECYCLE -------------
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

#pragma mark --------------TABLE VIEW DELEGATE -------------

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

#pragma mark ---------------------TABLE VIEW DATASOURCE ----------------

-(UITableViewCell *)tableView:(UITableView *)tabView cellForRowAtIndexPath:(NSIndexPath *)indexPath
    {
    
    UITableViewCell *cell =[tabView  dequeueReusableCellWithIdentifier:@"ContactCell"];
    
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    cell.textLabel.text = user.jidStr;
    [self configurePhotoForCell:cell user:user];
    return cell;
}



#pragma mark --------------------UITABLECELL HELPERS---------------------

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

#pragma mark -------------------TLTAG-CONTROL-DELEGATE--------------------

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

@end
