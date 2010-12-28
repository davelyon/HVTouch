#import "EventDetailViewController.h"
#import "Event.h"
#import "Photo.h"
#import "PhotoSource.h"

#import <MessageUI/MFMailComposeViewController.h>
#import "NSDateAdditions.h"

@implementation EventDetailViewController

@synthesize event, eventData, mediaData, relatedEvents, sections, tableView, managedObjectContext, managedObjectModel, datumCell;

#pragma mark -
#pragma mark View lifecycle

-(void)viewWillAppear:(BOOL)animated {

}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.sections = [NSArray arrayWithObjects:event.eventName,@"Possibly Related Events", nil];
	self.title = @"Event";
	
	[self.fetchedResultsController performFetch:nil];
	//TODO: Error handling
	[self.tableView setRowHeight:60.0f];
	[self.tableView reloadData];
	
}

- (NSArray *)toolbarItems {
	UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"28-star.png"] style:UIBarButtonItemStylePlain target:self action:@selector(didChangeBookmarkStatus:)];
	UIBarButtonItem *mailButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"18-envelope.png"] style:UIBarButtonItemStylePlain target:self action:@selector(mailEventInformation:)];
	UIBarButtonItem *imageButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"42-photos.png"] style:UIBarButtonItemStylePlain target:self action:@selector(launchImageViewer:)];
	UIBarButtonItem *movieButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"46-movie2.png"] style:UIBarButtonItemStylePlain target:self action:nil];
	if (self.event.images.count == 0) { // No images
		[imageButton setEnabled:NO];
	}
	
	if (self.event.movies.count == 0) {// No movies
		[movieButton setEnabled:NO];
	}
	
	NSArray *items = [NSArray arrayWithObjects:flexSpace, saveButton, flexSpace, mailButton, flexSpace, imageButton, flexSpace, movieButton, flexSpace, nil];
	[flexSpace release];
	[saveButton release];
	[mailButton release];
	[imageButton release];
	[movieButton release];
	
	return items;
}

-(NSDateFormatter *)dateFormatter {
	if(dateFormatter == nil){
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
		[dateFormatter setDateFormat:@"d MMM, yyyy - HH:mm:ss 'UTC'"]; // See: http://unicode.org/reports/tr35/tr35-6.html#Date_Format_Patterns
	}
	return dateFormatter;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


- (void)dealloc {
	[event release];
	[eventData release];
	[dateFormatter release];
	[sections	release];
	[relatedEvents release];
	[tableView release];
	[fetchedResultsController release]; fetchedResultsController = nil;
	[super dealloc];
}


#pragma mark -
#pragma mark Table view methods

-(NSArray *)eventData {
	if(eventData == nil) {
		
		// Each sub array is laid out as follows: displayName, value
		self.eventData = [NSArray arrayWithObjects:
											[NSArray arrayWithObjects:@"Began", [self.dateFormatter stringFromDate:event.startTime], nil],
											[NSArray arrayWithObjects:@"Ended", [self.dateFormatter stringFromDate:event.endTime], nil],
											[NSArray arrayWithObjects:@"Location (HPC)", [NSString stringWithFormat:@"[ %.4f , %.4f ]", [event.locationx floatValue], [event.locationy floatValue] ], nil],
											[NSArray arrayWithObjects:@"Observatory", event.observatory, nil],
											nil];
	}
	return eventData;
}

-(NSArray *)mediaData {
	if(mediaData == nil){
		self.mediaData	 = [NSArray arrayWithObjects:@"No Images", @"No Movies", nil];
	}
	return mediaData;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return [self.eventData count];
			break;
		case 1:
			return 0;//[self.fetchedResultsController.fetchedObjects count];
							 //TODO: Re-enable possibly related
		default:
			break;
	}	
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return [self.sections objectAtIndex:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
	switch (section) {
		case 0:
			return [NSString stringWithFormat:@"Reported By: %@",event.fromInstitute];
			break;
		default:
			return nil;
			break;
	}
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *kCellIdentifier = @"datumCell";
	
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"DatumCell" owner:self options:nil];
		cell = datumCell;
		self.datumCell = nil;
	}
	
	if(indexPath.section == 0){
		NSArray *data;
		data = [self.eventData objectAtIndex:indexPath.row];
		
		UILabel *label;
		label = (UILabel *)[cell viewWithTag:2];
		label.text = [data objectAtIndex:0];
		
		label = (UILabel *)[cell viewWithTag:4];
		label.text = [data objectAtIndex:1];
		
	} else {
		Event *relEvent = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
		NSString *text = (NSString *)relEvent.uid;
		cell.textLabel.text = text;
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}
	
	return cell;
	
}

- (NSFetchedResultsController *)fetchedResultsController {
	
	if(fetchedResultsController == nil) {
		NSFetchRequest *request = [self.managedObjectModel
															 fetchRequestFromTemplateWithName:@"likelySameEventByStartTimeEndTimeEventTypeUID" 
															 substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
																											self.event.startTime, @"startTime",
																											self.event.endTime, @"endTime", 
																											self.event.uid, @"uid",
																											nil
																											]];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:
																[[[NSSortDescriptor alloc] initWithKey:@"eventType.name" ascending:YES] autorelease],
																[[[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:NO] autorelease], nil];
		request.sortDescriptors = sortDescriptors;
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];

	}
	return fetchedResultsController;
}

#pragma mark -
#pragma mark Mail Methods

- (void)mailEventInformation:(id)sender {
	
	if([MFMailComposeViewController canSendMail] ){ // If user cannot send email
		MFMailComposeViewController *mailer = [[[MFMailComposeViewController alloc] init] retain];
		
		mailer.mailComposeDelegate = self;
		
		[mailer setSubject:[NSString stringWithFormat:@"Helioviewer Event: %@", event.eventName]];
		[mailer setMessageBody:[NSString stringWithFormat:@"http://helioviewer.org/index.php?date=%@",[event.startTime apiString]] isHTML:NO];
		[self presentModalViewController:mailer animated:YES];
		[mailer release];
		
	}else	{
		UIAlertView *mailAlert = [[UIAlertView alloc] initWithTitle:@"Mail Error" 
																												message:@"Unable to send email on this device.  Please ensure you have an active email account on this device." 
																											 delegate:self 
																							cancelButtonTitle:@"OK" 
																							otherButtonTitles:nil];
		[mailAlert show];
		[mailAlert release];
	}
}

-(void)mailComposeController:(MFMailComposeViewController *)controller 
				 didFinishWithResult:(MFMailComposeResult)result 
											 error:(NSError *)error {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Favorite Button

-(void)didChangeBookmarkStatus:(id)sender {
	BOOL current = [event.bookmarked boolValue];
	event.bookmarked = [NSNumber numberWithBool:!current];
	[managedObjectContext save:nil];
	//TODO: Proper error handling
	if (current == YES) {
		self.title = @"Event";
	} else {
		self.title = @"Event (Saved)";
	}

}

#pragma mark -
#pragma mark Image view methods

- (void)launchImageViewer:(id)sender{

	NSUInteger theCount = event.images.count;
	if (theCount == 0){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Images" 
																										message:@"No images are available for this event at this time.  Try again later, or check Helioviewer.org" 
																									 delegate:nil 
																					cancelButtonTitle:@"Close" 
																					otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else {
		NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:theCount];
		for (NSString *url in event.images) {
			[photos addObject:[[[Photo alloc] initWithImageURL:[NSURL URLWithString:url]]autorelease]];
		}
		
		PhotoSource *photoSource = [[PhotoSource alloc] initWithPhotos:photos];
		EGOPhotoViewController *photoController = [[EGOPhotoViewController alloc] initWithPhotoSource:photoSource];

		[self.navigationController pushViewController:photoController animated:YES];
		
		[photos release];
		[photoSource release];
		[photoController release];
		
	}

}

#pragma mark -
#pragma mark Movie view methods



@end

