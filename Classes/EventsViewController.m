#import "EventsViewController.h"
#import "Event.h"
#import "EventDetailViewController.h"
#import "NSDateAdditions.h"
#import "IASKAppSettingsViewController.h"


@implementation EventsViewController

@synthesize eventCell, managedObjectContext, tableView, fetchSectioningControl, managedObjectModel, appSettingsViewController;

- (void)viewDidLoad {
	[super viewDidLoad];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:self.managedObjectContext];

	[self fetch];
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Events" style:UIBarButtonItemStylePlain target:self action:nil];
	self.navigationItem.backBarButtonItem = backButton;
	[backButton release];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	self.tableView = nil;
	//self.fetchSectioningControl = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:self.managedObjectContext];
}

- (UISegmentedControl *)fetchSectioningControl {
	if(!fetchSectioningControl) {
		fetchSectioningControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"By Type", @"By Date", @"Saved", nil]];
		[fetchSectioningControl setSegmentedControlStyle:UISegmentedControlStyleBar];
		[fetchSectioningControl addTarget:self action:@selector(changeFetchSectioning:) forControlEvents:UIControlEventValueChanged];
		[fetchSectioningControl setTintColor:[UIColor darkGrayColor]];
		[fetchSectioningControl setSelectedSegmentIndex:0];
	}
	return fetchSectioningControl;
}

- (NSArray *)toolbarItems {
	UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	
	UIBarButtonItem *sortSelector = [[UIBarButtonItem	alloc] initWithCustomView:self.fetchSectioningControl];
	sortSelector.width = 240.0f;
	
	UIBarButtonItem *preferencesButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"20-gear2.png"] 
																																				style:UIBarButtonItemStyleBordered 
																																			 target:self
																																			 action:@selector(showSettingsModal:)];
	
	
	NSArray *items = [NSArray arrayWithObjects:flexSpace,sortSelector,flexSpace,preferencesButton,flexSpace,nil];
	[flexSpace release];
	[sortSelector release];
	[preferencesButton release];
	return items;
}

-(NSDateFormatter *)dateFormatter {
	if(dateFormatter == nil){
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle]; // See: http://unicode.org/reports/tr35/tr35-6.html#Date_Format_Patterns
	}
	return dateFormatter;
}


- (void)handleSaveNotification:(NSNotification *)aNotification {
	[managedObjectContext mergeChangesFromContextDidSaveNotification:aNotification];
	[self fetch];
}

- (void)changeFetchSectioning:(id)sender {
	[fetchedResultsController release];
	fetchedResultsController = nil;
	if([fetchSectioningControl selectedSegmentIndex] == 2){
		self.title = @"Saved Events";
	} else {
		self.title = @"Recent Events";
	}

	[self fetch];	
}

//- (IBAction)didChangeSavedStatus:(id)sender {

//	NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
//	Event *event = [fetchedResultsController objectAtIndexPath:indexPath];
//	event.bookmarked = [NSNumber numberWithBool:![event.bookmarked boolValue]];
//	[self.managedObjectContext save:nil];
//}


- (void)fetch {
	NSError *error = nil;
	BOOL success = [self.fetchedResultsController performFetch:&error];
	NSAssert2(success, @"Unhandled error performing fetch at EventsViewController.m, line %d: %@", __LINE__, [error localizedDescription]);
	[self.tableView reloadData];
}

- (EventDetailViewController *)detailController {
	[detailController release]; detailController =nil;
	if(detailController == nil){
		detailController = [[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil];
		detailController.managedObjectContext = self.managedObjectContext;
		detailController.managedObjectModel = self.managedObjectModel;
	}
	
	return detailController;
}

- (NSFetchedResultsController *)fetchedResultsController {

	if(fetchedResultsController == nil) {
		NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
		[fetchRequest setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext]];
		NSString *sectionNameKeyPath = nil;
		NSArray *sortDescriptors = nil;
		NSPredicate *defaultPredicate = [NSPredicate predicateWithFormat:@"startDate between {%@, %@}", [NSDate dateInPastForQuery], [NSDate dateWithToday]];
		[fetchRequest setPredicate:defaultPredicate];
		if([fetchSectioningControl selectedSegmentIndex] == 0)	{
			sortDescriptors = [NSArray arrayWithObjects:
																	[[[NSSortDescriptor alloc] initWithKey:@"eventType.name" ascending:YES] autorelease],
																	[[[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:NO] autorelease], nil];
			sectionNameKeyPath = @"eventType.name";

		} else if ([fetchSectioningControl selectedSegmentIndex] == 1){
			sortDescriptors = [NSArray arrayWithObjects:[[[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:NO] autorelease],
			[[[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:NO] autorelease], nil];
			sectionNameKeyPath = @"startDate";
		} else {
			NSPredicate *bookmarkPredicate = [NSPredicate predicateWithFormat:@"bookmarked == YES"];
			[fetchRequest setPredicate:bookmarkPredicate];
			sortDescriptors = [NSArray arrayWithObjects:
												 [[[NSSortDescriptor alloc] initWithKey:@"eventType.name" ascending:YES] autorelease],
												 [[[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:NO] autorelease], nil];
			sectionNameKeyPath = @"eventType.name";
		}

		[fetchRequest setSortDescriptors:sortDescriptors];
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:sectionNameKeyPath cacheName:nil];
	}
	return fetchedResultsController;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	[fetchedResultsController release];
	[dateFormatter release];
	[managedObjectContext release];
	[tableView release];
	[detailController release];
	[eventCell release];
	[super dealloc];
}

#pragma mark -
#pragma mark Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
	return [[fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)table titleForHeaderInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
	if ([fetchSectioningControl selectedSegmentIndex] == 1) { // If sorting by date, we want to see 20XX-MM-DD

		[self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];

		NSDate *sectionDate = [self.dateFormatter dateFromString:[sectionInfo name]];
		[self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		//[self.dateFormatter setDoesRelativeDateFormatting:YES];
		return [self.dateFormatter stringFromDate:sectionDate];
	}
	return [sectionInfo name];
}

- (NSInteger)tableView:(UITableView *)table sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	// tell table which section corresponds to section title/index (e.g. "B",1))
	return [fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *kCellIdentifier = @"EvCell";
	
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"EventCell" owner:self options:nil];
		cell = eventCell;
		self.eventCell = nil;
	}
	Event *event = [fetchedResultsController objectAtIndexPath:indexPath];
	UILabel *label;
	
	label = (UILabel *)[cell viewWithTag:1];
	label.text = [NSString stringWithFormat:@"%@", event.eventName];
	
	//[self.dateFormatter setDoesRelativeDateFormatting:NO];
	[self.dateFormatter setDateStyle:NSDateFormatterLongStyle];
	[self.dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	
	label = (UILabel *)[cell viewWithTag:2];
	label.text = [NSString stringWithFormat:@"%@", [self.dateFormatter stringFromDate:event.startTime]];

	if( [event.bookmarked boolValue]) {
		label = (UILabel *)[cell viewWithTag:10];
		[label setText:@"Saved"];
	}

	cell.imageView.image = [UIImage imageWithContentsOfFile:
													[[NSBundle mainBundle] pathForResource:
													 [NSString stringWithFormat:@"%@", [event.eventName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] ]  
																									ofType:@"png"]];

	return cell;
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[table deselectRowAtIndexPath:indexPath animated:YES];
	EventDetailViewController *newDetailController = self.detailController;
	newDetailController.event = [fetchedResultsController objectAtIndexPath:indexPath];
	[self.navigationController pushViewController:newDetailController animated:YES];
}

#pragma mark -
#pragma mark In app settings

- (IASKAppSettingsViewController*)appSettingsViewController {
	if (!appSettingsViewController) {
		appSettingsViewController = [[IASKAppSettingsViewController alloc] initWithNibName:@"IASKAppSettingsView" bundle:nil];
		appSettingsViewController.delegate = self;
	}
	return appSettingsViewController;
}

- (void)showSettingsModal:(id)sender {
	UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController:self.appSettingsViewController];
	//[viewController setShowCreditsFooter:NO];   // Uncomment to not display InAppSettingsKit credits for creators.
	// But we encourage you not to uncomment. Thank you!
	self.appSettingsViewController.showDoneButton = YES;
	self.appSettingsViewController.delegate = self;
	[self.navigationController presentModalViewController:aNavController animated:YES];
	[aNavController release];
}

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
	[self dismissModalViewControllerAnimated:YES];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults synchronize];
	NSLog(@"User Defaults: %@", [defaults dictionaryRepresentation]);
	// your code here to reconfigure the app for changed settings
}

@end
