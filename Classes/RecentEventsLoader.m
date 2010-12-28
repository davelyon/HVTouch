#import "RecentEventsLoader.h"
#import "Event.h"
#import "EventType.h"
#import "EventTypeCache.h"
#import "NSObject+YAJL.h"
#import "YAJLDocument.h"

@interface RecentEventsLoader ()

@property BOOL done;
@property (nonatomic, retain) NSURLConnection *urlConnection;
@property (nonatomic, assign) NSAutoreleasePool *importPool;
@end


@implementation RecentEventsLoader

@synthesize requestURL, delegate, persistentStoreCoordinator;
@synthesize urlConnection, done, dateFormatter, duplicates, importPool;

-(void)dealloc {
	[eventTypeCache release];
	[dateFormatter release];
	[requestURL release];
	[urlConnection release];
	[persistentStoreCoordinator release];
	[insertionContext release];
	[eventEntityDescription release];
	[duplicates release];
	[super dealloc];
}

-(void)main {
	self.importPool = [[NSAutoreleasePool alloc] init];
	importCount = 0;
	// If a delegate exists, it should be watching for this thread to save
	if (delegate && [delegate respondsToSelector:@selector(importerDidSave:)]) {
		[[NSNotificationCenter defaultCenter] addObserver:delegate selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.insertionContext];
	}
	
	done = NO; // When we start, the request is not complete.
	
	NSDateFormatter *aDateFormatter = [[NSDateFormatter alloc] init];
	[aDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"]; // See: http://unicode.org/reports/tr35/tr35-6.html#Date_Format_Patterns
	[aDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	self.dateFormatter = aDateFormatter;
	[aDateFormatter release];
	
	// Start the connection and begin receiving data
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:requestURL];

	document = [[YAJLDocument alloc] init];
	document.delegate = self;
	self.urlConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	theRequest = nil;
	
	// Loop until the connection has received all the data it is going to
	if (urlConnection != nil) {
		do {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		} while (!done);
	}
	

	[urlConnection release];

	self.urlConnection = nil;
	self.dateFormatter = nil;
	
	document.delegate = nil;
	[document release];
	document = nil;
	
	NSError *saveError = nil;
	NSAssert1([insertionContext save:&saveError], @"Unhandled error saving managed object context in import thread: %@", [saveError localizedDescription]);
	
	if (delegate && [delegate respondsToSelector:@selector(importerDidSave:)]) {
		[[NSNotificationCenter defaultCenter] removeObserver:delegate name:NSManagedObjectContextDidSaveNotification object:self.insertionContext];
	}
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(importerDidFinishParsingData:)]) {
		[self.delegate importerDidFinishParsingData:self];
	}
	
	[importPool release]; self.importPool = nil;
	
	
}

- (NSManagedObjectContext *)insertionContext {
	if (insertionContext == nil) {
		insertionContext = [[NSManagedObjectContext alloc] init];
		//[insertionContext setRetainsRegisteredObjects:NO];
		[insertionContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
	}
	return insertionContext;
}

- (void)forwardError:(NSError *)error {
	if (self.delegate != nil && [self.delegate respondsToSelector:@selector(importer:didFailWithError:)]) {
		[self.delegate importer:self didFailWithError:error];
	}
}

- (NSEntityDescription *)eventEntityDescription {
	if (eventEntityDescription == nil) {
		eventEntityDescription = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.insertionContext];
	}
	return eventEntityDescription;
}

- (EventTypeCache	*)eventTypeCache {
	if (eventTypeCache == nil) {
		eventTypeCache = [[EventTypeCache alloc] init];
		[eventTypeCache setManagedObjectContext:self.insertionContext];
	}
	return eventTypeCache;
}

#pragma mark NSURLConnection Delegate methods

// Forward errors to the delegate.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	//[self performSelectorOnMainThread:@selector(forwardError:) withObject:error waitUntilDone:NO];
	// Set the condition which ends the run loop.
	done = YES;
}

// Called when a chunk of data has been downloaded.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

	NSError *error = nil;
	[document parse:data error:&error];
	if(error){
		NSLog(@"YAJL Parse Error! %@", [error localizedDescription]);
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	done = YES; 
}


static NSString *const kUidKey							= @"kb_archivid";
static NSString *const kEventTypeKey				= @"concept";
static NSString *const kFromInstituteKey		=	@"frm_institute";
static NSString *const kObservatoryKey			= @"obs_observatory";
static NSString *const kStartTimeKey				= @"event_starttime";
static NSString *const kEndTimeKey					= @"event_endtime";
static NSString *const kReceivedDateFormat	= @"yyyy-MM-dd'T'HH:mm:ss'Z'";
static NSString *const kOutputDateFormat		= @"MMMM dd, yyyy'\n'HH:mm:ss'Z'";
static NSString *const kLocationXKey				= @"hpc_x";
static NSString *const kLocationYKey				= @"hpc_y";
static NSString *const kHPCoordsKey					= @"hpc_bbox";
static NSString *const kImagesKey						= @"screenshots";

static NSString *const kUidPrefixString			= @"ivo://helio-informatics.org/";
static NSString *const kUidPrefixReplacement = @"images";


#pragma mark -
#pragma mark YAJL document delegate methods
- (void)document:(YAJLDocument *)document didAddDictionary:(NSDictionary *)dict {
	if([dict objectForKey:kUidKey] == nil) return;
	if([self isDuplicate:[dict objectForKey:kUidKey]]) return;
		
	Event *newEvent = [[Event alloc] initWithEntity:self.eventEntityDescription insertIntoManagedObjectContext:self.insertionContext];

	NSString *uidString			= [dict valueForKey:kUidKey];
	newEvent.uid						=	uidString;

	newEvent.fromInstitute	= [dict valueForKey:kFromInstituteKey];
	newEvent.observatory		= [dict valueForKey:kObservatoryKey];
	newEvent.startTime			= [dateFormatter dateFromString:[dict valueForKey:kStartTimeKey]];
	
	NSDate *startDate = [dateFormatter dateFromString:[dict valueForKey:kStartTimeKey]];
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dateOnly = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:startDate];
	newEvent.startDate = [gregorian dateFromComponents:dateOnly];
	[gregorian release];
	
	newEvent.endTime				= [dateFormatter dateFromString:[dict valueForKey:kEndTimeKey]];
										
	newEvent.locationx			=	[dict valueForKey:kLocationXKey];
	newEvent.locationy			=	[dict valueForKey:kLocationYKey];

	
	EventType *eventType = [self.eventTypeCache eventTypeWithName:[dict valueForKey:kEventTypeKey]];
	newEvent.eventType			= eventType;
	newEvent.eventName			= [dict valueForKey:kEventTypeKey];
	
	NSArray *images = [dict valueForKey:kImagesKey];
	newEvent.images	= images;	
	importCount++;
	
	if(importCount >= 25) {

		[importPool release];
		self.importPool = [[NSAutoreleasePool alloc] init];
		importCount = 0;
		NSError *saveError = nil;
		NSAssert1([self.insertionContext save:&saveError], @"Unhandled error saving managed object context in import thread: %@", [saveError localizedDescription]);
	}
	
}

- (BOOL)isDuplicate:(NSString *)uidKey {
	NSFetchRequest *deduper = [[NSFetchRequest alloc] init];
	[deduper setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.insertionContext]];
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"uid == %@",uidKey];
	[deduper setPredicate:pred];

	NSError *error = nil;
	NSUInteger count = [self.insertionContext countForFetchRequest:deduper error:&error];

	[deduper release];
	//TODO: error handling goes here
	if( count >= 1 ){
		return YES;
	}else {
		return NO;
	}

}

@end
