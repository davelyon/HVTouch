#import "EventType.h"

@implementation EventType

@dynamic name, shortName, prefKey, events;

-(BOOL)enabled{
	return [[NSUserDefaults standardUserDefaults] boolForKey:self.prefKey];
}

@end
