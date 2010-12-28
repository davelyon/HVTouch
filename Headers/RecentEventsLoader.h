#import "YAJLDocument.h"

@class Event, EventTypeCache, RecentEventsLoader, YAJLDocument;

@protocol RecentEventsLoaderDelegate <NSObject>

@optional
// Notification posted by NSManagedObjectContext when saved.
- (void)importerDidSave:(NSNotification *)saveNotification;
// Called by the importer when parsing is finished.
- (void)importerDidFinishParsingData:(RecentEventsLoader *)loader;
// Called by the importer in the case of an error.
- (void)importer:(RecentEventsLoader *)loader didFailWithError:(NSError *)error;

@end


@interface RecentEventsLoader : NSOperation <YAJLDocumentDelegate>{
	
@private
	id <RecentEventsLoaderDelegate> delegate;
	NSURLConnection *urlConnection;
	BOOL completed;
	
	NSManagedObjectContext *insertionContext;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
	NSEntityDescription *eventEntityDescription;
	
	NSURL *requestURL;
	YAJLDocument *document;
	NSDateFormatter *dateFormatter;
	
	EventTypeCache *eventTypeCache;
	NSArray *duplicates;
	
	NSAutoreleasePool *importPool;
	NSUInteger importCount;

}

@property (nonatomic, retain) NSURL *requestURL;
@property (nonatomic, assign) id <RecentEventsLoaderDelegate> delegate;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectContext *insertionContext;
@property (nonatomic, retain, readonly) NSEntityDescription *eventEntityDescription;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, retain, readonly) EventTypeCache *eventTypeCache;
@property (nonatomic, retain, readonly) NSArray *duplicates;

- (void)main;
- (BOOL)isDuplicate:(NSString *)uidKey;
@end
