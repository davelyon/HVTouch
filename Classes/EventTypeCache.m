#import "EventTypeCache.h"
#import "EventType.h"

/*
 
 CacheNode is a simple object to help with tracking cached items. 
 TODO: Find the apple code I borrowed this from...
 */

@interface CacheNode : NSObject {
	NSManagedObjectID *objectID;
	NSUInteger accessCounter;
}

@property (nonatomic, retain) NSManagedObjectID *objectID;
@property NSUInteger accessCounter;

@end

@implementation CacheNode

@synthesize objectID, accessCounter;

- (void)dealloc {
	[objectID release];
	[super dealloc];
}

@end


@implementation EventTypeCache

@synthesize managedObjectContext, cache;

- (id)init {
	self = [super init];
	if (self != nil) {
		cache = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[eventTypeEntityDescription release];
	eventTypeEntityDescription = nil;
	[eventTypePredicateTemplate release];
	eventTypePredicateTemplate = nil;
	[managedObjectContext release];
	[cache release];
	[super dealloc];
}

// Implement the "set" accessor rather than depending on @synthesize so that we can set up registration
// for context save notifications.
- (void)setManagedObjectContext:(NSManagedObjectContext *)aContext {
	if (managedObjectContext) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:managedObjectContext];
		[managedObjectContext release];
	}
	managedObjectContext = [aContext retain];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:managedObjectContext];
}

// When a managed object is first created, it has a temporary managed object ID. When the managed object context in which it was created is saved, the temporary ID is replaced with a permanent ID. The temporary IDs can no longer be used to retrieve valid managed objects. The cache handles the save notification by iterating through its cache nodes and removing any nodes with temporary IDs.
// While it is possible force Core Data to provide a permanent ID before an object is saved, using the method -[ NSManagedObjectContext obtainPermanentIDsForObjects:error:], this method incurrs a trip to the database, resulting in degraded performance - the very thing we are trying to avoid. 
- (void)managedObjectContextDidSave:(NSNotification *)notification {
	CacheNode *cacheNode = nil;
	NSMutableArray *keys = [NSMutableArray array];
	for (NSString *key in cache) {
		cacheNode = [cache objectForKey:key];
		if ([cacheNode.objectID isTemporaryID]) {
			[keys addObject:key];
		}
	}
	[cache removeObjectsForKeys:keys];
}

- (NSEntityDescription *)eventTypeEntityDescription {
	if (eventTypeEntityDescription == nil) {
		eventTypeEntityDescription = [[NSEntityDescription entityForName:@"EventType" inManagedObjectContext:managedObjectContext] retain];
	}
	return eventTypeEntityDescription;
}

static NSString * const kCategoryNameSubstitutionVariable = @"NAME";

- (NSPredicate *)eventTypePredicateTemplate {
	if (eventTypePredicateTemplate == nil) {
		NSExpression *leftHand = [NSExpression expressionForKeyPath:@"name"];
		NSExpression *rightHand = [NSExpression expressionForVariable:kCategoryNameSubstitutionVariable];
		eventTypePredicateTemplate = [[NSComparisonPredicate alloc] initWithLeftExpression:leftHand rightExpression:rightHand modifier:NSDirectPredicateModifier type:NSLikePredicateOperatorType options:0];   
	}
	return eventTypePredicateTemplate;
}


- (EventType *)eventTypeWithName:(NSString *)name {

	// check cache
	CacheNode *cacheNode = [cache objectForKey:name];

	if (cacheNode != nil) {
		// cache hit, update access counter
		EventType *eventType = (EventType *)[managedObjectContext objectWithID:cacheNode.objectID];
		return eventType;
	}

	// cache missed, fetch from store - if not found in store there is no category object for the name and we must create one
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:self.eventTypeEntityDescription];
	NSPredicate *predicate = [self.eventTypePredicateTemplate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObject:name forKey:kCategoryNameSubstitutionVariable]];
	[fetchRequest setPredicate:predicate];
	NSError *error = nil;
	NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	NSAssert1(fetchResults != nil, @"Unhandled error executing fetch request in import thread: %@", [error localizedDescription]);
	
	EventType *eventType = nil;

	if ([fetchResults count] > 0) {
		// get category from fetch
		eventType = [fetchResults objectAtIndex:0];
	} else if ([fetchResults count] == 0) {
		// category not in store, must create a new category object 
		eventType = [[EventType alloc] initWithEntity:self.eventTypeEntityDescription insertIntoManagedObjectContext:managedObjectContext];
		eventType.name = name;
		[eventType autorelease];
	}

	// create a new cache node
	cacheNode = [[CacheNode alloc] init];
	cacheNode.objectID = [eventType objectID];
	[cache setObject:cacheNode forKey:name];
	[cacheNode release];
	
	return eventType;
}


@end
