#import <Foundation/Foundation.h>

@class EventType;

@interface EventTypeCache : NSObject {
	NSManagedObjectContext *managedObjectContext;
	NSMutableDictionary *cache;
	NSEntityDescription *eventTypeEntityDescription;
	NSPredicate *eventTypePredicateTemplate;	
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableDictionary *cache;
@property (nonatomic, retain, readonly) NSEntityDescription *eventTypeEntityDescription;
@property (nonatomic, retain, readonly) NSPredicate *eventTypePredicateTemplate;

- (EventType *)eventTypeWithName:(NSString *)name;


@end
