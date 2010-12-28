#import "EventsTableViewDelegate.h"
#import "NSDateAdditions.h"

@implementation EventsTableViewDelegate

@synthesize managedObjectContext, managedObjectModel;


-(NSDateFormatter *)dateFormatter {
	if(dateFormatter == nil){
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle]; // See: http://unicode.org/reports/tr35/tr35-6.html#Date_Format_Patterns
	}
	return dateFormatter;
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


@end
