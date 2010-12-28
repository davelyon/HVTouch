#import <Foundation/Foundation.h>

@interface EventType : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *shortName;
@property (nonatomic, retain) NSString *prefKey;
@property (nonatomic, retain) NSSet *events;


- (BOOL)enabled;

@end
