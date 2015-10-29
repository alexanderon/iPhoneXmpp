//
//  FetcheResultViewController.h
//  iPhoneXMPP
//
//  Created by RAHUL on 10/29/15.
//  Copyright © 2015 XMPPFramework. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "iPhoneXMPPAppDelegate.h"
#import "DDLog.h"



@interface FetcheResultViewController : UIViewController<NSFetchedResultsControllerDelegate>
- (NSFetchedResultsController *)fetchedResultsController;
- (iPhoneXMPPAppDelegate *)appDelegate;
@end
