#import "NSDateAdditions.h"


@implementation NSDate (HVCategory)

+ (NSDate *)dateInPastForQuery {
	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
  formatter.dateFormat = @"yyyy-d-M";
	
	NSString* formattedTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:(-4*24*60*60)]];
  NSDate* date = [formatter dateFromString:formattedTime];
	[formatter release];
	return date;
}

+ (NSDate *)dateWithToday {
	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
  formatter.dateFormat = @"yyyy-d-M";
	
  NSString* formattedTime = [formatter stringFromDate:[NSDate date]];
  NSDate* date = [formatter dateFromString:formattedTime];
	[formatter release];
	return date;
}

- (NSString *)apiString {
	static NSDateFormatter* formatter = nil;
  if (!formatter) {
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.000'Z'";
  }
  return [formatter stringFromDate:self];
	
}

@end
