#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "IASKAppSettingsViewController.h"
@class EventDetailViewController, IASKAppSettingsViewController;

@interface EventsViewController : UIViewController <IASKSettingsDelegate>{

	UITableView *tableView;
	
	UITableViewCell *eventCell;
	
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	NSManagedObjectModel *managedObjectModel;
	
	EventDetailViewController *detailController;
	IBOutlet UIToolbar *toolbar;
	IBOutlet UISegmentedControl *fetchSectioningControl;
	
	NSDateFormatter *dateFormatter;
	
	IASKAppSettingsViewController *appSettingsViewController;

}

@property (nonatomic, assign) IBOutlet	UITableViewCell *eventCell;
@property (nonatomic, retain, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain)						NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet	UITableView *tableView;
@property (nonatomic, retain, readonly) EventDetailViewController *detailController;
@property (nonatomic, retain) IBOutlet	UISegmentedControl *fetchSectioningControl;
@property (nonatomic, retain, readonly)	NSDateFormatter *dateFormatter;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) IASKAppSettingsViewController *appSettingsViewController;

-(void)fetch;
-(void)changeFetchSectioning:(id)sender;
//-(IBAction)didChangeSavedStatus:(id)sender;
- (void)showSettingsModal:(id)sender;

@end
