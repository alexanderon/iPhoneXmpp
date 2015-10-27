#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface RootViewController : UIViewController   <NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
	NSFetchedResultsController *fetchedResultsController;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)settings:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *backgroundView;

@end
