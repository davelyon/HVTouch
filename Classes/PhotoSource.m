#import "PhotoSource.h"


@implementation PhotoSource

@synthesize photos=_photos;
@synthesize numberOfPhotos=_numberOfPhotos;


- (id)initWithPhotos:(NSArray*)photos{
	
	if (self = [super init]) {
		
		_photos = [photos retain];
		_numberOfPhotos = [_photos count];
		
	}
	
	return self;
	
}

- (id <EGOPhoto>)photoAtIndex:(NSInteger)index{
	
	return [_photos objectAtIndex:index];
	
}

- (void)dealloc{
	
	[_photos release], _photos=nil;
	[super dealloc];
}

@end
