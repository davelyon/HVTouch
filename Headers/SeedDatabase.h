#import <Foundation/Foundation.h>


@interface DatabaseSeeder : NSObject {
	NSManagedObjectContext insertionContext;
}

@property (nonatomic,retain)NSManagedObjectContext insertionContext;

@end
