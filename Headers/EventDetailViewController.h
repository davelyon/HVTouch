#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@class Event;

@interface EventDetailViewController : UIViewController <MFMailComposeViewControllerDelegate> {
	Event *event;
	NSArray *eventData;
	NSArray *mediaData;
	NSArray *relatedEvents;
	NSArray *sections;
	UITableView *tableView;	
	NSDateFormatter *dateFormatter;
	
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	NSManagedObjectModel *managedObjectModel;

	UITableViewCell *datumCell;
	
}

@property (nonatomic, retain)	Event *event;
@property (nonatomic, retain) NSArray *eventData;
@property (nonatomic, retain) NSArray *mediaData;
@property (nonatomic, retain) NSArray *relatedEvents;
@property (nonatomic, retain) NSArray *sections;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain, readonly) NSDateFormatter *dateFormatter;

@property (nonatomic, retain, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain)						NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;

@property (nonatomic, retain) IBOutlet UITableViewCell *datumCell;

- (void)mailEventInformation:(id)sender;
- (void)didChangeBookmarkStatus:(id)sender;
- (void)launchImageViewer:(id)sender;
@end
