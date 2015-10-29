#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface RootViewController : UIViewController   <NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
	NSFetchedResultsController *fetchedResultsController;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (strong, nonatomic) IBOutlet UIView *popUpView;

- (IBAction)settings:(id)sender;
@end
