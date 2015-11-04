//
//  GroupListViewController.h
//  iPhoneXMPP
//
//  Created by RAHUL on 11/3/15.
//  Copyright © 2015 XMPPFramework. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface GroupListViewController : UIViewController <NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
        NSFetchedResultsController *fetchedGroupsResultsController;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
