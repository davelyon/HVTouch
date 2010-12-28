@class EventType;

@interface Event : NSManagedObject 

@property (nonatomic, retain)		NSString		*uid;
@property (nonatomic, retain)		EventType		*eventType;
@property (nonatomic, retain)		EventType		*eventName;
@property (nonatomic, retain)		NSString		*fromInstitute;
@property (nonatomic, retain)		NSString		*observatory;
@property (nonatomic, retain)		NSDate			*startTime;
@property (nonatomic, retain)		NSDate			*endTime;
@property (nonatomic, retain)		NSDate			*startDate;
@property (nonatomic, retain)		NSNumber		*locationx;
@property (nonatomic, retain)		NSNumber		*locationy;
@property (nonatomic, retain)		NSNumber		*bookmarked;
@property (nonatomic, retain)		NSArray			*images;
@property (nonatomic, retain)		NSArray			*movies;

@end
