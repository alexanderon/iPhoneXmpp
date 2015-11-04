//
//  GroupListViewController.m
//  iPhoneXMPP
//
//  Created by RAHUL on 11/3/15.
//  Copyright © 2015 XMPPFramework. All rights reserved.
//

#import "GroupListViewController.h"
#import "iPhoneXMPPAppDelegate.h"
#import "ChatViewController.h"
#import "DDLog.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif


@implementation GroupListViewController

#pragma mark Accessors

- (iPhoneXMPPAppDelegate *)appDelegate
{
    return (iPhoneXMPPAppDelegate *)[[UIApplication sharedApplication] delegate];
}


#pragma mark -------------------NSFetchedResultsController----------------------

-(NSFetchedResultsController *)fetchedGroupsResultsController
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
}



- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] reloadData];
}



#pragma mark ------------------UITableView-------------------------------------



- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
        return @"Groups";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
  
     return [[[self fetchedGroupsResultsController]fetchedObjects]count];
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
    
    

    
    if (indexPath.row<(int)[[[self fetchedGroupsResultsController]fetchedObjects]count]) {
        
        XMPPGroupCoreDataStorageObject *group = [[self fetchedGroupsResultsController] objectAtIndexPath:indexPath];
        
        cell.textLabel.text = group.name;
        
        
      
        
        
    }

    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    XMPPGroupCoreDataStorageObject *group = [[self fetchedGroupsResultsController] objectAtIndexPath:indexPath];
    
    ChatViewController *vc =[self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"] ;
    vc.group=group;
    vc.isGroupchat=YES;
    [self.navigationController pushViewController:vc animated:YES] ;
}


@end
