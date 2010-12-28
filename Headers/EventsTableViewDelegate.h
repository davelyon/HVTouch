
@interface EventsTableViewDelegate : NSObject <UITableViewDelegate, UITableViewDataSource> {
	UITableView *tableView;
	
	UITableViewCell *eventCell;
	
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	NSManagedObjectModel *managedObjectModel;
	
	NSDateFormatter *dateFormatter;
}

@property (nonatomic, retain, readonly) NSFetchedResultsController	*fetchedResultsController;
@property (nonatomic, retain)						NSManagedObjectContext			*managedObjectContext;
@property (nonatomic, retain, readonly)	NSDateFormatter							*dateFormatter;
@property (nonatomic, retain)						NSManagedObjectModel				*managedObjectModel;


@end
